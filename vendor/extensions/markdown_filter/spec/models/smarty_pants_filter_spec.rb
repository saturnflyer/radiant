require File.dirname(__FILE__) + '/../spec_helper'

describe SmartyPantsFilter do
  it "depends on the RubyPants library" do
    'rubypants/rubypants'.should be_loadable
  end

  it "should be named SmartyPants" do
    SmartyPantsFilter.filter_name.should == "SmartyPants"
  end
  
  it "should transform straight quotes into curly quotes" do
    SmartyPantsFilter.filter("\"double quote\" \'single quote\' apostrophe\'s").should == "&#8220;double quote&#8221; &#8216;single quote&#8217; apostrophe&#8217;s"
  end

  it "should transform backtick quotes into curly quotes" do
    SmartyPantsFilter.filter("\`\`double quote\'\'").should == "&#8220;double quote&#8221;"
  end

  it "should transform plain dashes into fancy dashes" do
    SmartyPantsFilter.filter("an en -- dash followed by an em --- dash").should == "an en &#8211; dash followed by an em &#8212; dash"
  end

  it "should transform three dots into ellipsis" do
    SmartyPantsFilter.filter("and so on... here we go again. . .").should == "and so on&#8230; here we go again&#8230;"
  end

  it "should not transform characters in <pre> blocks " do
    SmartyPantsFilter.filter("<pre>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</pre>").should == "<pre>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</pre>"
  end

  it "should not transform characters in <code> blocks " do
    SmartyPantsFilter.filter("<code>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</code>").should == "<code>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</code>"
  end

  it "should not transform characters in <kbd> blocks " do
    SmartyPantsFilter.filter("<kbd>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</kbd>").should == "<kbd>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</kbd>"
  end

  it "should not transform characters in <script> blocks " do
    SmartyPantsFilter.filter("<script>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</script>").should == "<script>\"double quote\" \'single quote\' apostrophe\'s \`\`double quote\'\' an en -- dash followed by an em --- dash and so on... here we go again. . .</script>"
  end
end