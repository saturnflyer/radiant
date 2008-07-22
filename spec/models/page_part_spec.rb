require File.dirname(__FILE__) + '/../spec_helper'

describe PagePart do
  scenario :pages
  test_helper :page_parts, :validations
  
  before :each do
    @part = @model = PagePart.new(PagePartTestHelper::VALID_PAGE_PART_PARAMS)
  end
  
  it 'should err with a name longer than 100 characters' do
    too_long_name = 'x' * 101
    @part.name = too_long_name
    @part.should have(1).error_on(:name)
  end
  
  it 'should err with a filter_id longer than 25 characters' do
    too_long_filter_id = 'x' * 26
    @part.filter_id = too_long_filter_id
    @part.should have(1).error_on(:filter_id)
  end
  
  it 'should not err with no filter_id' do
    @part.filter_id = nil
    lambda{ @part.save! }.should_not raise_error
  end
  
  it 'should err without a name' do
    @part.name = nil
    lambda {@part.save!}.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should err if page_id is not an integer' do
    @part.page_id = '1.3'
    @part.should have(1).error_on(:page_id)
  end
  
  it 'should err if id is not an integer' do
    @part.id = '1.3'
    @part.should have(1).error_on(:id)
  end
  
  it 'should save with no page_id' do
    @part.page_id = nil
    lambda {@part.save!}.should_not raise_error
  end
  
  it 'should save with no id' do
    @part.id = nil
    lambda {@part.save!}.should_not raise_error
  end

  it 'should find parts ordered by name' do
    pending "order_by seems to not be working..."
    @page = pages(:home)
    @page.parts.should == [@page.part('body'),@page.part('extended'),@page.part('sidebar'),@page.part('titles')]
  end
end

describe PagePart, 'filter' do
  scenario :markup_pages
  
  before(:each) do
    @part = page_parts(:textile_body)
  end
  
  it 'should have a TextileFilter with a filter_id of "Textile"' do
    @part.filter.should be_kind_of(TextileFilter)
  end
  
  it 'should have a MarkdownFilter with a filter_id of "Markdown"' do
    @part.filter_id = 'Markdown'
    @part.filter.should be_kind_of(MarkdownFilter)
  end
  
  it 'should have a SmartyPantsFilter with a filter_id of "SmartyPants"' do
    @part.filter_id = 'SmartyPants'
    @part.filter.should be_kind_of(SmartyPantsFilter)
  end
end
