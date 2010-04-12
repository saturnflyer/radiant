module UserTags
  include Radiant::Taggable
  
  desc %{
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end

  desc %{
    Renders the Gravatar of the author of the current page or the named user.

    *Usage:*

    <pre><code><r:gravatar /></code></pre>

    or

    <pre><code><r:gravatar [name="User Name"]
        [rating="G | PG | R | X"]
        [size="32px"] /></code></pre>
  }
  tag 'gravatar' do |tag|
    page = tag.locals.page
    name = (tag.attr['name'] || page.created_by.name)
    rating = (tag.attr['rating'] || 'G')
    size = (tag.attr['size'] || '32px')
    email = User.find_by_name(name).email
    if email != ''
      url = 'http://www.gravatar.com/avatar.php?'
      url << "gravatar_id=#{Digest::MD5.new.update(email)}"
      url << "&rating=#{rating}"
      url << "&size=#{size.to_i}"
      url
    else
      "#{request.protocol}#{request.host_with_port}/images/admin/avatar_#{([size.to_i] * 2).join('x')}.png"
    end
  end
end