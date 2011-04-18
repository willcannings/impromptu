module Impromptu
  # Resources are represented in a tree, with the root_resource
  # representing the Object object. All resources are children
  # of this resource.
  def self.root_resource
    @root_resource ||= Resource.new(:Object, nil)
  end
  
  # The set of components known to Impromptu
  def self.components
    @components ||= ComponentSet.new
  end
  
  # Call update to reload any folders (and associated files) which
  # have been marked as reloadable. Any modified files will be
  # reloaded, any new files will have their assiciated resources
  # inserted in the resource tree, and any removed files will be
  # unloaded. Any preloaded resources which are unloaded as a
  # result of an update will automatically be reloaded again.
  def self.update
    components.each do |component|
      component.folders.each do |folder|
        folder.reload if folder.reloadable?
      end
    end
    
    # force any unloaded preloading resources to reload
    self.root_resource.reload_preloaded_resources
  end
  
  # Reset Impromptu by removing all known components and resources.
  # This should rarely be used in a running application and mainly
  # exists to allow the test framework to run the same setup code
  # multiple times without changing stale components.
  def self.reset
    # unload all resources
    unless @root_resource.nil?
      @root_resource.unload
    end
    
    # reset lists to nil
    @root_resource = nil
    @components = nil
    @base = nil
  end

  # Parse component definition files, or create components as
  # necessary directly from the supplied block. The block is run
  # in the context of the Impromptu module allowing you to call
  # 'component' directly without reference to Impromptu.
  def self.define_components(base=nil, &block)
    # load the component definitions
    raise "No block supplied to define_components" unless block_given?
    @base = base || Pathname.new('.').realpath
    instance_eval &block
    
    # now that we have a complete file/resource graph, freeze
    # the associations at this point (will be unfrozen for reloads)
    components.each do |component|
      component.load_external_dependencies
      component.freeze
    end
    
    # preload any resources which extend existing standard library
    # modules or classes. we can't catch uses of these resources
    # using const_missing, so we need to load them now.
    @root_resource.mark_dont_undef
    @root_resource.load_if_extending_stdlib
    
    # load any folders which are to be preloaded
    components.each do |component|
      component.folders.each do |folder|
        folder.preload if folder.preload?
      end
    end
  end

  # Open and run a file defining components. The folder containing
  # the file is used as the 'base' folder, and folder references
  # within components are assumed to be relative to this base.
  def self.parse_file(path)
    @base = Pathname.new(path).realpath.dirname
    ::File.open(path) do |file|
      instance_eval file.read
    end
  end

  # Define and create a new component. The name of the component
  # must be unique (otherwise you will get a reference to the
  # existing component), and the block supplied is run in the context
  # of the newly created component.
  def self.component(name, &block)
    component = components << Component.new(@base, name)
    component.instance_eval &block if block_given?
    component.folders.each {|folder| folder.load}
  end  
end
