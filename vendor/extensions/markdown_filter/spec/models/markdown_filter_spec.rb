require File.dirname(__FILE__) + '/../spec_helper'

describe MarkdownFilter do
  it "depends on the BlueCloth Markdown library" do
    'bluecloth'.should be_loadable
  end

  it "should be named Markdown" do
    MarkdownFilter.filter_name.should == "Markdown"
  end
  
  it "should filter text according to Markdown rules" do
    MarkdownFilter.filter('**strong**').should == /\<p\>\<strong\>strong\<\/strong\>\<\/p\>[\n]/
  end
end