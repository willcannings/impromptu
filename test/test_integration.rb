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
    should "01 create five components" do
      assert_equal 5, Impromptu.components.size
    end
    
    should "02 have the correct number of folders per component" do
      assert_equal 2, Impromptu.components['framework'].folders.size
      assert_equal 1, Impromptu.components['framework.extensions'].folders.size
      assert_equal 1, Impromptu.components['other'].folders.size
      assert_equal 1, Impromptu.components['private'].folders.size
      assert_equal 1, Impromptu.components['folder_namespace'].folders.size
    end
    
    should "03 have a single require in the framework component" do
      assert_equal 1, Impromptu.components['framework'].requirements.size
    end
    
    should "04 have a namespace for the framework components" do
      assert_equal :Framework, Impromptu.components['framework'].namespace
      assert_equal :Framework, Impromptu.components['framework.extensions'].namespace
      assert_equal nil, Impromptu.components['other'].namespace
    end
    
    should "05 start tracking 11 files" do
      assert_equal 2, Impromptu.components['framework'].folders.first.files.size
      assert_equal 2, Impromptu.components['framework.extensions'].folders.first.files.size
      assert_equal 3, Impromptu.components['other'].folders.first.files.size
      assert_equal 2, Impromptu.components['private'].folders.first.files.size
      assert_equal 2, Impromptu.components['folder_namespace'].folders.first.files.size
    end
    
    should "06 load definitions for 13 resources" do
      assert Impromptu.root_resource.child?(:Framework)
      assert Impromptu.root_resource.child(:Framework).child?(:Extensions)
      assert Impromptu.root_resource.child(:Framework).child(:Extensions).child?(:Blog)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass)
      assert Impromptu.root_resource.child(:Framework).child?(:Klass2)
      assert Impromptu.root_resource.child(:Framework).child?(:Preload)
      assert Impromptu.root_resource.child?(:Load)
      assert Impromptu.root_resource.child?(:OtherName)
      assert Impromptu.root_resource.child?(:ModOne)
      assert Impromptu.root_resource.child?(:ModTwo)
      assert Impromptu.root_resource.child?(:Another)
      assert Impromptu.root_resource.child(:Namespace)
      assert Impromptu.root_resource.child(:Namespace).child?(:Stream)
      assert Impromptu.root_resource.child(:Namespace).child?(:TwoNames)
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
      assert_equal false, Impromptu.root_resource.child(:Another).namespace?
      assert_equal true,  Impromptu.root_resource.child(:Namespace).namespace?
      assert_equal false, Impromptu.root_resource.child(:Namespace).child(:Stream).namespace?
      assert_equal false, Impromptu.root_resource.child(:Namespace).child(:TwoNames).namespace?
    end
    
    should "08 keep all non-preloaded resources unloaded to start with, and preload otherwise" do
      # normal, non preloaded resources
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Extensions::Blog').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Framework::Klass2').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Load').loaded?
      assert_equal false, Impromptu.root_resource.child(:'OtherName').loaded?
      assert_equal false, Impromptu.root_resource.child(:'ModOne').loaded?
      assert_equal false, Impromptu.root_resource.child(:'ModTwo').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Another').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Namespace').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Namespace::Stream').loaded?
      assert_equal false, Impromptu.root_resource.child(:'Namespace::TwoNames').loaded?
      
      # preloaded resources are the opposite of this
      assert Impromptu.root_resource.child(:'Framework').loaded?
      assert Impromptu.root_resource.child(:'Framework::Preload').loaded?
    end

    should "09 have all resources specified by the correct number of files" do
      assert_equal 0, Impromptu.root_resource.child(:'Framework').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Extensions::Blog').files.size
      assert_equal 2, Impromptu.root_resource.child(:'Framework::Klass').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Preload').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Load').files.size
      assert_equal 2, Impromptu.root_resource.child(:'OtherName').files.size
      assert_equal 1, Impromptu.root_resource.child(:'ModOne').files.size
      assert_equal 1, Impromptu.root_resource.child(:'ModTwo').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Another').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Namespace::Stream').files.size
      assert_equal 1, Impromptu.root_resource.child(:'Namespace::TwoNames').files.size
      assert_equal true, Impromptu.root_resource.child(:'Framework').implicitly_defined?
      assert_equal true, Impromptu.root_resource.child(:'Namespace').implicitly_defined?
    end
    
    
    # ----------------------------------------
    # Loading/unloading
    # ----------------------------------------
    should "10 allow loading the implicitly namespace modules" do
      Impromptu.root_resource.child(:'Framework').reload
      assert_equal true, Impromptu.root_resource.child(:'Framework').loaded?
      assert_nothing_raised do
        Framework
      end
      
      assert_equal false, Impromptu.root_resource.child(:'Namespace').loaded?
      Impromptu.root_resource.child(:'Namespace').reload
      assert_equal true, Impromptu.root_resource.child(:'Namespace').loaded?
      assert_nothing_raised do
        Namespace
      end
    end
    
    should "11 load resources using associated files when required" do
      # preloaded resource
      assert_nothing_raised do
        Framework::Preload
      end
      assert_respond_to Framework::Preload, :method
      assert Framework::Preload.method
      
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
      
      # private
      Impromptu.root_resource.child(:Another).reload
      assert_equal true, Impromptu.root_resource.child(:Another).loaded?
      assert_nothing_raised do
        Another
      end
      
      # folder namespace
      Impromptu.root_resource.child(:'Namespace::Stream').reload
      Impromptu.root_resource.child(:'Namespace::TwoNames').reload
      assert_equal true, Impromptu.root_resource.child(:'Namespace::Stream').loaded?
      assert_equal true, Impromptu.root_resource.child(:'Namespace::TwoNames').loaded?
      assert_nothing_raised do
        Namespace::Stream
      end
      assert_nothing_raised do
        Namespace::TwoNames
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
    
    should "15 automatically reload preloaded resources when their parent is reloaded" do
      # ensure the preloaded resource is in fact preloaded
      assert Impromptu.root_resource.child(:'Framework').loaded?
      assert Impromptu.root_resource.child(:'Framework::Preload').loaded?
      assert_nothing_raised do
        Framework::Preload
      end
      
      # reload the parent resource and ensure the preloaded resource is still available
      Impromptu.root_resource.child(:'Framework').reload
      assert Impromptu.root_resource.child(:'Framework').loaded?
      assert Impromptu.root_resource.child(:'Framework::Preload').loaded?
      assert_nothing_raised do
        Framework::Preload
      end
    end
    
    
    # ----------------------------------------
    # Updating files
    # ----------------------------------------
    context "and changing the definition of klass" do
      setup do
        Impromptu.root_resource.child(:'Framework::Klass').reload
        new_klass = File.open('test/framework/copies/new_klass.rb').read
        File.open('test/framework/lib/klass.rb', 'w') do |file|
          file.write new_klass
        end
      end
      
      teardown do
        old_klass = File.open('test/framework/copies/original_klass.rb').read
        File.open('test/framework/lib/klass.rb', 'w') do |file|
          file.write old_klass
        end
      end
      
      should "reload a class definition correctly when a file is changed" do        
        # update impromptu and test the new klass is loaded
        assert_respond_to Framework::Klass, :standard_method
        assert_equal 2, Framework::Klass.overriden_method
        Impromptu.update
        assert_respond_to Framework::Klass, :new_method
        assert_equal false, Framework::Klass.respond_to?(:standard_method)
        assert_equal 2, Framework::Klass.overriden_method
      end
    end
    
    
    # ----------------------------------------
    # Adding files
    # ----------------------------------------
    context "and adding a new file to a reloadable folder" do
      setup do
        FileUtils.mv 'test/framework/copies/new_unseen.rb', 'test/framework/private/unseen.rb'
      end
      
      teardown do
        FileUtils.mv 'test/framework/private/unseen.rb', 'test/framework/copies/new_unseen.rb'
      end
      
      should "make the resource from the new file available for loading" do
        assert_equal false, Impromptu.root_resource.child?(:'Framework::Unseen')
        Impromptu.update
        assert_equal true, Impromptu.root_resource.child?(:'Framework::Unseen')
        Impromptu.root_resource.child(:'Framework::Unseen').reload
        assert Framework::Unseen.test_method
      end
    end
    
    context "and adding files to an explicitly defined folder" do
      setup do
        FileUtils.mv 'test/framework/copies/new_unseen.rb', 'test/framework/other/unseen.rb'
      end
      
      teardown do
        FileUtils.mv 'test/framework/other/unseen.rb', 'test/framework/copies/new_unseen.rb'
      end
      
      should "not make add a file definition to the folder" do
        assert_equal 3, Impromptu.components['other'].folders.first.files.size
        Impromptu.update
        assert_equal 3, Impromptu.components['other'].folders.first.files.size
      end
    end
    
    
    # ----------------------------------------
    # Removing files
    # ----------------------------------------
    context "and removing a file from a reloadable folder" do
      teardown do
        FileUtils.mv 'test/framework/copies/klass2.rb', 'test/framework/lib/group/klass2.rb'
      end
      
      should "make the resource from the old unavailable since its definition has been removed" do
        # ensure the resource exists and load it
        assert_equal true, Impromptu.root_resource.child?(:'Framework::Klass2')
        Impromptu.root_resource.child(:'Framework::Klass2').reload
        assert_nothing_raised do
          Framework::Klass2
        end
        
        # update and see the missing file
        FileUtils.mv 'test/framework/lib/group/klass2.rb', 'test/framework/copies/klass2.rb'
        Impromptu.update
        assert_equal false, Impromptu.root_resource.child?(:'Framework::Klass2')
        assert_raise NameError do
          Framework::Klass2
        end
      end
    end
    
    
    # ----------------------------------------
    # Adding a file to a previously defined
    # resource
    # ----------------------------------------
    context "and adding a file to a previously defined resource" do
      setup do
        Impromptu.root_resource.child(:'Framework::Klass2').reload
        FileUtils.mv 'test/framework/copies/extra_klass2.rb', 'test/framework/private/klass2.rb'
      end
      
      teardown do
        FileUtils.mv 'test/framework/private/klass2.rb', 'test/framework/copies/extra_klass2.rb'
      end
      
      should "extend the definition and the list of files implementing the resource" do
        # existing definition
        assert Impromptu.root_resource.child?(:'Framework::Klass2')
        assert_equal 1, Impromptu.root_resource.child(:'Framework::Klass2').files.size
        assert_equal false, Framework::Klass2.respond_to?(:new_method)
        
        # extend with new definition
        Impromptu.update
        assert_equal 2, Impromptu.root_resource.child(:'Framework::Klass2').files.size
        assert Framework::Klass2.respond_to?(:new_method)
        assert Framework::Klass2.new_method
      end
    end
  end
end
