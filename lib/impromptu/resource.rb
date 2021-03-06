module Impromptu
  # Resources represent the modules or classes that are tracked by
  # Impromptu and which can be lazy loaded. You should never create
  # resources yourself - use component definitions to define folders
  # of files which will implement resources.
  class Resource
    attr_reader :name, :base_symbol, :files, :children, :parent, :preload
    
    def initialize(name, parent)
      @name         = name.to_sym
      @parent       = parent
      @base_symbol  = @name.base_symbol
      @files        = OrderedSet.new
      @children     = {}
      @reference    = nil
      @namespace    = false
      @dont_undef   = self.loaded?  # existing constants, such as 'String', should never be unloaded
      @preload      = false # true if any folder defining this resource is marked to be preloaded
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
    
    # Indicate whether this resource needs to be preloaded
    def preload=(preload)
      @preload = preload
    end
    
    # True if this resource needs to be preloaded before other files
    # are automatically loaded on demand
    def preload?
      @preload
    end
    
    # Attempts to retrieve a reference to the object represented by
    # this resource. If the resource is unloaded, nil is returned.
    def reference
      return Object if root?
      return nil unless @parent && @parent.reference
      @reference ||= @parent.reference.const_get(@base_symbol)
    end
    
    # Reload the implementation of this resource from all files being
    # tracked for this resource. Call this method if you are manually
    # managing file tracking, and need to guarantee all files for this
    # resource have been loaded. It is normally unecessary to call this
    # if you rely on the autoloader and reloader.
    def reload
      @parent.reload unless @parent.loaded?
      if @implicitly_defined
        unload
        Object.module_eval "module #{@name}; end"
      else
        @files.first.reload
      end
      reload_preloaded_resources
    end
    
    # Unload the resource by undefining the constant representing it.
    # Any resources contained within this resource will also be
    # unloaded. This allows the resource to be garbage collected. If
    # the resource is a class, you can define a class method called
    # 'descendants' that returns an array of references to subclasses.
    # Any subclasses known to Impromptu will also be unloaded, just as
    # namespaced children are. This prevents subclasses holding a
    # reference to a stale version of a super class.
    def unload
      return unless loaded?
      
      # unload namespaced children
      @children.each_value(&:unload)
      
      # unload descendants if they can be reloaded by impromptu
      if reference.respond_to? :descendants
        reference.descendants.each do |descendant|
          resource = Impromptu.root_resource.child(descendant.name.to_sym)
          resource.unload unless resource.nil?
        end
      end
      
      # remove from the parent's descendants list
      if reference.respond_to?(:superclass) &&  reference.superclass.respond_to?(:descendants)
        reference.superclass.descendants.delete(reference)
      end
      
      unless @dont_undef
        @parent.reference.send(:remove_const, @base_symbol)
        @reference = nil
      end
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
      @implicitly_defined = true if @files.size == 0 && namespace?
    end
    
    # True if no files have been associated with this resource. In
    # this case, loading the resource will be achieved by creating
    # a blank module with the name of the resource. If any files
    # have been associated, they will be loaded instead, and this
    # method will return false.
    def implicitly_defined?
      @implicitly_defined
    end
    
    # True if this resource represents a module acting as a
    # namespace.
    def namespace?
      @namespace
    end
    
    # Mark a resource as representing a module acting as a
    # namespace.
    def namespace!
      @namespace = true
    end
    
    # True if this resource is the parent of any resources.
    def children?
      !@children.empty?
    end
    
    # Add a child resource to this resource. This does not load the
    # resource. This should only be called by get_or_create_child.
    def add_child(resource)
      @children[resource.base_symbol] = resource
    end
    
    # Remove a reference to a child resource. This does not unload
    # the object, but is called automatically by unload on its parent
    # resource.
    def remove_child(resource)
      @children.delete(resource.base_symbol)
    end
    
    # In most instances, this method should only be called on the
    # root resource to traverse the resource tree and retrieve or
    # create the specified resource. Name must be a symbol.
    def get_or_create_child(name)
      return nil unless name.is_a?(Symbol)
      current = self
      
      name.each_namespaced_symbol do |name|
        # attempt to get the current resource
        child_resource = current.child(name.base_symbol)
        
        # create the resource if needed
        if child_resource.nil?
          child_resource = Resource.new(name, current)
          current.add_child(child_resource)
        end
        
        # the next current resource is the one we just created or retrieved
        current = child_resource
      end
      
      # after iterating through the name, current will be the resulting resource
      current
    end
    
    # Walks the resource tree and returns the resource corresponding
    # to name (which must be a symbol and can be namespaced). If the
    # resource doesn't exist, nil is returned
    def child(name)
      return nil unless name.is_a?(Symbol)
      return @children[name.without_leading_colons.to_sym] if name.unnested?
      
      # if the name is nested, walk the resource tree to return the
      # resource under this branch. rerturn nil if we reach a
      # branch which doesn't exist
      nested_symbols    = name.nested_symbols
      top_level_symbol  = nested_symbols.first
      further_symbols   = nested_symbols[1..-1].join('::').to_sym
      return nil unless @children.has_key?(top_level_symbol)
      @children[top_level_symbol].child(further_symbols)
    end
    
    # Walks the resource tree to determine if the resource referred
    # to by name (which must be a symbol, and may be namespaced) is
    # known by Impromptu.
    def child?(name)
      !self.child(name).nil?
    end
    
    # Unload and remove all references to this resource.
    def remove
      unload
      @parent.remove_child(self) if @parent
    end
    
    # True if this resource is the root resource referring to Object.
    def root?
      @parent.nil?
    end
    
    # True if this resource exists as a constant in its parent.
    # This does not guarantee that every file implementing this
    # resource has been loaded, however, so an incomplete instance
    # may exist. If you rely on the autoloader and reloader this
    # will not occur.
    def loaded?
      return true if root?
      return false unless @parent && @parent.loaded? && @parent.reference
      parent.reference.constants.include?(@base_symbol)
    end
    
    # Mark this resource as having been loaded before Impromptu if the
    # resource is already defined.
    def mark_dont_undef
      @dont_undef = self.loaded?
      @children.each_value(&:mark_dont_undef)
    end
    
    # Loads this resource if it is an extension of an existing class
    # or module (such as an object in the standard library). Should
    # only be called on app startup by Impromptu itself. Recurses to
    # this resource's children as well.
    def load_if_extending_stdlib
      reload if loaded? && !self.root?
      @children.each_value(&:load_if_extending_stdlib)
    end
    
    # Loads this resource, and any child resources, if the resource is
    # marked as requiring preloading, and the resource is not currently
    # loaded. This loading may happen multiple times during the application
    # life cycle depending on whether parent resources are reloaded and so on.
    def reload_preloaded_resources
      reload if !loaded? && preload?
      @children.each_value(&:reload_preloaded_resources)
    end
  end
end
