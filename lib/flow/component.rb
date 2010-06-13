module Flow
  class Component
    attr_accessor :base, :name, :requirements, :folders, :namespace, :children, :parent
    
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
      protect_from_modification
      @namespace = name.empty? ? @namespace : name.first
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
      @folders.each do |folder|
        if folder.modules
        end
      end
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if frozen?
      end
  end
end
