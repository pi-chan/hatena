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

        connection = Faraday.new
        uri = URI.parse("https://blog.hatena.ne.jp/#{@hatena_id}/#{@blog_id}/atom/entry")
        
        entries = []
        total_count = 0
        
        while true
          response = connection.send(:get, uri) do |req|
            req.headers[:authorization] = auth_header(:get, uri)
          end

          doc = Nokogiri::XML(response.body)
          should_break_loop = false

          entries += doc.search("entry").select do |entry|
            if @draft.nil?
              required = true
            else
              entry_is_published = entry.at('app|draft').content == "no"
              required = @draft ? !entry_is_published : entry_is_published
            end
            
            if @range
              updated = DateTime.parse(entry.at('updated').content)
              if updated < @range.begin
                should_break_loop = true
              end
              
              within_time = @range.cover?(updated)
              required &= within_time
            end

            if @limit
              total_count += 1 if required
              if total_count > @limit
                should_break_loop = true
                required = false
              end
            end
            
            required 
          end.map{|entry| Hatena::Blog::Entry.new(entry)}

          break if should_break_loop

          next_link = doc.at('link[@rel="next"]')
          break unless next_link
          
          next_uri = next_link.attribute("href").value
          uri = URI.parse(next_uri)
        end

        return entries
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
      
    end  
  end
end
