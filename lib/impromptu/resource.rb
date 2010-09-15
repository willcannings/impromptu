module Impromptu
  class Resource
    attr_reader :name, :files, :children, :parent, :reference
    
    def initialize(name, parent)
      @name         = name.to_sym
      @parent       = parent
      @base_symbol  = name.to_s.split('::').last.to_sym
      @files        = OrderedSet.new
      @children     = []
      @reference    = nil
    end
    
    def eql?(other)
      other.name == @name
    end
    
    def hash
      @name.hash
    end
    
    def reload
      @files.each {|file| file.reload}
    end
    
    def unload
      return unless loaded?
      @children.each {|child| child.unload}
      parent.reference.send(:remove_const, @base_symbol)
      @reference = nil
    end
    
    def loaded?
      return false unless parent && parent.reference
      parent.reference.constants.include?(@base_symbol)
    end
  end
end
