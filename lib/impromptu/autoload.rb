module Impromptu
  module Autoload
    def const_missing(symbol)
      Impromptu::ComponentSet.load_module(symbol)
      mod = eval symbol.to_s
      return mod unless mod.nil?
      super(symbol)
    end
  end
end

Object.extend(Impromptu::Autoload)
