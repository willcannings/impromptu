require 'helper'

class TestAutload < Test::Unit::TestCase
  context "A component with a namespace and no resources" do
    setup do
      Impromptu.reset
      Impromptu.define_components do
        component 'test' do
          namespace :Namespace
        end
      end
    end
    
    should "have a single component with a namespace" do
      assert_equal 1, Impromptu.components.size
      assert_equal :Namespace, Impromptu.components.values.first.namespace
      assert_not_nil Impromptu.root_resource.child(:Namespace)
    end
    
    should "be able to have the namespace loaded using the autoload extension" do
      assert_nothing_raised do
        ::Namespace
      end
    end
    
    should "raise an appropriate exception when accessing a non existant resource" do
      assert_raise NameError do
        ::IDontExistSoRaiseAnException
      end
    end
  end
end
