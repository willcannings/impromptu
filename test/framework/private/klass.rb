module Framework
  class Klass
    def self.extension_method
    end
    
    def self.overriden_method
      2
    end
  end
  
  module SubComponent
    module Leaf
    end
  end
end
