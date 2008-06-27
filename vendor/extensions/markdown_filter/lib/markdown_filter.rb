begin
  require 'rdiscount'
  YourCloth = RDiscount
  rescue LoadError
    require 'bluecloth'
    YourCloth = BlueCloth
  end
require 'rubypants/rubypants'

class MarkdownFilter < TextFilter
  description_file File.dirname(__FILE__) + "/../markdown.html"
  def filter(text)
    RubyPants.new(YourCloth.new(text).to_html).to_html
  end
end