module StandardTags::PageTags

  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end
  
  desc %{
    Causes the tags referring to a page's attributes to refer to the current page.

    *Usage:*
    
    <pre><code><r:page>...</r:page></code></pre>
  }
  tag 'page' do |tag|
    tag.locals.page = tag.globals.page
    tag.expand
  end

  [:breadcrumb, :slug, :title].each do |method|
    desc %{
      Renders the @#{method}@ attribute of the current page.
    }
    tag method.to_s do |tag|
      tag.locals.page.send(method)
    end
  end

  desc %{
    Renders the @url@ attribute of the current page.
  }
  tag 'url' do |tag|
    relative_url_for(tag.locals.page.url, tag.globals.page.request)
  end
  
  desc %{
    Renders the main content of a page. Use the @part@ attribute to select a specific
    page part. By default the @part@ attribute is set to body. Use the @inherit@
    attribute to specify that if a page does not have a content part by that name that
    the tag should render the parent's content part. By default @inherit@ is set to
    @false@. Use the @contextual@ attribute to force a part inherited from a parent
    part to be evaluated in the context of the child page. By default 'contextual'
    is set to true.

    *Usage:*
    
    <pre><code><r:content [part="part_name"] [inherit="true|false"] [contextual="true|false"] /></code></pre>
  }
  tag 'content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    # Prevent simple and deep recursive rendering of the same page part
    rendering_parts = (tag.locals.rendering_parts ||= Hash.new {|h,k| h[k] = []})
    if rendering_parts[page.id].include?(part_name)
      raise TagError.new(%{Recursion error: already rendering the `#{part_name}' part.})
    else
      rendering_parts[page.id] << part_name
    end
    boolean_attr = proc do |attribute_name, default|
      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{`#{attribute_name}' attribute of `content' tag must be set to either "true" or "false"}) unless attribute =~ /true|false/i
      (attribute.downcase == 'true') ? true : false
    end
    inherit = boolean_attr['inherit', false]
    part_page = page
    if inherit
      while (part_page.part(part_name).nil? and (not part_page.parent.nil?)) do
        part_page = part_page.parent
      end
    end
    contextual = boolean_attr['contextual', true]
    part = part_page.part(part_name)
    tag.locals.page = part_page unless contextual
    result = tag.globals.page.render_snippet(part) unless part.nil?
    rendering_parts[page.id].delete(part_name)
    result
  end

  desc %{
    Renders the containing elements if all of the listed parts exist on a page.
    By default the @part@ attribute is set to @body@, but you may list more than one
    part by separating them with a comma. Setting the optional @inherit@ to true will
    search ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *Usage:*
    
    <pre><code><r:if_content [part="part_name, other_part"] [inherit="true"] [find="any"]>...</r:if_content></code></pre>
  }
  tag 'if_content' do |tag|
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', 'false')
    find = attr_or_error(tag, :attribute_name => 'find', :default => 'all', :values => 'any, all')
    expandable = true
    one_found = false
    parts_arr.each do |name|
      part_page = tag.locals.page
      name.strip!
      if inherit
        while (part_page.part(name).nil? and (not part_page.parent.nil?)) do
          part_page = part_page.parent
        end
      end
      expandable = false if part_page.part(name).nil?
      one_found ||= true if !part_page.part(name).nil?
    end
    expandable = true if (find == 'any' and one_found)
    tag.expand if expandable
  end

  desc %{
    The opposite of the @if_content@ tag. It renders the contained elements if all of the
    specified parts do not exist. Setting the optional @inherit@ to true will search
    ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will not render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *Usage:*
    
    <pre><code><r:unless_content [part="part_name, other_part"] [inherit="false"] [find="any"]>...</r:unless_content></code></pre>
  }
  tag 'unless_content' do |tag|
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', false)
    find = attr_or_error(tag, :attribute_name => 'find', :default => 'all', :values => 'any, all')
    expandable, all_found = true, true
    parts_arr.each do |name|
      part_page = tag.locals.page
      name.strip!
      if inherit
        while (part_page.part(name).nil? and (not part_page.parent.nil?)) do
          part_page = part_page.parent
        end
      end
      expandable = false if !part_page.part(name).nil?
      all_found = false if part_page.part(name).nil?
    end
    if all_found == false and find == 'all'
      expandable = true
    end
    tag.expand if expandable
  end
  
end