module Impromptu
  class ComponentSet < OrderedSet
    # Retrieve a component by name. This is used very
    # rarely (only in component definitions and the
    # test suite) so a linear search is acceptable.
    def [](name)
      @items_list.select {|component| component.name == name}.first
    end
  end
end