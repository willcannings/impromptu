module Impromptu
  class Component
    attr_accessor :base_path, :name, :requires, :folders, :frozen
    attr_writer   :namespace
    
    def initialize(base_path, name)
      @base_path    = base_path
      @name         = name
      @requires     = OrderedSet.new
      @folders      = OrderedSet.new
    end
    
    # Extract the name of the parent of this component. e.g:
    # 'mylib.a.b' => 'mylib.a'
    def parent_component_name
      @parent_component_name ||= @name.split('.')[0..-2].join('.')
    end
 
    # Add external dependencies (such as gems) to this component. e.g:
    # requires 'gem_name', 'other_file'
    def requires(*resources)
      protect_from_modification
      @requires.merge(resources)
    end
    
    def folder(*path)
      protect_from_modification
      folder = @folders << Folder.new(@base_path.join(*path).to_s)
      yield folder if block_given?
    end
    
    def namespace(name=nil, options={})
      unless name.nil?
        protect_from_modification
        @namespace = name
        @namespace_file = options[:file]
      end
      @namespace
    end
    
    
    def load
      return if @loaded
      
      # declare this component loaded before loading any sub-components
      # (which may have dependencies re-requiring this component)
      @loaded = true

      # load external dependencies
      @requires.each do |requirement|
        begin
          require requirement
        rescue LoadError => unavailable
          # try loading as a gem
          begin
            require 'rubygems'
          rescue LoadError
            raise unavailable
          end
          require requirement
        end
      end
      
      # FIXME: namespace will be a resource object that should be loaded
      # load the namespace file if the default blank namespace module isn't used
      Kernel.load @base.join(@namespace_file) if @namespace_file
      
      # load the resources provided by the folders of this component
      @folders.each {|folder| folder.reload}
      
      # load any children underneath this component in the tree
      @children.each {|child| child.load}
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if @frozen
      end
  end
end
