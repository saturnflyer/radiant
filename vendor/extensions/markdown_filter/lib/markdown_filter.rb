begin
  gem 'rdiscount', '>= 1.2.6'
  require 'rdiscount'
  Markdown = RDiscount
  class MarkdownFilter < TextFilter
    description_file File.dirname(__FILE__) + "/../markdown.html"
    def filter(text)
      Markdown.new(text, :smart).to_html
    end
  end
  rescue LoadError
    require 'bluecloth'
    require 'rubypants/rubypants'
    Markdown = BlueCloth
    class MarkdownFilter < TextFilter
      description_file File.dirname(__FILE__) + "/../markdown.html"
      def filter(text)
        RubyPants.new(Markdown.new(text).to_html).to_html
      end
    end
  end