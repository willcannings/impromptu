require 'helper'

class TestFolder < Test::Unit::TestCase
  context "A new folder" do
    setup { @folder = Flow::Folder.new('/folder') }
    should "have no modules" do
      assert_equal 0, @folder.modules.size
    end
    
    should "have a path" do
      assert_not_nil @folder.path
    end
    
    should "respond to provides" do
      assert_respond_to @folder, :provides
    end

    context "with modules added" do
      setup { @folder.provides(:ModuleOne, :ModuleTwo) }
      should "store all modules added" do
        assert_equal 2, @folder.modules.size
      end
      
      context "and more, overlapping modules added" do
        setup { @folder.provides(:ModuleThree, :ModuleOne) }
        should "store all new and existing unique modules" do
          assert_equal 3, @folder.modules.size
        end
      end
    end
  end
end
