require 'faraday'
require 'simple_oauth'

module Hatena
  module Blog
    class Client

      def initialize(consumer_key, consumer_secret, token, token_secret, user_name)
        @credentials = {
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: token,
          token_secret: token_secret
        }
        @user_name = user_name
      end

      def fetch_entries
        connection = Faraday.new
        uri = URI.parse("https://blog.hatena.ne.jp/#{@user_name}/#{@user_name}.hatenablog.com/atom/entry")
        
        entries = []
        while true
          response = connection.send(:get, uri) do |req|
            req.headers[:authorization] = auth_header(:get, uri)
          end

          doc = Nokogiri::XML(response.body)
          entries += doc.search("entry").select do |entry|
            entry.at('app|draft').content == "yes"
          end.map{|entry| Hatena::Blog::Entry.new(entry)}

          next_link = doc.at('link[@rel="next"]')
          break unless next_link
          
          next_uri = next_link.attribute("href").value
          uri = URI.parse(next_uri)
        end
        entries
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
