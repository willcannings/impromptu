module Flow
  class Component
    attr_accessor :base, :name, :requirements, :folders, :children, :parent
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
      if !name.empty?
        protect_from_modification
        @namespace = name.first
      else
        @namespace
      end
    end
    
    
    # Loading functions
    def load
      return if @loaded
      
      # load the dependencies and modules for this component
      @requirements.each {|component| component.load}
      @folders.each {|folder| folder.load_all_modules}
      
      # load any children underneath this component in the tree
      @children.each {|child| child.load}
      @loaded = true
    end
    
    def load_module(name)
      load and return if !loaded?
      name = name.sub(@namespace, '')
      
      @folders.each do |folder|
        folder.load_module(name) and return if folder.modules.include?(name)
      end
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if frozen?
      end
  end
end
