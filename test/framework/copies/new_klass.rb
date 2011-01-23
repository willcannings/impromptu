module Framework
  class Klass
    def self.overriden_method
      3
    end
    
    def self.new_method
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
