require File.dirname(__FILE__) + '/../spec_helper'

describe MarkdownFilter do
  it "depends on the Markdown and SmartyPants processing libraries" do
    all_of('rubypants/rubypants', :bluecloth).should be_loadable
  end

  it "should be named Markdown" do
    MarkdownFilter.filter_name.should == "Markdown"
  end

  it "should transform text into paragraphs" do
    MarkdownFilter.filter('Just a paragraph.').should == '<p>Just a paragraph.</p>'
  end

  it "should transform double astericks or underscores into <strong> tags" do
    MarkdownFilter.filter('**strong** __strong__').should == '<p><strong>strong</strong> <strong>strong</strong></p>'
  end

  it "should transform single asktericks or underscores into <em> tags" do
    MarkdownFilter.filter('*emphasis* _emphasis_').should == '<p><em>emphasis</em> <em>emphasis</em></p>'
  end

  it "should transform straight quotes into curly quotes" do
    MarkdownFilter.filter("\"double quote\" \'single quote\' apostrophe\'s").should == "<p>&#8220;double quote&#8221; &#8216;single quote&#8217; apostrophe&#8217;s</p>"
  end

  # This test works fine in SmartyPants but a BlueCloth bug prevents it from working in Markdown.
  # it "should transform backtick quotes into curly quotes" do
  #   MarkdownFilter.filter("\`\`double quote\'\'").should == "<p>&#8220;double quote&#8221;</p>"
  # end

  it "should transform double dashes into en dashes" do
    MarkdownFilter.filter("an en -- dash").should == "<p>an en &#8211; dash</p>"
  end

  it "should transform triple dashes into em dashes" do
    MarkdownFilter.filter("an em --- dash").should == "<p>an em &#8212; dash</p>"
  end

  it "should transform three dots into ellipsis" do
    MarkdownFilter.filter("and so on... here we go again. . .").should == "<p>and so on&#8230; here we go again&#8230;</p>"
  end

  it "should not transform characters in <pre> blocks " do
    MarkdownFilter.filter("<pre>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</pre>").should == "<pre>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</pre>"
  end

  # This test works fine in SmartyPants but a BlueCloth bug prevents it from working in Markdown.
  # it "should not transform characters in <code> blocks " do
  #   MarkdownFilter.filter("<code>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</code>").should == "<code>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</code>"
  # end

  # This test works fine in SmartyPants but a BlueCloth bug prevents it from working in Markdown.
  # it "should not transform characters in <kbd> blocks " do
  #   MarkdownFilter.filter("<kbd>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</kbd>").should == "<kbd>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</kbd>"
  # end

  it "should not transform characters in <script> blocks " do
    MarkdownFilter.filter("<script>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</script>").should == "<script>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</script>"
  end
end