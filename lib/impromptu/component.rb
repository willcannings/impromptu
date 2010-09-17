module Impromptu
  class Component
    attr_accessor :base_path, :name, :requirements, :folders, :frozen
    attr_writer   :namespace
    
    # Create a new component. base_path is the 'current working
    # directory' of the component, and all folder paths will be
    # joined with this path to create an absolute path. Name is
    # the name of the component and is currently only used as a
    # reference. Names must be unique amongst all components, so
    # to avoid clashes a namespacing scheme should be used.
    def initialize(base_path, name)
      @base_path    = base_path || Pathname.new('.').realpath
      @name         = name
      @requirements = OrderedSet.new
      @folders      = OrderedSet.new
      @namespace    = nil
      @frozen       = false
      @dependencies_loaded = false
    end
    
    # Add external dependencies (such as gems) to this component. e.g:
    # requires 'gem_name', 'other_file'. May be called multiple times.
    def requires(*resources)
      protect_from_modification
      @requirements.merge(resources)
    end
    
    # Declare a folder implementing this component. All source files
    # within this folder are assumed to define the resources of this
    # component. Sub-folders by default provide nested namespaces,
    # and when used in combination with the namespace method can
    # produce multi-level namespaces. For example, a root folder 'src'
    # which contains a sub-folder 'plugins', and a file 'testing.rb'
    # would provide the resource Plugins::Testing. If namespace was
    # used to define a root namespace for the component, that namespace
    # would precede the Plugins namespace. To turn off this behaviour
    # set the nested_namespaces option to false. e.g:
    # folder 'src', nested_namespaces: false
    def folder(path, options={})
      protect_from_modification
      folder = @folders << Folder.new(@base_path.join(*path), options)
      yield folder if block_given?
    end
    
    # Define a namespace used for all resources provided by this
    # component. This becomes the root namespace for all top level
    # folders. e.g if you declare a namespace ':Root', and a single
    # folder 'src' which contains a file 'klass.rb', klass.rb will
    # declare the resource Root::Klass. By default, nested folders
    # will extend the namespace with the name of the folder. For
    # instance, if the src folder contained another called 'plugins'
    # which contained a file 'testing.rb', the resource
    # Root::Plugins::Testing would be defined. Folder declarations
    # can override this behaviour.
    def namespace(name=nil)
      unless name.nil?
        protect_from_modification
        @namespace = name
      end
      @namespace
    end
    
    # Load the external dependencies required by this component. If
    # the require fails, ruby gems is loaded and the require attempted
    # again. Any failures after this point will cause a LoadError
    # exception to bubble through your application.
    def load_external_dependencies
      return if @dependencies_loaded
      @requirements.each do |requirement|
        begin
          require requirement
        rescue LoadError => unavailable
          begin
            require 'rubygems'
          rescue LoadError
            raise unavailable
          end
          require requirement
        end
      end
      @dependencies_loaded = true
    end
    
    # Mark a component as 'frozen'. Modification of the component
    # requirements or folders are not allowed after this point.
    def freeze
      @frozen = true
    end
    
    # True if the component definition has been frozen.
    def frozen?
      @frozen
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if @frozen
      end
  end
end
