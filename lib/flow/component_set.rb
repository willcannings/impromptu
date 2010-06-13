module Flow
  module ComponentSet
    def self.define_components(base=nil, &block)
      # initialise
      @components = Hash.new {|hash, key| raise "Attempt to reference unknown component"}
      @modules    = Hash.new {|hash, key| raise "Attempt to reference unknown module"}
      @files      = Hash.new {|hash, key| raise "Attempt to reference unknown file"}
      @base       = base
      
      # parse component definition files, or create components as
      # necessary directly from the supplied block
      raise "No block supplied to define_components" unless block_given?
      instance_eval &block
      
      # construct the component tree and ensure the validity of the
      # dependency graph between components
      create_missing_components
      generate_component_tree
      determine_component_namespaces
      complete_requirement_references
      freeze_components
      ensure_no_circular_dependencies_exist
    end
    
    def self.parse_file(path)
      @base = Pathname.new(File.dirname(path))
      File.open(path) do |file|
        instance_eval file.read
      end
    end

    def self.component(name, &block)
      if @components.has_key?(name)
        raise "A component named '#{name}' already exists"
      else
        @components[name] = Flow::Component.new(@base, name)
        @components[name].instance_eval &block if block_given?
      end
    end
    

    private
      # Create any components which are expected to exist (given the component
      # hierarchy) but don't. Blank components are created to complete the tree.
      def self.create_missing_components
        @components.values.each do |component|
          next if !component.name.include?('.')
          hierarchy = component.name.split('.')
          hierarchy.size.times {|index| create_component_if_missing(component.base, hierarchy[0..index].join('.'))}
        end
      end
      
      # Creates a blank component if no component by the given name exists.
      def self.create_component_if_missing(base, name)
        return if @components.has_key?(name)
        @components[name] = Flow::Component.new(base, name)
      end
    
      # Generate the list of child components for each component. A reference
      # to the parent of each component is also stored in each child.
      def self.generate_component_tree
        potential_children = @components.values
        @components.values.each do |component|
          component.children = potential_children.select {|child| child.parent_component_name == component.name}
          component.children.each {|child| child.parent = component}
          potential_children -= component.children
        end
      end
      
      # Determine the namespace for each component based on the ancestors
      # in the component tree. For instance, a component with no namespace
      # will inherit the namespace from the first ancestor with a namespace.
      def self.determine_component_namespaces
        # TODO: this is ripe for optimisation
        @components.values.each do |component|
          namespaces = []
          node = component
          namespaces << node.namespace and node = node.parent until node.nil?
          component.namespace = namespaces.compact.reverse.join("::")
        end
      end
      
      # When components are defined, requirements are specified using the
      # string name of each dependency. This function converts each string
      # name in to a reference to the actual, realised component object.
      def self.complete_requirement_references
        @components.values.each do |component|
          component.requirements = component.requirements.collect {|component_name| @components[component_name]}
        end
      end
    
      # Call the freeze method on every component, preventing modification
      # to the components after we have processed dependencies and
      # constructed the component tree.
      def self.freeze_components
        @components.values.each {|component| component.freeze}
      end
    
      # Determine if any circular references exist within the dependency
      # graphs generated from any root component. It's possible to have
      # multiple segregated graphs; by searching from each root node we
      # are guaranteed to hit every node in the entire graph at least
      # once.
      def self.ensure_no_circular_dependencies_exist        
        # determine which components are root components
        root_nodes = @components.values
        @components.values.each do |component|
          component.requirements.each {|required_component| root_nodes.delete required_component}
        end
        
        # perform a depth first search from each root component
        seen_nodes = []
        completed_nodes = []
        require_node = lambda do |node|
          return if completed_nodes.include?(node)
          raise "Circular reference detected in component dependency graph (#{node.name})" if seen_nodes.include?(node)
          seen_nodes << node
          node.requirements.each {|node| require_node.call(node)}
          node.children.each {|child| require_node.call(child)}
          completed_nodes << node
        end
        
        root_nodes.each do |node|
          seen_nodes = []
          completed_nodes = []
          require_node.call(node)
        end
      end
    
  end
end
