module StandardTags::ContentTags

  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end
  
  desc %{
    Randomly renders one of the options specified by the @option@ tags.

    *Usage:*

    <pre><code><r:random>
      <r:option>...</r:option>
      <r:option>...</r:option>
      ...
    <r:random>
    </code></pre>
  }
  tag 'random' do |tag|
    tag.locals.random = []
    tag.expand
    options = tag.locals.random
    option = options[rand(options.size)]
    option if option
  end
  tag 'random:option' do |tag|
    items = tag.locals.random
    items << tag.expand
  end

  desc %{
    Nothing inside a set of comment tags is rendered.

    *Usage:*

    <pre><code><r:comment>...</r:comment></code></pre>
  }
  tag 'comment' do |tag|
  end

  desc %{
    Escapes angle brackets, etc. for rendering in an HTML document.

    *Usage:*

    <pre><code><r:escape_html>...</r:escape_html></code></pre>
  }
  tag "escape_html" do |tag|
    CGI.escapeHTML(tag.expand)
  end

  desc %{
    Outputs the published date using the format mandated by RFC 1123. (Ideal for RSS feeds.)

    *Usage:*

    <pre><code><r:rfc1123_date /></code></pre>
  }
  tag "rfc1123_date" do |tag|
    page = tag.locals.page
    if date = page.published_at || page.created_at
      CGI.rfc1123_date(date.to_time)
    end
  end

  desc %{
    Renders a list of links specified in the @urls@ attribute according to three
    states:

    * @normal@ specifies the normal state for the link
    * @here@ specifies the state of the link when the url matches the current
       page's URL
    * @selected@ specifies the state of the link when the current page matches
       is a child of the specified url
    # @if_last@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the last in the navigation elements
    # @if_first@ renders its contents within a @normal@, @here@ or
      @selected@ tag if the item is the first in the navigation elements

    The @between@ tag specifies what should be inserted in between each of the links.

    *Usage:*

    <pre><code><r:navigation urls="[Title: url | Title: url | ...]">
      <r:normal><a href="<r:url />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:url />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    </code></pre>
  }
  tag 'navigation' do |tag|
    hash = tag.locals.navigation = {}
    tag.expand
    raise TagError.new("`navigation' tag must include a `normal' tag") unless hash.has_key? :normal
    result = []
    pairs = tag.attr['urls'].to_s.split('|').map do |pair|
      parts = pair.split(':')
      value = parts.pop
      key = parts.join(':')
      [key.strip, value.strip]
    end
    pairs.each_with_index do |(title, url), i|
      compare_url = remove_trailing_slash(url)
      page_url = remove_trailing_slash(self.url)
      hash[:title] = title
      hash[:url] = url
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == pairs.length - 1
      case page_url
      when compare_url
        result << (hash[:here] || hash[:selected] || hash[:normal]).call
      when Regexp.compile( '^' + Regexp.quote(url))
        result << (hash[:selected] || hash[:normal]).call
      else
        result << hash[:normal].call
      end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.reject { |i| i.blank? }.join(between)
  end
  [:normal, :here, :selected, :between].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol] = tag.block
    end
  end
  [:title, :url].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol]
    end
  end

  desc %{
    Renders the containing elements if the element is the first
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:if_first>...</r:if_first></r:normal></code></pre>
  }
  tag 'navigation:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end

  desc %{
    Renders the containing elements unless the element is the first
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:unless_first>...</r:unless_first></r:normal></code></pre>
  }
  tag 'navigation:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end

  desc %{
    Renders the containing elements unless the element is the last
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:unless_last>...</r:unless_last></r:normal></code></pre>
  }
  tag 'navigation:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end

  desc %{
    Renders the containing elements if the element is the last
    in the navigation list

    *Usage:*

    <pre><code><r:normal><r:if_last>...</r:if_last></r:normal></code></pre>
  }
  tag 'navigation:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end
  
    desc %{
    Renders one of the passed values based on a global cycle counter.  Use the @reset@
    attribute to reset the cycle to the beginning.  Use the @name@ attribute to track
    multiple cycles; the default is @cycle@.

    *Usage:*
    
    <pre><code><r:cycle values="first, second, third" [reset="true|false"] [name="cycle"] /></code></pre>
  }
  tag 'cycle' do |tag|
    raise TagError, "`cycle' tag must contain a `values' attribute." unless tag.attr['values']
    cycle = (tag.globals.cycle ||= {})
    values = tag.attr['values'].split(",").collect(&:strip)
    cycle_name = tag.attr['name'] || 'cycle'
    current_index = (cycle[cycle_name] ||=  0)
    current_index = 0 if tag.attr['reset'] == 'true'
    cycle[cycle_name] = (current_index + 1) % values.size
    values[current_index]
  end



  desc %{
    Renders the date based on the current page (by default when it was published or created).
    The format attribute uses the same formating codes used by the Ruby @strftime@ function. By
    default it's set to @%A, %B %d, %Y@.  The @for@ attribute selects which date to render.  Valid
    options are @published_at@, @created_at@, @updated_at@, and @now@. @now@ will render the
    current date/time, regardless of the  page.

    *Usage:*

    <pre><code><r:date [format="%A, %B %d, %Y"] [for="published_at"]/></code></pre>
  }
  tag 'date' do |tag|
    page = tag.locals.page
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    time_attr = tag.attr['for']
    date = if time_attr
      case
      when time_attr == 'now'
        Time.now
      when ['published_at', 'created_at', 'updated_at'].include?(time_attr)
        page[time_attr]
      else
        raise TagError, "Invalid value for 'for' attribute."
      end
    else
      page.published_at || page.created_at
    end
    date.strftime(format)
  end

  desc %{
    Renders a link to the page. When used as a single tag it uses the page's title
    for the link name. When used as a double tag the part in between both tags will
    be used as the link text. The link tag passes all attributes over to the HTML
    @a@ tag. This is very useful for passing attributes like the @class@ attribute
    or @id@ attribute. If the @anchor@ attribute is passed to the tag it will
    append a pound sign (<code>#</code>) followed by the value of the attribute to
    the @href@ attribute of the HTML @a@ tag--effectively making an HTML anchor.

    *Usage:*

    <pre><code><r:link [anchor="name"] [other attributes...] /></code></pre>
    
    or
    
    <pre><code><r:link [anchor="name"] [other attributes...]>link text here</r:link></code></pre>
  }
  tag 'link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    %{<a href="#{tag.render('url')}#{anchor}"#{attributes}>#{text}</a>}
  end

  desc %{
    Renders a trail of breadcrumbs to the current page. The separator attribute
    specifies the HTML fragment that is inserted between each of the breadcrumbs. By
    default it is set to @>@. The boolean nolinks attribute can be specified to render
    breadcrumbs in plain text, without any links (useful when generating title tag).

    *Usage:*

    <pre><code><r:breadcrumbs [separator="separator_string"] [nolinks="true"] /></code></pre>
  }
  tag 'breadcrumbs' do |tag|
    page = tag.locals.page
    breadcrumbs = [page.breadcrumb]
    nolinks = (tag.attr['nolinks'] == 'true')
    page.ancestors.each do |ancestor|
      tag.locals.page = ancestor
      if nolinks
        breadcrumbs.unshift tag.render('breadcrumb')
      else
        breadcrumbs.unshift %{<a href="#{tag.render('url')}">#{tag.render('breadcrumb')}</a>}
      end
    end
    separator = tag.attr['separator'] || ' &gt; '
    breadcrumbs.join(separator)
  end
  
    desc %{
    Prints the page's status as a string.  Optional attribute 'downcase'
    will cause the status to be all lowercase.

    *Usage:*

    <pre><code><r:status [downcase='true'] /></code></pre>
  }
  tag 'status' do |tag|
    status = tag.globals.page.status.name
    return status.downcase if tag.attr['downcase']
    status
  end

  desc %{
    The namespace for 'meta' attributes.  If used as a singleton tag, both the description
    and keywords fields will be output as &lt;meta /&gt; tags unless the attribute 'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta [tag="false"] />
     <r:meta>
       <r:description [tag="false"] />
       <r:keywords [tag="false"] />
     </r:meta>
    </code></pre>
  }
  tag 'meta' do |tag|
    if tag.double?
      tag.expand
    else
      tag.render('description', tag.attr) +
      tag.render('keywords', tag.attr)
    end
  end

  desc %{
    Emits the page description field in a meta tag, unless attribute
    'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta:description [tag="false"] /> </code></pre>
  }
  tag 'meta:description' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    description = CGI.escapeHTML(tag.locals.page.description)
    if show_tag
      "<meta name=\"description\" content=\"#{description}\" />"
    else
      description
    end
  end

  desc %{
    Emits the page keywords field in a meta tag, unless attribute
    'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta:keywords [tag="false"] /> </code></pre>
  }
  tag 'meta:keywords' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    keywords = CGI.escapeHTML(tag.locals.page.keywords)
    if show_tag
      "<meta name=\"keywords\" content=\"#{keywords}\" />"
    else
      keywords
    end
  end

  desc %{
    Renders the snippet specified in the @name@ attribute within the context of a page.

    *Usage:*

    <pre><code><r:snippet name="snippet_name" /></code></pre>

    When used as a double tag, the part in between both tags may be used within the
    snippet itself, being substituted in place of @<r:yield/>@.

    *Usage:*

    <pre><code><r:snippet name="snippet_name">Lorem ipsum dolor...</r:snippet></code></pre>
  }
  tag 'snippet' do |tag|
    if name = tag.attr['name']
      if snippet = Snippet.find_by_name(name.strip)
        tag.locals.yield = tag.expand if tag.double?
        tag.globals.page.render_snippet(snippet)
      else
        raise TagError.new('snippet not found')
      end
    else
      raise TagError.new("`snippet' tag must contain `name' attribute")
    end
  end

  desc %{
    Used within a snippet as a placeholder for substitution of child content, when
    the snippet is called as a double tag.

    *Usage (within a snippet):*
    
    <pre><code>
    <div id="outer">
      <p>before</p>
      <r:yield/>
      <p>after</p>
    </div>
    </code></pre>

    If the above snippet was named "yielding", you could call it from any Page,
    Layout or Snippet as follows:

    <pre><code><r:snippet name="yielding">Content within</r:snippet></code></pre>

    Which would output the following:

    <pre><code>
    <div id="outer">
      <p>before</p>
      Content within
      <p>after</p>
    </div>
    </code></pre>

    When called in the context of a Page or a Layout, @<r:yield/>@ outputs nothing.
  }
  tag 'yield' do |tag|
    tag.locals.yield
  end
  
end