module Flow
  module Autoload
    def const_missing(symbol)
      Flow::ComponentSet.load_module(symbol)
      mod = eval symbol.to_s
      return mod unless mod.nil?
      super(symbol)
    end
  end
end

Object.extend(Flow::Autoload)
