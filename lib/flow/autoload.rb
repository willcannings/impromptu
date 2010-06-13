module Flow
  module Autoload
    def const_missing(symbol)
      
    end
  end
end

Object.extend(Flow::Autoload)