module Flow
  class Folder
    attr_accessor :path, :modules

    def initialize(base, path)
      @modules = []
      @path = base.join(*path).to_s
    end
    
    def provides(*modules)
      @modules += modules
      @modules.uniq!
    end
  end
end
