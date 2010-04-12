require 'spec_helper'

describe "User Tags" do
  dataset :users_and_pages

  describe "<r:author>" do
    it "should render the author of the current page" do
      pages(:home).should render('<r:author />').as('Admin')
    end

    it "should render nothing when the page has no author" do
      pages(:no_user).should render('<r:author />').as('')
    end
  end

  describe "<r:gravatar>" do
    it "should render the Gravatar URL of author of the current page" do
      pages(:home).should render('<r:gravatar />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=G&size=32')
    end

    it "should render the Gravatar URL of the name user" do
      pages(:home).should render('<r:gravatar name="Admin" />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=G&size=32')
    end

    it "should render the default avatar when the user has not set an email address" do
      pages(:home).should render('<r:gravatar name="Designer" />').as('http://testhost.tld/images/admin/avatar_32x32.png')
    end

    it "should render the specified size" do
      pages(:home).should render('<r:gravatar name="Designer" size="96px" />').as('http://testhost.tld/images/admin/avatar_96x96.png')
    end

    it "should render the specified rating" do
      pages(:home).should render('<r:gravatar rating="X" />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=X&size=32')
    end
  end
    
end