module Framework
  class Klass
    def self.standard_method
    end
    
    def self.overriden_method
      1
    end
    
    def self.descendants
      @descendants ||= []
    end

    def self.inherited(child)
      super(child)
      descendants << child
    end
  end
end
