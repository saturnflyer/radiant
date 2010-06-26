require File.dirname(__FILE__) + "/../spec_helper"

describe Radiant::AdminUI do
  before :each do
    @admin = Radiant::AdminUI.instance
  end
  
  it "should load the default extension regions" do
    ext = @admin.extensions
    ext.index.should_not be_nil
    ext.index.thead.should == %w{title_header website_header version_header}
    ext.index.tbody.should == %w{title_cell website_cell version_cell}
  end
end