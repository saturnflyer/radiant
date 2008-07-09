# courtesy of [chris kampmeier](http://www.shiftcommathree.com/articles/testing-your-dependencies)

module BeLoadableMatcher

  class BeLoadable   #:nodoc:
    def matches?(requirement)
      @requirement = requirement
      if @requirement.respond_to?(:satisfied?)
        @requirement.satisfied?
      elsif @requirement.respond_to?(:to_s)
        @requirement = MultipleDependencyRequirement.new(:all, [requirement])
        @requirement.satisfied?
      end
    end

    def failure_message
      @requirement.failure_message
    end
  end


  # Checks whether each dependency can be loaded with +require+, and fails if the
  # result doesn't match your expectation. Example usage:
  #
  #   one_of('image_science', 'RMagick', 'mini_magick').should be_loadable
  #   all_of('digest/sha1', 'digest/sha2', 'digest/md5').should be_loadable
  #   both_of(:openid, :yadis).should be_loadable
  #   either_of('maruku', 'RedCloth').should be_loadable
  #   'chronic'.should be_loadable
  #   :hpricot.should be_loadable
  def be_loadable
    BeLoadable.new
  end



  class MultipleDependencyRequirement   #:nodoc:
    # :type        :any or :all
    # :libraries   an array of strings/symbols/etc. to try to +require+
    def initialize(type, libraries)
      @type = type
      @libraries = libraries
      @failed_libraries = []
    end
    
    def satisfied?
      libraries = @libraries.dup
      libraries.each do |lib|
        begin
          require lib.to_s
        rescue LoadError, MissingSourceFile
          @failed_libraries << lib.to_s
        end
      end
      
      return (@type == :any && @failed_libraries.size < @libraries.size) ||
             (@type == :all && @failed_libraries.empty?)
    end
    
    def to_s
      @libraries.map {|lib| "'#{lib}'"}.to_sentence
    end
    
    def load_failures_to_s
      @failed_libraries.map {|lib| "'#{lib}'"}.to_sentence
    end
    
    def failure_message
      if @failed_libraries.size == 1
        "Make sure the #{load_failures_to_s} library is available."
      elsif @type == :any
        "Make sure at least one of these libraries is available: #{self} (all failed to load)."
      else
        "Make sure all of these libraries are available: #{self} (failed to load #{load_failures_to_s})."
      end
    end
  end


  # Specify that at least one of +libraries+ should be loadable. Example:
  #   one_of('maruku', 'RedCloth', 'BlueCloth').should be_loadable
  # Aliased as +either_of+ for more-readable use with two libraries specified.
  def one_of(*libraries)
    MultipleDependencyRequirement.new(:any, libraries)
  end
  alias_method :either_of, :one_of
  
  
  # Specify that every one of +libraries+ should be loadable. Example:
  #   all_of('digest/sha1', 'digest/sha2', 'digest/md5').should be_loadable
  # Aliased as +both_of+ for more-readable use with two libraries specified.
  def all_of(*libraries)
    MultipleDependencyRequirement.new(:all, libraries)
  end
  alias_method :both_of, :all_of

end


include BeLoadableMatcher