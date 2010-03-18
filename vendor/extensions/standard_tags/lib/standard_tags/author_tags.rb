module StandardTags::AuthorTags
  
  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end
  
  desc %{
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end
end