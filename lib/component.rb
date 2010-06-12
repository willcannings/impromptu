module Flow
  class Component
    attr_accessor :component_set, :name, :namespace, :requires
    
    def initialize(component_set, name, block)
      @component_set = component_set
      @name = name
      instance_eval block
    end
    
    def requires(*components)
    end
    
    def folder(name)
      self
    end
    
    def provides(*modules)
    end
    
    def namespace(name)
      @namespace = name
    end
  end
end
