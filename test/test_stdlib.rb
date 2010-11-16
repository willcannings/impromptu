require 'helper'

class TestStdlib < Test::Unit::TestCase
  context "A component with resources extending the standard library" do
    setup do
      Impromptu.reset
      Impromptu.define_components do
        component 'stdlib' do
          folder 'test/framework/stdlib'
        end
      end
    end
    
    should "have a single component, and an extension for String" do
      assert_equal 1, Impromptu.components.size
      assert_not_nil Impromptu.root_resource.child(:String)
    end
    
    should "automatically load the String resource" do
      assert_respond_to "string", :extra_method
      assert "string".extra_method
    end
    
    should "automatically load nested resources" do
      # timeout
      assert_respond_to Timeout, :ext_one
      assert Timeout.ext_one
      
      # timeout::error
      assert_respond_to Timeout::Error, :ext_two
      assert Timeout::Error.ext_two
    end
  end
end
