module StandardTags::FinderTags
  
  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end
  
  desc %{
    Renders the containing elements only if the page's url matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.

    *Usage:*
    
    <pre><code><r:if_url matches="regexp" [ignore_case="true|false"]>...</r:if_url></code></pre>
  }
  tag 'if_url' do |tag|
    raise TagError.new("`if_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    unless tag.locals.page.url.match(regexp).nil?
       tag.expand
    end
  end

  desc %{
    The opposite of the @if_url@ tag.

    *Usage:*
    
    <pre><code><r:unless_url matches="regexp" [ignore_case="true|false"]>...</r:unless_url></code></pre>
  }
  tag 'unless_url' do |tag|
    raise TagError.new("`unless_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    if tag.locals.page.url.match(regexp).nil?
        tag.expand
    end
  end
  
    desc %{
    Renders the contained elements if the current contextual page is either the actual page or one of its parents.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is or descends from the current page.

    *Usage:*
    
    <pre><code><r:if_ancestor_or_self>...</r:if_ancestor_or_self></code></pre>
  }
  tag "if_ancestor_or_self" do |tag|
    tag.expand if (tag.globals.page.ancestors + [tag.globals.page]).include?(tag.locals.page)
  end

  desc %{
    Renders the contained elements unless the current contextual page is either the actual page or one of its parents.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up unless the child element is or descends from the current page.

    *Usage:*
    
    <pre><code><r:unless_ancestor_or_self>...</r:unless_ancestor_or_self></code></pre>
  }
  tag "unless_ancestor_or_self" do |tag|
    tag.expand unless (tag.globals.page.ancestors + [tag.globals.page]).include?(tag.locals.page)
  end

  desc %{
    Renders the contained elements if the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is the current page.

    *Usage:*
    
    <pre><code><r:if_self>...</r:if_self></code></pre>
  }
  tag "if_self" do |tag|
    tag.expand if tag.locals.page == tag.globals.page
  end

  desc %{
    Renders the contained elements unless the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up unless the child element is the current page.

    *Usage:*

    <pre><code><r:unless_self>...</r:unless_self></code></pre>
  }
  tag "unless_self" do |tag|
    tag.expand unless tag.locals.page == tag.globals.page
  end
  
  desc %{
    Inside this tag all page related tags refer to the page found at the @url@ attribute.
    @url@s may be relative or absolute paths.

    *Usage:*

    <pre><code><r:find url="value_to_find">...</r:find></code></pre>
  }
  tag 'find' do |tag|
    url = tag.attr['url']
    raise TagError.new("`find' tag must contain `url' attribute") unless url

    found = Page.find_by_url(absolute_path_for(tag.locals.page.url, url))
    if page_found?(found)
      tag.locals.page = found
      tag.expand
    end
  end
  
  desc %{
    Renders the containing elements only if Radiant in is development mode.

    *Usage:*

    <pre><code><r:if_dev>...</r:if_dev></code></pre>
  }
  tag 'if_dev' do |tag|
    tag.expand if dev?(tag.globals.page.request)
  end

  desc %{
    The opposite of the @if_dev@ tag.

    *Usage:*

    <pre><code><r:unless_dev>...</r:unless_dev></code></pre>
  }
  tag 'unless_dev' do |tag|
    tag.expand unless dev?(tag.globals.page.request)
  end
end