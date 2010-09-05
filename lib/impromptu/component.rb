# TODO: need way to define gem or other requirements for a component

module Impromptu
  class Component
    attr_accessor :base, :name, :requirements, :folders, :children, :parent, :frozen
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
    
    def namespace(name=nil, options={})
      unless name.nil?
        protect_from_modification
        @namespace = name
        @namespace_file = options[:file]
      end
      @namespace
    end
    
    
    # Loading functions
    def load
      return if @loaded

      # load the namespace file if the default blank namespace module isn't used
      require @base.join(@namespace_file) if @namespace_file
      
      # declare this component loaded before loading any sub-components
      # (which may have dependencies re-requiring this component)
      @loaded = true
      
      # load the dependencies and modules for this component
      @requirements.each {|component| component.load}
      @folders.each {|folder| folder.load_all_modules}
      
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
