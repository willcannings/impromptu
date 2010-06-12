module Flow
  class Component
    attr_accessor :base, :component_set, :name, :requirements, :folders
    
    def initialize(base, component_set, name)
      @base = base
      @component_set = component_set
      @name = name
      @requirements = []
      @folders = []
    end
    
    def requires(*components)
      @requirements += components
      @requirements.uniq!
    end
    
    # TODO: perhaps we should do full path resolution from here
    # so we can assert there is only one folder object per path
    def folder(*path)
      @folders << Folder.new(base, path)
    end
    
    def namespace(*name)
      if name.size == 0
        @namespace
      else
        @namespace = name.first
      end
    end
  end
end
