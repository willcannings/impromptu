require 'helper'

class TestIntegration < Test::Unit::TestCase
  context "Loading the test.components file" do
    setup do
      Impromptu.define_components do
        parse_file 'test/framework/test.components'
      end
    end
    
    should "create two components" do
      assert_equal 2, Impromptu.components.size
    end
  end
end