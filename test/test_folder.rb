require 'helper'

class TestFolder < Test::Unit::TestCase
  context "A new folder" do
    setup { @folder = Flow::Folder.new(Pathname.new('.'), ['folder']) }
    should "have no modules" do
      assert_equal 0, @folder.modules.size
    end

    context "with modules added" do
      setup { @folder.provides(:ModuleOne, :ModuleTwo) }
      should "store all modules added" do
        assert_equal 2, @folder.modules.size
      end
      
      context "and more modules added" do
        setup { @folder.provides(:ModuleThree, :ModuleFour) }
        should "store all new and existing modules" do
          assert_equal 4, @folder.modules.size
        end
      end
    end
  end
  
  context "A folder with a local base and single path" do
    setup { @folder = Flow::Folder.new(Pathname.new('.'), ['lib']) }
    should "have a local path" do
      assert_equal "lib", @folder.path
    end
  end
  
  context "A folder with a local base and multiple path components" do
    setup { @folder = Flow::Folder.new(Pathname.new('.'), ['lib', 'models', 'tests']) }
    should "have a local path" do
      assert_equal "lib/models/tests", @folder.path
    end
  end
  
  context "A folder with an absolute base and single path" do
    setup { @folder = Flow::Folder.new(Pathname.new('/tmp'), ['lib']) }
    should "have an absolute path" do
      assert_equal @folder.path, "/tmp/lib"
    end
  end
  
  context "A folder with an absolute base and multiple path components" do
    setup { @folder = Flow::Folder.new(Pathname.new('/tmp'), ['lib', 'models', 'tests']) }
    should "have a local path" do
      assert_equal @folder.path, "/tmp/lib/models/tests"
    end
  end
end
