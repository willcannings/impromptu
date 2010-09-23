module Impromptu
  def self.root_resource
    @root_resource ||= Resource.new(:Object, nil)
  end
  
  def self.components
    @components ||= Hash.new {|hash, key| raise "Attempt to reference unknown component"}
  end

  # parse component definition files, or create components as
  # necessary directly from the supplied block  
  def self.define_components(base=nil, &block)
    raise "No block supplied to define_components" unless block_given?
    @base = base || Pathname.new('.').realpath
    instance_eval &block
  end

  def self.parse_file(path)
    @base = Pathname.new(path).realpath.dirname
    ::File.open(path) do |file|
      instance_eval file.read
    end
  end

  def self.component(name, &block)
    if components.has_key?(name)
      component = components[name]
    else
      component = Component.new(@base, name)
      components[name] = component
    end
    component.instance_eval &block if block_given?
    component.folders.each {|folder| folder.evaluate_block}
  end  
end
