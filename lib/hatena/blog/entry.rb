require 'nokogiri'

module Hatena
  module Blog
    class Entry
      attr_accessor :title, :id, :edit_link, :raw
      
      def initialize(xml)
        @id = xml.at("id").content
        @draft = xml.at("app|draft").content.downcase == "yes" ? true : false
        @edit_link = xml.at('link[@rel="edit"]').attribute("href").value
        @title = xml.at('title').content
        @raw = xml
      end

      def to_s
        [@id,@title,@edit_link].to_s
      end

      def draft?
        @draft
      end
      
    end
  end
end
