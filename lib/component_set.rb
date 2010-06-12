module Flow
  class ComponentSet
    attr_accessor :components

    def initialize
      @components = {}
    end

    def component(name, &block)
      @components[name] = Component.new(self, name, block)
    end
  end
end
