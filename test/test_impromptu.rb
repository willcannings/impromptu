require 'helper'

class TestImpromptu < Test::Unit::TestCase
  context "Impromptu" do
    should "respond to root_resource" do
      assert_respond_to Impromptu, :root_resource
    end
  
    should "respond to components" do
      assert_respond_to Impromptu, :components
    end
  
    should "respond to reset" do
      assert_respond_to Impromptu, :reset
    end
  
    should "respond to define_components" do
      assert_respond_to Impromptu, :define_components
    end
  
    should "respond to parse_file" do
      assert_respond_to Impromptu, :parse_file
    end
  
    should "respond to component" do
      assert_respond_to Impromptu, :component
    end
  
    should "return a resource from root_resource" do
      assert_instance_of Impromptu::Resource, Impromptu.root_resource
    end
    
    should "return a component set from components" do
      assert_instance_of Impromptu::ComponentSet, Impromptu.components
    end
    
    should "rase an exception if a block is not supplied to define_components" do
      assert_raise RuntimeError do
        Impromptu.define_components
      end
    end
  end
end
