module Impromptu
  class Resource
    attr_reader :name, :files, :children, :parent, :reference
    
    def initialize(name, parent, component)
      @name         = name.to_sym
      @parent       = parent
      @base_symbol  = name.to_s.split('::').last.to_sym
      @files        = OrderedSet.new
      @children     = []
      @reference    = nil
      @implicitly_defined = true
    end
    
    # Override eql? so two resources with the same name will be
    # considered equal by ordered set. Names are fully namespaced
    # so will always be unique.
    def eql?(other)
      other.name == @name
    end
    
    # Override hash so two resources with the same name will result
    # in the same hash value. Names are fully namespaced so will
    # always be unique.
    def hash
      @name.hash
    end
    
    # Reload the implementation of this resource from all files being
    # tracked for this resource. Call this method if you are manually
    # managing file tracking, and need to guarantee all files for this
    # resource have been loaded. It is normally unecessary to call this
    # if you rely on the autoloader and reloader.
    def reload
      if @implicitly_defined
        # TODO: load blank module
      else
        @files.each {|file| file.reload}
      end
    end
    
    # Unload the resource by undefining the constant representing it.
    # Any resources contained within this resource will also be
    # unloaded. This allows the resource to be garbage collected.
    def unload
      return unless loaded?
      @children.each {|child| child.unload}
      parent.reference.send(:remove_const, @base_symbol)
      @reference = nil
    end
    
    # Start tracking a file which implements this resource. If the
    # file has already been added it won't be added a second time.
    # This method does not load the added file, so the definition
    # of the resource will be incomplete until reload is called.
    def add_file(file)
      @files << file
      @implicitly_defined = false
    end
    
    # Un-track a file implementing this resource. If the file was
    # never tracked, no error is raised. This does not reload the
    # resource, so the resource will be based on a stale definition
    # if it was previously loaded.
    def remove_file(file)
      @files.delete(file)
      @implicitly_defined = true if @files.size == 0
    end
    
    # Unload and remove all references to this resource.
    def remove
      # TODO: implement
    end
    
    # True if this resource exists as a constant in its parent.
    # This does not guarantee that every file implementing this
    # resource has been loaded, however, so an incomplete instance
    # may exist. If you rely on the autoloader and reloader this
    # will not occur.
    def loaded?
      return false unless parent && parent.reference
      parent.reference.constants.include?(@base_symbol)
    end
  end
end
