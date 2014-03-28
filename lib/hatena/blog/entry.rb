require 'xmlsimple'

module Hatena
  module Blog
    class Entry
      def initialize(xml)
        @__hash__ = XmlSimple.xml_in(xml, ContentKey:"__content__", KeepRoot:false, SuppressEmpty:true, KeyToSymbol:false, ForceArray:false, ForceContent:true)
      end

      def draft
        @__hash__["control"]["draft"]["__content__"] == "yes"
      end

      def draft=(value)
        @__hash__["control"]["draft"]["__content__"] = value ? "yes" : "no"
      end

      def author
        @__hash__["author"]["name"]["__content__"]
      end

      def author=(name)
        @__hash__["author"]["name"]["__content__"] = name
      end

      ["edit", "alternate"].each do |name|
        eval %Q{
          def link_#{name}
            elm = @__hash__["link"].select{|elm| elm["rel"] == "#{name}"}.first
            elm["href"]
          end

          def link_#{name}=(url)
            elm = @__hash__["link"].select{|elm| elm["rel"] == "#{name}"}.first
            elm["href"] = url
          end
        }
      end

      def method_missing(method_id, *args)
        if h = @__hash__[method_id.to_s]
          h["__content__"]
        else
          nil
        end
      end

      def to_xml
        XmlSimple.xml_out(@__hash__, :RootName => "entry", ContentKey:"__content__")
      end

    end
  end
end
