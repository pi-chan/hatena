require 'faraday'
require 'simple_oauth'

module Hatena
  module Blog
    class Client

      def initialize(consumer_key, consumer_secret, token, token_secret, hatena_id, blog_id)
        @credentials = {
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: token,
          token_secret: token_secret,
        }
        @hatena_id = hatena_id
        @blog_id = blog_id
      end

      def fetch_entries(options={})
        @range = options[:range]
        @limit = options[:limit]
        @draft = options[:draft]
        @entries = []
        @total_count = 0
        
        uri = URI.parse("https://blog.hatena.ne.jp/#{@hatena_id}/#{@blog_id}/atom/entry")
        while true
          uri = fetch_page(uri)
          break unless uri
        end

        return @entries
      end

      def fetch_drafts(options={})
        options[:draft] = true
        fetch_entries(options)
      end

      def fetch_published(options={})
        options[:draft] = false
        fetch_entries(options)
      end

      def fetch_entry(url)
        body = fetch_entry_body(url)
        doc = Nokogiri::XML(body)
        Hatena::Blog::Entry.new(doc)
      end

      def publish(url)
        # raise Hatena::NotDraftError if entry.draft?

        body = fetch_entry_body(url)
        body.gsub!(/<app:draft>yes<\/app:draft>/, "<app:draft>no</app:draft>")
        date = DateTime.now.to_s # (DateTime.now - 1.0/1440).to_s
        %W(updated published app:edited).each do |tag|
          body.gsub!(Regexp.new("<#{tag}>(.+)</#{tag}>"), "<#{tag}>#{date}</#{tag}>")
        end

        connection = Faraday.new
        uri = URI.parse(url)

        response = connection.send(:put,uri) do |req|
          req.headers[:authorization] = auth_header(:put,uri)
          req.headers['Content-Type'] = 'application/xml'
          req.body = body
        end

        response
      end

      private

      def auth_header(method, uri)
        SimpleOAuth::Header.new(method.to_sym, uri, {}, @credentials).to_s
      end

      def fetch_entry_body(url)
        connection = Faraday.new
        uri = URI.parse(url)
        response = connection.send(:get, uri) do |req|
          req.headers[:authorization] = auth_header(:get,uri)
        end
        response.body
      end

      def fetch_page(uri)
        connection = Faraday.new
        response = connection.send(:get, uri) do |req|
          req.headers[:authorization] = auth_header(:get, uri)
        end

        doc = Nokogiri::XML(response.body)
        should_fetch_more = true

        doc.search("entry").each do |entry|
          should_fetch_more = process(entry)
        end

        return nil unless should_fetch_more

        return next_page(doc)
      end

      def process(entry)
        should_fetch_more = true

        if @draft.nil?
          required = true
        else
          entry_is_published = entry.at('app|draft').content == "no"
          required = @draft ? !entry_is_published : entry_is_published
        end
        
        if @range
          updated = DateTime.parse(entry.at('updated').content)
          if updated < @range.begin
            should_fetch_more = false
          end
          
          within_time = @range.cover?(updated)
          required &= within_time
        end

        if @limit and required and (@entries.count >= @limit)
          should_fetch_more = false
          required = false
        end

        if required
          @entries << Hatena::Blog::Entry.new(entry)
        end

        return should_fetch_more
      end

      def next_page(xml_doc)
        next_link = xml_doc.at('link[@rel="next"]')
        return nil unless next_link
        
        next_uri = next_link.attribute("href").value
        return URI.parse(next_uri)
      end
      
    end
  end
end
