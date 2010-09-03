# TODO: need way to define gem or other requirements for a component

module Impromptu
  class Component
    attr_accessor :base, :name, :requirements, :folders, :children, :parent, :frozen, :create_namespace # TODO: add test for create_namespace
    attr_writer   :namespace
    
    def initialize(base, name)
      @base = base
      @name = name
      @requirements = OrderedSet.new
      @folders = OrderedSet.new
    end

    # Utility functions
    def parent_component_name
      @name.split('.')[0..-2].join('.')
    end
 
 
    # Definition functions
    def requires(*components)
      protect_from_modification
      @requirements.merge(components)
    end
    
    def folder(*path)
      protect_from_modification
      @folders << Folder.new(@base.join(*path).to_s)
    end
    
    def namespace(*name)
      unless name.empty?
        protect_from_modification
        @namespace = name.first
        @create_namespace = true
        if name.size == 2
          @namespace_file = name[1][:file]
        else
          @namespace_file = nil # required for: namespace :A, :file => ''; followed by namespace :A on the same component
        end
      end
      @namespace
    end
    
    
    # Loading functions
    def load
      return if @loaded

      # load or create the namespace as required
      if @namespace && @create_namespace
        if @namespace_file
          require @base.join(@namespace_file)
        else
          eval "::#{@namespace} = Module.new"
        end
      end
      
      # load the dependencies and modules for this component
      @requirements.each {|component| component.load}
      @folders.each {|folder| folder.load_all_modules}
      
      # declare this component loaded before loading any sub-components
      # (which may have dependencies re-requiring this component)
      @loaded = true
      
      # load any children underneath this component in the tree
      @children.each {|child| child.load}
    end
    
    def load_module(name)
      load and return unless @loaded
      
      name = name.sub(@namespace, '')
      @folders.each do |folder|
        folder.load_module(name) and return if folder.modules.include?(name)
      end
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if @frozen
      end
  end
end
