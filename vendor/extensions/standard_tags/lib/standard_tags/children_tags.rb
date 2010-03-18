module StandardTags::ChildrenTags
  
  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end

  desc %{
    Gives access to a page's children.

    *Usage:*
    
    <pre><code><r:children>...</r:children></code></pre>
  }
  tag 'children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end

  desc %{
    Renders the total number of children.
  }
  tag 'children:count' do |tag|
    options = children_find_options(tag)
    options.delete(:order) # Order is irrelevant
    tag.locals.children.count(options)
  end

  desc %{
    Returns the first child. Inside this tag all page attribute tags are mapped to
    the first child. Takes the same ordering options as @<r:children:each>@.

    *Usage:*
    
    <pre><code><r:children:first>...</r:children:first></code></pre>
  }
  tag 'children:first' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if first = children.first
      tag.locals.page = first
      tag.expand
    end
  end

  desc %{
    Returns the last child. Inside this tag all page attribute tags are mapped to
    the last child. Takes the same ordering options as @<r:children:each>@.

    *Usage:*
    
    <pre><code><r:children:last>...</r:children:last></code></pre>
  }
  tag 'children:last' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if last = children.last
      tag.locals.page = last
      tag.expand
    end
  end

  desc %{
    Cycles through each of the children. Inside this tag all page attribute tags
    are mapped to the current child page.

    *Usage:*
    
    <pre><code><r:children:each [offset="number"] [limit="number"]
     [by="published_at|updated_at|created_at|slug|title|keywords|description"]
     [order="asc|desc"] [status="draft|reviewed|published|hidden|all"]>
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'children:each' do |tag|
    options = children_find_options(tag)
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    kids = children.find(:all, options)
    kids.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == kids.length - 1
      result << tag.expand
    end
    result
  end

  desc %{
    Page attribute tags inside of this tag refer to the current child. This is occasionally
    useful if you are inside of another tag (like &lt;r:find&gt;) and need to refer back to the
    current child.

    *Usage:*
    
    <pre><code><r:children:each>
      <r:child>...</r:child>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:child' do |tag|
    tag.locals.page = tag.locals.child
    tag.expand
  end
  
  desc %{
    Renders the tag contents only if the current page is the first child in the context of
    a children:each tag
    
    *Usage:*
    
    <pre><code><r:children:each>
      <r:if_first >
        ...
      </r:if_first>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end

  
  desc %{
    Renders the tag contents unless the current page is the first child in the context of
    a children:each tag
    
    *Usage:*
    
    <pre><code><r:children:each>
      <r:unless_first >
        ...
      </r:unless_first>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end
  
  desc %{
    Renders the tag contents only if the current page is the last child in the context of
    a children:each tag
    
    *Usage:*
    
    <pre><code><r:children:each>
      <r:if_last >
        ...
      </r:if_last>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end

  
  desc %{
    Renders the tag contents unless the current page is the last child in the context of
    a children:each tag
    
    *Usage:*
    
    <pre><code><r:children:each>
      <r:unless_last >
        ...
      </r:unless_last>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end
  
  desc %{
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.

    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.

    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.

    *Usage:*
    
    <pre><code><r:children:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"]>
        ...
      </r:header>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end
  
  desc %{
    Renders the contained elements only if the current contextual page has one or
    more child pages.  The @status@ attribute limits the status of found child pages
    to the given status, the default is @"published"@. @status="all"@ includes all
    non-virtual pages regardless of status.

    *Usage:*
    
    <pre><code><r:if_children [status="published"]>...</r:if_children></code></pre>
  }
  tag "if_children" do |tag|
    children = tag.locals.page.children.count(:conditions => children_find_options(tag)[:conditions])
    tag.expand if children > 0
  end

  desc %{
    Renders the contained elements only if the current contextual page has no children.
    The @status@ attribute limits the status of found child pages to the given status,
    the default is @"published"@. @status="all"@ includes all non-virtual pages
    regardless of status.

    *Usage:*
    
    <pre><code><r:unless_children [status="published"]>...</r:unless_children></code></pre>
  }
  tag "unless_children" do |tag|
    children = tag.locals.page.children.count(:conditions => children_find_options(tag)[:conditions])
    tag.expand unless children > 0
  end
  
end