# Extensions to all Symbols to make it easier to deal
# with namespaced, nested symbol names
class Symbol
  # True if this symbol contains namespaces (is a nested
  # symbol such as A::B).
  def nested?
    self.to_s.include? '::'
  end
  
  # True if this symbol contains no namespaces (is a root
  # symbol such as A, in contrast to to A::B).
  def unnested?
    !self.nested?
  end
  
  # Split a symbol into its component names (A::B =>
  # [:A, :B])
  def nested_symbols
    self.to_s.split('::').collect(&:to_sym)
  end
  
  # Retrieve the base (end or final) symbol name from this
  # symbol (the Class or Module actually being referred to).
  def base_symbol
    self.nested_symbols.last
  end
  
  # Retrieve the root (first) symbol name from this symbol.
  def root_symbol
    self.nested_symbols.first
  end
  
  # Iterate through a namespaced symbol by visiting each
  # name in turn, including its parent names. e.g calling
  # on A::B::C would yield :A, :A::B, and :A::B::C
  def each_namespaced_symbol
    self.nested_symbols.inject([]) do |name, symbol|
      name << symbol
      yield name.join('::').to_sym
      name
    end
  end
end
