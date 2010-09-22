class Symbol
  def nested?
    self.to_s.include? '::'
  end
  
  def unnested?
    !self.nested?
  end
  
  def nested_symbols
    self.to_s.split('::').collect(&:to_sym)
  end
  
  def base_symbol
    self.nested_symbols.last
  end
  
  def root_symbol
    self.nested_symbols.first
  end
end
