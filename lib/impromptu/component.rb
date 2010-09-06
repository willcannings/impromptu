module Impromptu
  class Component
    attr_accessor :base_path, :name, :dependencies, :requires, :folders, :children, :parent, :frozen
    attr_writer   :namespace
    
    def initialize(base_path, name)
      @base_path    = base_path
      @name         = name
      @dependencies = OrderedSet.new
      @requires     = OrderedSet.new
      @folders      = OrderedSet.new
    end
    
    # Extract the name of the parent of this component. e.g:
    # 'mylib.a.b' => 'mylib.a'
    def parent_component_name
      @parent_component_name ||= @name.split('.')[0..-2].join('.')
    end
 
    # Add component dependencies to this component. e.g:
    # depends_on 'mylib.a', 'mylib.b'
    def depends_on(*components)
      protect_from_modification
      @dependencies.merge(components)
    end
 
    # Add external dependencies (such as gems) to this component. e.g:
    # requires 'gem_name', 'other_file'
    def requires(*resources)
      protect_from_modification
      @requires.merge(resources)
    end
    
    def folder(*path)
      protect_from_modification
      @folders << Folder.new(@base_path.join(*path).to_s)
    end
    
    def namespace(name=nil, options={})
      unless name.nil?
        protect_from_modification
        @namespace = name
        @namespace_file = options[:file]
      end
      @namespace
    end
    
    
    # Loading functions
    def load
      return if @loaded

      # load the namespace file if the default blank namespace module isn't used
      require @base.join(@namespace_file) if @namespace_file
      
      # declare this component loaded before loading any sub-components
      # (which may have dependencies re-requiring this component)
      @loaded = true
      
      # load the dependencies and modules for this component
      @requirements.each {|component| component.load}
      @folders.each {|folder| folder.load_all_modules}
      
      # load any children underneath this component in the tree
      @children.each {|child| child.load}
    end
    
    def load_module(name)
      load and return unless @loaded
      
      name = name.sub(@namespace, '')
      @folders.each do |folder|
        folder.load_module(name) and return if folder.modules.include?(name)
      end
    end
    
    private
      def protect_from_modification
        raise "Modification of component after component has been loaded" if @frozen
      end
  end
end
