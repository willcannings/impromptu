# Impromptu implements the autoloading behaviour using const_missing.
# Module's const_missing definition is replaced with the one below to
# catch references to objects which don't exist. It first tries
# to determine if we know about the resource corresponding to name
# and if so loads and returns a reference to it. Otherwise, the usual
# NameError exception will be raised. We also test to make sure a
# resource isn't already loaded before returning a reference to it. If
# it is, then something very screwy has gone on and Ruby cannot locate
# an already loaded resource.
Module.send(:remove_method, :const_missing)
Module.send(:define_method, :const_missing) do |symbol|
  # namespace the missing resource with the name of the
  # current class or module
  if self == Object
    namespaced_symbol = symbol
  else
    namespaced_symbol = "#{self.name}::#{symbol}".to_sym
  end
  
  # walk the resource tree and get a reference to the
  # resource or nil if we're not tracking it
  resource = Impromptu.root_resource.child(namespaced_symbol)
  raise NameError if resource.nil?
  
  # ensure the resource hasn't already been loaded
  raise "Illegal condition: const_missing called after a resource has been loaded" if resource.loaded?
  
  # load the resource and return a reference to it. this
  # assumes that the source files will correctly define
  # the resource. otherwise nil will be returned.
  resource.reload
  resource.reference
end
