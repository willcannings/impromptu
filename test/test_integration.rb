require 'helper'
require 'yaml'

class TestIntegration < Test::Unit::TestCase
  context "Loading the test.components file" do
    setup do
      Impromptu.reset
      Impromptu.define_components do
        parse_file 'test/framework/test.components'
      end
    end
    
    # ----------------------------------------
    # Loading component definitions
    # ----------------------------------------
    should "01 create four components" do
      assert_equal 4, Impromptu.components.size
    end
    
    should "02 have a single folder per component" do
      assert_equal 1, Impromptu.components['framework'].folders.size
      assert_equal 1, Impromptu.components['framework.extensions'].folders.size
      assert_equal 1, Impromptu.components['other'].folders.size
    end
    
    should "03 have a single require in the framework component" do
      assert_equal 1, Impromptu.components['framework'].requirements.size
    end
    
    should "04 have a namespace for the framework components" do
      assert_equal :Framework, Impromptu.components['framework'].namespace
      assert_equal :Framework, Impromptu.components['framework.extensions'].namespace
      assert_equal nil, Impromptu.components['other'].namespace
    end
    
    should "05 start tracking 8 files" do
      assert_equal 2, Impromptu.components['framework'].folders.first.files.size
      assert_equal 2, Impromptu.components['framework.extensions'].folders.first.files.size
      assert_equal 3, Impromptu.components['other'].folders.first.files.size
      assert_equal 1, Impromptu.components['private'].folders.first.files.size
    end
    
    should "06 load definitions for 9 resources" do
      assert Impromptu.root_resource.child?(:Framework)
      assert Impromptu.root_resource.child(:Framework).child?(:Extensions)
      assert Impromptu.root_resource.child(:Framework).child(:Extensions).child?(:Blog)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass2)
      assert Impromptu.root_resource.child?(:Load)
      assert Impromptu.root_resource.child?(:OtherName)
      assert Impromptu.root_resource.child?(:ModOne)
      assert Impromptu.root_resource.child?(:ModTwo)
    end
    
    should "07 correctly mark namespace resources" do
      assert_equal true,  Impromptu.root_resource.child(:Framework).namespace?
      assert_equal false, Impromptu.root_resource.child(:Framework).child(:Extensions).namespace?
      assert_equal false, Impromptu.root_resource.child(:Framework).child(:Extensions).child(:Blog).namespace?
      assert_equal false, Impromptu.root_resource.child(:Framework).child(:Klass).namespace?
      assert_equal false, Impromptu.root_resource.child(:Framework).child(:Klass2).namespace?
      assert_equal false, Impromptu.root_resource.child(:Load).namespace?
      assert_equal false, Impromptu.root_resource.child(:OtherName).namespace?
      assert_equal false, Impromptu.root_resource.child(:ModOne).namespace?
      assert_equal false, Impromptu.root_resource.child(:ModTwo).namespace?
    end
    
    should "08 keep all resources unloaded to start with" do
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass2').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Load').loaded?
      assert_equal false, Impromptu.root_resource.child(:'OtherName').loaded?
      assert_equal false, Impromptu.root_resource.child(:'ModOne').loaded?
      assert_equal false, Impromptu.root_resource.child(:'ModTwo').loaded?
    end
    
    should "09 have all resources specified by the correct number of files" do
      assert_equal 0, Impromptu.root_resource.child(:'Framework').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions::Blog').files.size
      assert_equal 2, Impromptu.root_resource.child(:'Framework::Klass').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Load').files.size
      assert_equal 2, Impromptu.root_resource.child(:'OtherName').files.size
      assert_equal 1, Impromptu.root_resource.child(:'ModOne').files.size
      assert_equal 1, Impromptu.root_resource.child(:'ModTwo').files.size
      assert_equal true, Impromptu.root_resource.child(:'Framework').implicitly_defined?
    end
    
    
    # ----------------------------------------
    # Loading/unloading
    # ----------------------------------------
    should "10 allow loading the implicitly defined framework module" do
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
      Impromptu.root_resource.child(:'Framework').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework').loaded?
      assert_nothing_raised do
        Framework
      end
    end
    
    should "11 load resources using associated files when required" do
      # ext
      Impromptu.root_resource.child(:'Framework::Extensions::Blog').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      assert_nothing_raised do
        Framework::Extensions
      end
      assert_nothing_raised do
        Framework::Extensions::Blog
      end
      
      # lib
      assert_raise NameError do
        CMath
      end
      Impromptu.root_resource.child(:'Framework::Klass').reload
      Impromptu.root_resource.child(:'Framework::Klass2').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework::Klass').loaded?
      assert_equal true, Impromptu.root_resource.child(:'Framework::Klass2').loaded?
      assert_nothing_raised do
        Framework::Klass
      end
      assert_nothing_raised do
        Framework::Klass2
      end
      assert_nothing_raised do
        CMath
      end
      
      # other
      Impromptu.root_resource.child(:Load).reload
      Impromptu.root_resource.child(:OtherName).reload
      Impromptu.root_resource.child(:ModOne).reload
      Impromptu.root_resource.child(:ModTwo).reload
      assert_equal true, Impromptu.root_resource.child(:Load).loaded?
      assert_equal true, Impromptu.root_resource.child(:OtherName).loaded?
      assert_equal true, Impromptu.root_resource.child(:ModOne).loaded?
      assert_equal true, Impromptu.root_resource.child(:ModTwo).loaded?
      assert_nothing_raised do
        Load
      end
      assert_nothing_raised do
        OtherName
      end
      assert_nothing_raised do
        ModOne
      end
      assert_nothing_raised do
        ModTwo
      end
    end
    
    should "12 load multiple files for a resource when required" do
      # Klass
      Impromptu.root_resource.child(:'Framework::Klass').reload
      assert_respond_to Framework::Klass, :standard_method
      assert_respond_to Framework::Klass, :overriden_method
      assert_respond_to Framework::Klass, :extension_method
      assert_equal 2, Framework::Klass.overriden_method
      
      # OtherName
      Impromptu.root_resource.child(:OtherName).reload
      assert_respond_to OtherName, :one
      assert_respond_to OtherName, :overriden_method
      assert_respond_to OtherName, :two
      assert_equal 4, OtherName.overriden_method
    end
    
    should "13 be able to unload implicit and explicit resources" do
      # explicit
      Impromptu.root_resource.child(:'Framework::Extensions::Blog').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      Impromptu.root_resource.child(:'Framework::Extensions').unload
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      
      # implicit
      Impromptu.root_resource.child(:'Framework').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework').loaded?
      Impromptu.root_resource.child(:'Framework').unload
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
    end
    
    should "14 be able to reload previously unloaded resources" do
      # implicit
      Impromptu.root_resource.child(:'Framework').reload
      Impromptu.root_resource.child(:'Framework').unload
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
      Impromptu.root_resource.child(:'Framework').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework').loaded?
      
      # explicit
      Impromptu.root_resource.child(:'Framework::Extensions::Blog').reload
      Impromptu.root_resource.child(:'Framework::Extensions').unload
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      Impromptu.root_resource.child(:'Framework::Extensions::Blog').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal true, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
    end
    
    
    # ----------------------------------------
    # Updating files/folders
    # ----------------------------------------
    
  end
end
