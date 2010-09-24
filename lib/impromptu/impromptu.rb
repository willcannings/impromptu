module Impromptu
  def self.root_resource
    @root_resource ||= Resource.new(:Object, nil)
  end
  
  def self.components
    @components ||= ComponentSet.new
  end
  
  # Call update to reload any folders (and associated files) which
  # have been marked as reloadable. Any modified files will be
  # reloaded, any new files will have their assiciated resources
  # inserted in the resource tree, and any removed files will be
  # unloaded.
  def self.update
    components.each do |component|
      component.folders.each do |folder|
        folder.reload if folder.reloadable?
      end
    end
  end
  
  # Reset Impromptu by removing all known components and resources.
  # This should rarely be used in a running application and mainly
  # exists to allow the test framework to run the same setup code
  # multiple times without changing stale components.
  def self.reset
    # unload all resources
    unless @root_resource.nil?
      @root_resource.children.each_value do |resource|
        resource.unload
      end
    end
    
    # reset lists to nil
    @root_resource = nil
    @components = nil
    @base = nil
  end

  # parse component definition files, or create components as
  # necessary directly from the supplied block  
  def self.define_components(base=nil, &block)
    # load the component definitions
    raise "No block supplied to define_components" unless block_given?
    @base = base || Pathname.new('.').realpath
    instance_eval &block
    
    # now that we have a complete file/resource graph, freeze
    # the associations at this point (will be unfrozen for reloads)
    components.each do |component|
      component.freeze
    end
  end

  def self.parse_file(path)
    @base = Pathname.new(path).realpath.dirname
    ::File.open(path) do |file|
      instance_eval file.read
    end
  end

  def self.component(name, &block)
    component = components << Component.new(@base, name)
    component.instance_eval &block if block_given?
    component.folders.each {|folder| folder.load}
  end  
end
