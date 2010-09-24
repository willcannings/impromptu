module Impromptu
  class OrderedSet
    include Enumerable

    def initialize
      @items_hash = {}
      @items_list = []
    end
    
    def <<(item)
      unless self.include?(item)
        @items_hash[item] = item
        @items_list << item
      end
      @items_hash[item]
    end
    alias :push :<<
    
    def merge(items)
      items.each {|item| self.<< item}
    end
    
    def delete(item)
      self.include?(item) or return nil
      @items_hash.delete(item)
      @items_list.delete(item)
    end

    def include?(item)
      @items_hash.has_key?(item)
    end

    def to_a
      @items_list.dup
    end
    
    def each(&block)
      @items_list.each {|item| yield item}
    end
    
    def size
      @items_list.size
    end
    
    def empty?
      @items_list.empty?
    end
  end
end
