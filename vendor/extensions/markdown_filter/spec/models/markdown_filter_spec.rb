require File.dirname(__FILE__) + '/../spec_helper'

describe MarkdownFilter do
  it "depends on a Markdown processing library" do
    either_of(:rdiscount, :bluecloth).should be_loadable
  end

  it "should be named Markdown" do
    MarkdownFilter.filter_name.should == "Markdown"
  end
  
  it "should filter text according to Markdown rules" do
    MarkdownFilter.filter('**strong**').should == /\<p\>\<strong\>strong\<\/strong\>\<\/p\>[\n]/
  end
  
  it "should filter text with quotes into smart quotes" do
    MarkdownFilter.filter("# Radiant's \"filters\" rock!").should == "<h1>Radiant&#8217;s &#8220;filters&#8221; rock!</h1>"
  end
end