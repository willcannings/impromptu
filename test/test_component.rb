require 'helper'

class TestComponent < Test::Unit::TestCase
  context "A new component" do
    setup { @component = Impromptu::Component.new(nil, 'component') }
    should "have a default path of the cwd" do
      assert_equal Pathname.new('.').realpath, @component.base_path
    end
    
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

    # ----------------------------------------
    # Requirements
    # ----------------------------------------
    context "with two requirements" do
      setup { @component.requires('gem', 'other') }
      should "store two requirements" do
        assert_equal 2, @component.requirements.size
      end
      
      context "and with two more, overlapping requirements" do
        setup { @component.requires('another', 'gem') }
        should "only store new requirements" do
          assert_equal 3, @component.requirements.size
        end
      end
    end

    # ----------------------------------------
    # Namespaces
    # ----------------------------------------
    context "with a namespace" do
      setup { @component.namespace(:Framework) }
      should "have a namespace" do
        assert_equal :Framework, @component.namespace
      end
    end
    
    # ----------------------------------------
    # Folders
    # ----------------------------------------
    context "with a folder" do
      setup { @component.folder('framework') }
      should "have one folder" do
        assert_equal 1, @component.folders.size
      end
      
      should "have a folder that is a folder" do
        assert_instance_of Impromptu::Folder, @component.folders.first
      end
    end
    
    # ----------------------------------------
    # Freezing
    # ----------------------------------------
    should "be able to be frozen" do
      assert_respond_to @component, :freeze
      assert_respond_to @component, :frozen?
    end
    
    should "not be frozen by default" do
      assert_equal false, @component.frozen?
    end
    
    context "which is frozen" do
      setup { @component.freeze }
      should "be frozen after calling freeze" do
        assert_equal true, @component.frozen?
      end
    
      should "raise an exception when being modified" do
        assert_raise RuntimeError do
          @component.requires('ignored')
        end
        assert_raise RuntimeError do
          @component.folder('ignored')
        end
        assert_raise RuntimeError do
          @component.namespace(:Ignored)
        end
      end
    end
    
    # ----------------------------------------
    # Loading dependencies
    # ----------------------------------------
    context "with some external requirements" do
      setup { @component.requires 'matrix' }
      should "ensure unloaded requirements are not already loaded" do
        assert_raise NameError do
          Matrix
        end
      end
      
      should "load external requirements when requested" do
        success = @component.load_external_dependencies
        assert_equal true, success
        assert_nothing_raised do
          Matrix
        end
      end
      
      should "only load requirements once" do
        success = @component.load_external_dependencies
        assert_equal true, success
        success = @component.load_external_dependencies
        assert_equal false, success
      end
    end
  end
end
