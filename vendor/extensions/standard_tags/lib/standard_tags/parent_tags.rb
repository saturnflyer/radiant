module StandardTags::ParentTags
  
  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end
  
  desc %{
    Page attribute tags inside this tag refer to the parent of the current page.

    *Usage:*
    
    <pre><code><r:parent>...</r:parent></code></pre>
  }
  tag "parent" do |tag|
    parent = tag.locals.page.parent
    tag.locals.page = parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has a parent, i.e.
    is not the root page.

    *Usage:*
    
    <pre><code><r:if_parent>...</r:if_parent></code></pre>
  }
  tag "if_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has no parent, i.e.
    is the root page.

    *Usage:*
    
    <pre><code><r:unless_parent>...</r:unless_parent></code></pre>
  }
  tag "unless_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand unless parent
  end
  
end