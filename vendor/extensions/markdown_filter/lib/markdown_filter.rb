begin
  gem 'rdiscount', '>= 1.2.6'
  require 'rdiscount'
  Markdown = RDiscount
  rescue LoadError
    require 'bluecloth'
    Markdown = BlueCloth
  end
require 'rubypants/rubypants'

class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    RubyPants.new(Markdown.new(text).to_html).to_html
  end
end