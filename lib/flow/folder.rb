module Flow
  class Folder
    attr_accessor :path, :modules
    
    def initialize(path)
      @modules = OrderedSet.new
      @path = path
    end
    
    def eql?(other)
      other.path == @path
    end
    alias :== :eql?
    
    def hash
      @path.hash
    end
    
    
    # definition functions
    def provides(*modules)
      @modules.merge(modules)
    end
    
    
    # loading functions
    def load_module(name)
      # if the name is namespaced, we only care about the final component, then
      # change from camel case to underscored
      name = name.to_s.split('::').last
      name = name.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
      require File.join(@path, name)
    end
    
    def load_all_modules
      @modules.each {|name| load_module name}
    end
  end
end
