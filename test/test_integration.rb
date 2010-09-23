require 'helper'

class TestIntegration < Test::Unit::TestCase
  context "Loading the test.components file" do
    setup do
      Impromptu.define_components do
        parse_file 'test/framework/test.components'
      end
    end
    
    should "01 create two components" do
      assert_equal 2, Impromptu.components.size
    end
    
    should "02 have a single folder per component" do
      assert_equal 1, Impromptu.components['framework'].folders.size
      assert_equal 1, Impromptu.components['framework.extensions'].folders.size
    end
    
    should "03 have a single require in the framework component" do
      assert_equal 1, Impromptu.components['framework'].requirements.size
    end
    
    should "04 have a namespace for both components" do
      assert_equal :Framework, Impromptu.components['framework'].namespace
      assert_equal :Framework, Impromptu.components['framework.extensions'].namespace
    end
    
    should "05 start tracking 4 files" do
      assert_equal 2, Impromptu.components['framework'].folders.first.files.size
      assert_equal 2, Impromptu.components['framework.extensions'].folders.first.files.size
    end
    
    should "06 load definitions for 5 resources" do
      assert Impromptu.root_resource.child?(:Framework)
      assert Impromptu.root_resource.child(:Framework).child?(:Extensions)
      assert Impromptu.root_resource.child(:Framework).child(:Extensions).child?(:Blog)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass2)
    end
    
    should "07 keep all resources unloaded to start with" do
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass2').loaded?
    end
    
    should "08 have all resources specified by one file, and the namespace specified by none" do
      assert_equal 0, Impromptu.root_resource.child(:'Framework').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions::Blog').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
      assert_equal true, Impromptu.root_resource.child(:'Framework').implicitly_defined?
    end
    
    should "09 allow loading the implicitly defined framework module" do
      assert_equal false, Impromptu.root_resource.child(:'Framework').loaded?
      Impromptu.root_resource.child(:'Framework').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework').loaded?
      assert_nothing_raised do
        Framework
      end
    end
    
    should "10 load resources using associated files when required" do
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
    end
  end
end
