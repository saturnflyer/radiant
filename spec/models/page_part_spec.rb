require File.dirname(__FILE__) + '/../spec_helper'

describe PagePart do
  test_helper :page_parts, :validations
  
  before :each do
    @part = @model = PagePart.new(PagePartTestHelper::VALID_PAGE_PART_PARAMS)
  end
  
  it 'should not save with a name longer than 100 characters' do
    too_long_name = 'x' * 101
    @part.name = too_long_name
    lambda {
      @part.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should not save with a filter_id longer than 25 characters' do
    too_long_filter_id = 'x' * 26
    @part.filter_id = too_long_filter_id
    lambda {
      @part.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should save with no filter_id' do
    @part.filter_id = nil
    lambda{ @part.save! }.should_not raise_error
  end
  
  it 'should not save without a name' do
    @part.name = nil
    lambda {
      @part.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should not save if page_id is not an integer' do
    @part.page_id = '1.3'
    lambda {
      @part.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should not save if id is not an integer' do
    @part.id = '1.3'
    lambda {
      @part.save!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'should save with no page_id' do
    @part.page_id = nil
    lambda {@part.save!}.should_not raise_error
  end
  
  it 'should save with no id' do
    @part.id = nil
    lambda {@part.save!}.should_not raise_error
  end

  it 'should find parts ordered by name'
end

describe PagePart, 'filter' do
  scenario :markup_pages
  
  specify 'getting and setting' do
    @part = page_parts(:textile_body)
    original = @part.filter
    original.should be_kind_of(TextileFilter)
    
    @part.filter.should equal(original)
    
    @part.filter_id = 'Markdown'
    @part.filter.should be_kind_of(MarkdownFilter)
  end
end
