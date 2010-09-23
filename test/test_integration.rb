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
    
    should "have a single folder per component" do
      assert_equal 1, Impromptu.components['framework'].folders.size
      assert_equal 1, Impromptu.components['framework.extensions'].folders.size
    end
    
    should "have a single require in the framework component" do
      assert_equal 1, Impromptu.components['framework'].requirements.size
    end
    
    should "have a namespace for both components" do
      assert_equal :Framework, Impromptu.components['framework'].namespace
      assert_equal :Framework, Impromptu.components['framework.extensions'].namespace
    end
  end
end
