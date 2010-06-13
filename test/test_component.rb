require 'helper'

class TestComponent < Test::Unit::TestCase
  context "A new component" do
    setup { @component = Flow::Component.new(Pathname.new('.'), 'component') }
    should "respond to :requires" do
      assert_respond_to @component, :requires
    end
    
    should "respond to :namespace" do
      assert_respond_to @component, :namespace
    end
    
    should "respond to :folder" do
      assert_respond_to @component, :folder
    end
    
    should "have a name" do
      assert_not_nil @component.name
    end
    
    should "have no requirements" do
      assert_equal 0, @component.requirements.size
    end
    
    should "have no folders" do
      assert_equal 0, @component.folders.size
    end
    
    context "with two requirements" do
      setup { @component.requires('component2', 'component3.subcomponent') }
      should "store two requirements" do
        assert_equal 2, @component.requirements.size
      end
      
      context "and with two more, overlapping requirements" do
        setup { @component.requires('component3.subcomponent', 'component4') }
        should "only store new requirements" do
          assert_equal 3, @component.requirements.size
        end
      end
    end
    
    context "with a namespace" do
      setup { @component.namespace("context") }
      should "have a namespace" do
        assert_equal "context", @component.namespace
      end
    end
    
    context "with a folder" do
      setup { @component.folder('lib') }
      should "have one folder" do
        assert_equal 1, @component.folders.size
      end
      
      should "have a folder that is a folder" do
        assert_instance_of Flow::Folder, @component.folders.first
      end
    end
  end

end