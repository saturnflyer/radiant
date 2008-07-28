require File.dirname(__FILE__) + '/../spec_helper'

class PageSpecTestPage < Page
  description 'this is just a test page'
  
  def headers
    {
      'cool' => 'beans',
      'request' => @request.inspect[20..30],
      'response' => @response.inspect[20..31]
    }
  end
  
  tag 'test1' do
    'Hello world!'
  end
  
  tag 'test2' do
    'Another test.'
  end
end

describe Page, 'validations' do
  scenario :pages
  test_helper :validations
  
  before :each do
    @page = @model = Page.new(page_params)
  end
  
  it 'should err with "255-character limit" when given a title longer than 255 characters' do
    too_long_title = 'x' * 256
    @page.title = too_long_title
    @page.valid?
    @page.errors.on(:title).should include('255-character limit')
  end
  
  it 'should err with "100-character limit" when given a slug longer than 100 characters' do
    too_long_slug = 'x' * 101
    @page.slug = too_long_slug
    @page.valid?
    @page.errors.on(:slug).should include('100-character limit')
  end
  
  it 'should err with "160-character limit" when given a breadcrumb longer than 160 characters' do
    too_long_breadcrumb = 'x' * 161
    @page.breadcrumb = too_long_breadcrumb
    @page.valid?
    @page.errors.on(:breadcrumb).should include('160-character limit')
  end
  
  it 'should err that title is "required" when given no title' do
    @page.title = nil
    @page.valid?
    @page.errors.on(:title).should include('required')
  end
  
  it 'should err that slug is "required" when given no slug' do
    @page.slug = nil
    @page.valid?
    @page.errors.on(:slug).should include('required')
  end
  
  it 'should err that breadcrumb is "required" when given no breadcrumb' do
    @page.breadcrumb = nil
    @page.valid?
    @page.errors.on(:breadcrumb).should include('required')
  end
  
  it 'should err that status_id is "required" when given no status_id' do
    @page.status_id = nil
    @page.valid?
    @page.errors.on(:status_id).should include('required')
  end
  
  it 'should err with "invalid format" with a slug containing one or more spaces' do
    @page.slug = 'invalid slug'
    @page.valid?
    @page.errors.on(:slug).should include('invalid format')
  end
  
  it 'should err with "invalid format" with a slug containing one or more slashes' do
    @page.slug = 'invalid/slug'
    @page.valid?
    @page.errors.on(:slug).should include('invalid format')
  end
  
  it 'should err that id "must be a number" when given a non integer id' do
    @page.id = 'a'
    @page.valid?
    @page.errors.on(:id).should include('must be a number')
  end
  
  it 'should err that status_id "must be a number" when given a non integer status_id' do
    @page.status_id = '2,4'
    @page.valid?
    @page.errors.on(:status_id).should include('must be a number')
  end
  
  it 'should err that parent_id "must be a number" when given a non integer parent_id' do
    @page.parent_id = '1.3'
    @page.valid?
    @page.errors.on(:parent_id).should include('must be a number')
  end
  
  it 'should err that "slug already in use for child of parent" when given a slug already in use by a child of the same parent page' do
    @page.parent = pages(:parent)
    @page.slug = 'child'
    @page.valid?
    @page.errors.on(:slug).should include('slug already in use for child of parent')
  end
  
  it 'should allow a duplicate slug when pages do not have the same parent' do
    @page.parent = pages(:parent)
    @page2 = @model2 = Page.new(page_params)
    @page2.slug = 'notoriginal'
    @page.slug = 'notoriginal'
    @page.should be_valid
  end
  
  it 'should allow assignment of class name' do
    @page.attributes = { :class_name => 'ArchivePage' }
    @page.should be_valid
  end
  
  it 'should err with "must be set to a valid descendant of Page" when the given class name is not a descendant of page' do
    @page.class_name = 'Object'
    @page.valid?
    @page.errors.on(:class_name).should include('must be set to a valid descendant of Page')
  end

  it 'should err with "must be set to a valid descendant of Page" when the given class name is not a descendant of page and it is set through mass assignment' do
    @page.attributes = {:class_name => 'Object' }
    @page.valid?
    @page.errors.on(:class_name).should include('must be set to a valid descendant of Page')
  end
    
  it 'should save successfully with a class name of "Page"' do
    @page = ArchivePage.new(page_params)
    @page.class_name = 'Page'
    lambda{@page.save!}.should_not raise_error
  end
  
  it 'should have a class name of "Page" after saving with a class name of "Page"' do
    @page = ArchivePage.new(page_params)
    @page.class_name = 'Page'
    @page.save
    @page.class_name.should == 'Page'
  end
    
  it 'should save successfully with a class name of ""' do
    @page = ArchivePage.new(page_params)
    @page.class_name = ''
    lambda{@page.save!}.should_not raise_error
  end
  
  it 'should have a class name of "" after saving with a class name of ""' do
    @page = ArchivePage.new(page_params)
    @page.class_name = ''
    @page.save
    @page.class_name.should == ''
  end
    
  it 'should save successfully with a nil class name' do
    @page = ArchivePage.new(page_params)
    @page.class_name = nil
    lambda{@page.save!}.should_not raise_error
  end
  
  it 'should have a nil class name after saving with a nil class name' do
    @page = ArchivePage.new(page_params)
    @page.class_name = nil
    @page.save
    @page.class_name.should be_nil
  end
end

describe Page, "behaviors" do
  it 'should include StandardTags' do
    Page.included_modules.should include(StandardTags)
  end
  it 'should include Annotatable' do
    Page.included_modules.should include(Annotatable)
  end
end

describe Page, "layout" do
  scenario :pages_with_layouts
  
  describe "with no layout assigned" do
    it "should return the name of the layout for its ancestor when requesting its layout name" do
      @page = pages(:first)
      @page.layout.name.should == "Main"
    end
    
    it "should return the layout_id of the layout for its ancestor when requesting its layout_id" do
      @page = pages(:first)
      @page.layout_id.should == layout_id(:main)
    end
    
    it "should have the layout of its ancestor" do
      @page = pages(:inherited_layout)
      @page.layout.should == @page.parent.layout
    end
  end
end

describe Page do
  scenario :pages
  
  before :each do
    @page = pages(:first)
  end
  
  it 'should have parts' do
    @new_page = Page.new(page_params)
    @new_page.should respond_to(:parts)
  end
  
  it 'should destroy dependant parts when destroyed' do
    @page.parts.create(page_part_params(:name => 'test', :page_id => nil))
    id = @page.id
    @page.destroy
    PagePart.find_by_page_id(id).should be_nil
  end
  
  it 'should allow access to a part by name with a string' do
    part = @page.part('body')
    part.name.should == 'body'
  end
  
  it 'should allow access to a part by name with a symbol' do
    part = @page.part(:body)
    part.name.should == 'body'
  end
  
  it 'should allow access to a part by name with a string when the page is unsaved' do
    part = PagePart.new(:content => "test", :name => "test")
    @page.parts << part
    @page.part('test').should == part
  end
  
  it 'should allow access to a part by name with a symbol when the page is unsaved' do
    part = PagePart.new(:content => "test", :name => "test")
    @page.parts << part
    @page.part(:test).should == part
  end
  
  it 'should allow access to parts by name with a string when created with the build method and the page is unsaved' do
    @page.parts.build(:content => "test", :name => "test")
    @page.part('test').content.should == "test"
  end
  
  it 'should allow access to parts by name with a symbol when created with the build method and the page is unsaved' do
    @page.parts.build(:content => "test", :name => "test")
    @page.part(:test).content.should == "test"
  end
  
  it 'should set published_at when published' do
    @page = Page.new(page_params(:status_id => '1', :published_at => nil))
    
    @page.status_id = Status[:published].id
    @page.save
    @page.published_at.strftime("%Y %m %d %H %M").should == Time.now.strftime("%Y %m %d %H %M")
    # if you find an error here, run your specs again. Time sensitive comparisons that occor at the change of a minute may fail
  end 
  
  it 'should not update published_at when already published' do
    @page = Page.new(page_params(:status_id => Status[:published].id))
    
    expected = @page.published_at
    @page.save
    @page.published_at.should == expected
  end
  
  it 'should have a Time object for published_at' do
    @page.published_at.should be_kind_of(Time) 
  end
  
  it 'should answer true when published' do
    @page.status = Status[:published]
    @page.published?.should be_true
  end
  
  it 'should answer false when not published' do
    @page.status = Status[:draft]
    @page.published?.should be_false
  end
  
  it "should return a slash delimited string of slugs from the page and it's ancestors when requesting the page's url" do
    @page = pages(:parent)
    @page.children.first.url.should == '/parent/child/'
  end
  
  it "should allow you to calculate it's child's url" do
    @page = pages(:parent)
    @page.child_url(@page.children.first).should == '/parent/child/'
  end
  
  it 'should return the appropriate status code in headers' do
    @page.headers.should == { 'Status' => ActionController::Base::DEFAULT_RENDER_STATUS_CODE }
  end
  
  it 'should have status_id of 1 when draft' do
    @page = pages(:home)
    @page.status = Status[:draft]
    @page.status_id.should == 1
  end
  
  it 'should have status_id of 50 when reviewed' do
    @page = pages(:home)
    @page.status = Status[:reviewed]
    @page.status_id.should == 50
  end
  
  it 'should have status_id of 100 when published' do
    @page = pages(:home)
    @page.status_id.should == 100
  end
  
  it 'should have status_id of 101 when hidden' do
    @page = pages(:home)
    @page.status = Status[:hidden]
    @page.status_id.should == 101
  end
  
  it 'should allow you to set the status' do
    @page = pages(:home)
    draft = Status[:draft]
    @page.status = draft
    @page.status_id.should == draft.id
  end
  
  it 'should respond to cache? with true (by default)' do
    @page.cache?.should == true
  end
  
  it 'should respond to virtual? with false (by default)' do
    @page.virtual?.should == false
  end
  
  it 'should state that it has a part based on a string' do
    @page = pages(:home)
    @page.has_part?('sidebar').should be_true
  end
  
  it 'should state that it has a part based on a symbol' do
    @page = pages(:home)
    @page.has_part?(:body).should be_true
  end
  
  it 'should state that it does not have a part based on a string' do
    @page = pages(:home)
    @page.has_part?('imaginary').should_not be_true
  end
  
  it 'should state that it does not have a part based on a symbol' do
    @page = pages(:home)
    @page.has_part?(:madeup).should_not be_true
  end
  
  it 'should state that it inherits an existing part from the parent when it does not have the specified part' do
    @page = pages(:child)
    @page.inherits_part?(:sidebar).should be_true
  end
  
  it 'should state that it does not inherit a part from the parent when it has the specified part' do
    @page = pages(:home)
    @page.inherits_part?(:sidebar).should_not be_true
  end
  
  it 'should state that it has or inherits an existing part' do
    @page = pages(:child)
    @page.has_or_inherits_part?(:sidebar).should == true
  end
  
  it 'should state that it does not have or inherit a non-existant part' do
    @page = pages(:child)
    @page.has_or_inherits_part?(:obviously_false_part_name).should == false
  end
  
  it 'should support optimistic locking' do
    p1, p2 = pages(:first), pages(:first)
    p1.save!
    lambda { p2.save! }.should raise_error(ActiveRecord::StaleObjectError) 
  end
end

describe Page, "before save filter" do
  scenario :home_page
  
  before :each do
    Page.create(page_params(:title =>"Month Index", :class_name => "ArchiveMonthIndexPage"))
    @page = Page.find_by_title("Month Index")
  end
  
  it 'should set the class name correctly' do
    @page.should be_kind_of(ArchiveMonthIndexPage)
  end
  
  it 'should set the virtual bit correctly' do
    @page.virtual?.should == true
    @page.virtual.should == true
  end
  
  it 'should update virtual based on new class name' do
    # turn a regular page into a virtual page
    @page.class_name = "ArchiveMonthIndexPage"
    @page.save.should == true
    @page.virtual?.should == true
    @page.send(:read_attribute, :virtual).should == true
    
   # turn a virtual page into a non-virtual one
   ["", nil, "Page", "EnvDumpPage"].each do |value|
      @page = ArchiveYearIndexPage.create(page_params)
      @page.class_name = value
      @page.save.should == true
      @page = Page.find @page.id
      @page.should be_instance_of(Page.descendant_class(value))
      @page.virtual?.should == false
      @page.send(:read_attribute, :virtual).should == false
    end
  end
end

describe Page, "rendering" do
  scenario :pages, :markup_pages, :snippets, :layouts
  test_helper :render
  
  before :each do
    @page = pages(:home)
  end
  
  it 'should render' do
    @page.render.should == 'Hello world!'
  end
  
  it 'should render with a filter' do
    pages(:textile).render.should == '<p>Some <strong>Textile</strong> content.</p>'
  end
  
  it 'should render with tags' do
    pages(:radius).render.should == "Radius body."
  end
  
  it 'should render with a layout' do
    @page.update_attribute(:layout_id, layout_id(:main))
    @page.render.should == "<html>\n  <head>\n    <title>Home</title>\n  </head>\n  <body>\n    Hello world!\n  </body>\n</html>\n"
  end
  
  it 'should render a part' do
    @page.render_part(:body).should == "Hello world!"
  end
  
  it "should render blank when given a non-existent part" do
    @page.render_part(:empty).should == ''
  end
  
  it 'should render a snippet' do
    assert_snippet_renders :first, 'test'
  end
  
  it 'should render a snippet with a filter' do
    assert_snippet_renders :markdown, '<p><strong>markdown</strong></p>'
  end
  
  it 'should render a snippet with a tag' do
    assert_snippet_renders :radius, 'Home'
  end
  
  it 'should render custom pages with tags' do
    create_page "Test Page", :body => "<r:test1 /> <r:test2 />", :class_name => "PageSpecTestPage"
    pages(:test_page).should render_as('Hello world! Another test. body.')
  end
end

describe Page, "#find_by_url" do
  scenario :pages, :file_not_found
  
  before :each do
    @page = pages(:home)
  end
  
  it 'should allow you to find the home page' do
    @page.find_by_url('/') .should == @page
  end
  
  it 'should allow you to find deeply nested pages' do
    @page.find_by_url('/parent/child/grandchild/great-grandchild/').should == pages(:great_grandchild)
  end
  
  it 'should not allow you to find virtual pages' do
    @page.find_by_url('/virtual/').should == pages(:file_not_found)
  end
  
  it 'should find the FileNotFoundPage when a page does not exist' do
    @page.find_by_url('/nothing-doing/').should == pages(:file_not_found)
  end

  it 'should find a draft FileNotFoundPage in dev mode' do
    @page.find_by_url('/drafts/no-page-here', false).should == pages(:lonely_draft_file_not_found)
  end

  it 'should not find a draft FileNotFoundPage in live mode' do
    @page.find_by_url('/drafts/no-page-here').should_not == pages(:lonely_draft_file_not_found)
  end

  it 'should find a custom file not found page' do
    @page.find_by_url('/gallery/nothing-doing/').should == pages(:no_picture)
  end
  
  it 'should not find draft pages in live mode' do
    @page.find_by_url('/draft/').should == pages(:file_not_found)
  end
  
  it 'should find draft pages in dev mode' do
    @page.find_by_url('/draft/', false).should == pages(:draft)
  end
end

describe Page, "class" do
  it 'should have a description' do
    PageSpecTestPage.description.should == 'this is just a test page'
  end
  
  it 'should have a display name' do
    Page.display_name.should == "Page"
    
    PageSpecTestPage.display_name.should == "Page Spec Test"
    
    PageSpecTestPage.display_name = "New Name"
    PageSpecTestPage.display_name.should == "New Name"
    
    FileNotFoundPage.display_name.should == "File Not Found"
  end
  
  it 'should list decendants' do
    descendants = Page.descendants
    assert_kind_of Array, descendants
    assert_match /PageSpecTestPage/, descendants.inspect
  end
  
  it 'should allow initialization with empty defaults' do
    @page = Page.new_with_defaults({})
    @page.parts.size.should == 0
  end
  
  it 'should allow initialization with default page parts' do
    @page = Page.new_with_defaults({ 'defaults.page.parts' => 'a, b, c'})
    @page.parts.size.should == 3
    @page.parts.first.name.should == 'a'
    @page.parts.last.name.should == 'c'
  end
  
  it 'should allow initialization with default page status' do
    @page = Page.new_with_defaults({ 'defaults.page.status' => 'published' })
    @page.status.should == Status[:published]
  end
  
  it 'should allow initialization with default filter' do
    @page = Page.new_with_defaults({ 'defaults.page.filter' => 'Textile', 'defaults.page.parts' => 'a, b, c' })
    @page.parts.each do |part|
      part.filter_id.should == 'Textile'
    end
  end
  
  it 'should allow you to get the class name of a descendant class with a string' do
    ["", nil, "Page"].each do |value|
      Page.descendant_class(value).should == Page
    end
    Page.descendant_class("PageSpecTestPage").should == PageSpecTestPage
  end
  
  it 'should allow you to determine if a string is a valid descendant class name' do
    ["", nil, "Page", "PageSpecTestPage"].each do |value|
      Page.is_descendant_class_name?(value).should == true
    end
    Page.is_descendant_class_name?("InvalidPage").should == false
  end
  
end

describe Page, "loading subclasses before bootstrap" do
  before :each do
    Page.connection.should_receive(:tables).and_return([])
  end
  
  it "should not attempt to search for missing subclasses" do
    Page.connection.should_not_receive(:select_values).with("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL")
    Page.load_subclasses
  end
end

describe Page, 'loading subclasses after bootstrap' do
  it "should find subclasses in extensions" do
    defined?(ArchivePage).should_not be_nil
  end
  
  it "should not adjust the display name of subclasses found in extensions" do
    ArchivePage.display_name.should_not match(/not installed/)
  end
end

describe Page, "class which is applied to a page but not defined" do
  scenario :pages

  before :each do
    eval(%Q{class ClassNotDefinedPage < Page; def self.missing?; false end end}, TOPLEVEL_BINDING)    
    create_page "Class Not Defined", :class_name => "ClassNotDefinedPage"
    Object.send(:remove_const, :ClassNotDefinedPage)
    Page.load_subclasses
  end

  it 'should be created dynamically as a new subclass of Page' do
    Object.const_defined?("ClassNotDefinedPage").should == true
  end

  it 'should indicate that it wasn\'t defined' do
    ClassNotDefinedPage.missing?.should == true
  end
  
  it "should adjust the display name to indicate that the page type is not installed" do
    ClassNotDefinedPage.display_name.should match(/not installed/)
  end
end

describe Page, "class find_by_url" do
  scenario :pages, :file_not_found
  
  it 'should find the home page' do
    Page.find_by_url('/').should == pages(:home)
  end
  
  it 'should find children' do
    Page.find_by_url('/parent/child/').should == pages(:child)
  end
  
  it 'should not find draft pages in live mode' do
    Page.find_by_url('/draft/').should == pages(:file_not_found)
    Page.find_by_url('/draft/', false).should == pages(:draft)
  end
  
  it 'should raise an exception when root page is missing' do
    pages(:home).destroy
    Page.find_by_parent_id().should be_nil
    lambda { Page.find_by_url "/" }.should raise_error(Page::MissingRootPageError, 'Database missing root page')
  end
end

describe Page, "processing" do
  scenario :pages_with_layouts
  
  before :all do
    @request = ActionController::TestRequest.new :url => '/page/'
    @response = ActionController::TestResponse.new
  end
  
  it 'should set response body' do
    @page = pages(:home)
    @page.process(@request, @response)
    @response.body.should match(/Hello world!/)
  end

  it 'should set headers and pass request and response' do
    create_page "Test Page", :class_name => "PageSpecTestPage"
    @page = pages(:test_page)
    @page.process(@request, @response)
    @response.headers['cool'].should == 'beans'
    @response.headers['request'].should == 'TestRequest'
    @response.headers['response'].should == 'TestResponse'
  end
  
  it 'should set content type based on layout' do
    @page = pages(:utf8)
    @page.process(@request, @response)
    assert_response :success
    @response.headers['Content-Type'].should == 'text/html;charset=utf8'
  end
end
