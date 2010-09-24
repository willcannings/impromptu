require 'helper'

class TestComponentSet < Test::Unit::TestCase
  context "A component set with two components" do
    setup do
      @set = Impromptu::ComponentSet.new
      @a = @set << Impromptu::Component.new(nil, 'a')
      @b = @set << Impromptu::Component.new(nil, 'b')
    end
    
    should "have two components" do
      assert_equal 2, @set.size
    end
    
    should "be able to find both components by name" do
      assert_equal @a, @set['a']
      assert_equal @b, @set['b']
    end
  end
end
