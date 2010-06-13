module Flow
  module Autoload
    def const_missing(symbol)
      mod = Flow::ComponentSet.load_module(symbol)
      return mod if !mod.nil?
      super(symbol)
    end
  end
end

Object.extend(Flow::Autoload)
