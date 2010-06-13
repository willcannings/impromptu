module Flow
  class ComponentSet
    # even though a component set can be composed of components defined in
    # different base directories, it is assumed that the process of parsing
    # component definition files is performed in a single thread, so
    # setting the 'base' instance variable once per file parsed (and passing
    # this to all new components created) should work ok.
    attr_accessor :components, :base

    def initialize
      @components = {}
    end
    
    def parse_file(path)
      @base = File.dirname(path)
      File.open(path) do |file|
        instance_eval file.read
      end
    end

    def component(name, &block)
      if @components.has_key(name)
        raise "Attempt to create a component using a name that already exists"
      else
        new_component = Component.new(@base, self, name)
        new_component.instance_eval block
        @components[name] = new_component
      end
    end
  end
end
