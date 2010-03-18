module StandardTags

  class TagError < StandardError; end

  private

    def children_find_options(tag)
      attr = tag.attr.symbolize_keys

      options = {}

      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end

      by = (attr[:by] || 'published_at').strip
      order = (attr[:order] || 'asc').strip
      order_string = ''
      if self.attributes.keys.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string

      status = (attr[:status] || ( dev?(tag.globals.page.request) ? 'all' : 'published')).downcase
      unless status == 'all'
        stat = Status[status]
        unless stat.nil?
          options[:conditions] = ["(virtual = ?) and (status_id = ?)", false, stat.id]
        else
          raise TagError.new(%{`status' attribute of `each' tag must be set to a valid status})
        end
      else
        options[:conditions] = ["virtual = ?", false]
      end
      options
    end

    def remove_trailing_slash(string)
      (string =~ %r{^(.*?)/$}) ? $1 : string
    end

    def tag_part_name(tag)
      tag.attr['part'] || 'body'
    end

    def build_regexp_for(tag, attribute_name)
      ignore_case = tag.attr.has_key?('ignore_case') && tag.attr['ignore_case']=='false' ? nil : true
      begin
        regexp = Regexp.new(tag.attr['matches'], ignore_case)
      rescue RegexpError => e
        raise TagError.new("Malformed regular expression in `#{attribute_name}' argument of `#{tag.name}' tag: #{e.message}")
      end
      regexp
    end

    def relative_url_for(url, request)
      File.join(ActionController::Base.relative_url_root || '', url)
    end

    def absolute_path_for(base_path, new_path)
      if new_path.first == '/'
        new_path
      else
        File.expand_path(File.join(base_path, new_path))
      end
    end

    def page_found?(page)
      page && !(FileNotFoundPage === page)
    end

    def boolean_attr_or_error(tag, attribute_name, default)
      attribute = attr_or_error(tag, :attribute_name => attribute_name, :default => default.to_s, :values => 'true, false')
      (attribute.to_s.downcase == 'true') ? true : false
    end

    def attr_or_error(tag, options = {})
      attribute_name = options[:attribute_name].to_s
      default = options[:default]
      values = options[:values].split(',').map!(&:strip)

      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{'#{attribute_name}' attribute of #{tag} tag must be one of: #{values.join(',')}}) unless values.include?(attribute)
      return attribute
    end

    def dev?(request)
      if dev_host = Radiant::Config['dev.host']
        dev_host == request.host
      else
        request.host =~ /^dev\./
      end
    end
end
