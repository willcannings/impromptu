require 'helper'

class TestComponentSet < Test::Unit::TestCase
  context "A set definition" do
    should "raise an exception with no block" do
      assert_raise RuntimeError do
        Flow::ComponentSet.define_components
      end
    end
    
    should "raise an exception when a component file does not exist" do
      assert_raise Errno::ENOENT do
        Flow::ComponentSet.define_components do
          parse_file(File.join(File.dirname(__FILE__), 'non_existent.components'))
        end
      end
    end
    
    should "raise an exception with simple circular dependencies" do
      assert_raise RuntimeError do
        Flow::ComponentSet.define_components do
          component 'test.one' do
            requires 'test.two'
          end
          component 'test.two' do
            requires 'test.one'
          end
        end
      end
    end
    
    should "raise an exception with distant circular dependencies" do
      assert_raise RuntimeError do
        Flow::ComponentSet.define_components do
          # first set of components are valid (here to ensure we catch circular dependencies on latter roots)
          component 'one.one' do
            requires 'one.two'
          end
          component 'one.two' do
          end
          
          # second graph with more distant dependencies
          component 'two.one' do
            requires 'two.two'
          end
          component 'two.two' do
            requires 'two.three', 'two.four'
          end
          component 'two.three' do
          end
          component 'two.four' do
            requires 'two.one'
          end
        end
      end
    end
  end
  
  
  context "The example component set" do
    setup do
      Flow::ComponentSet.define_components do
        parse_file(File.join(File.dirname(__FILE__), 'example_component_set.components'))
      end
      @components = Flow::ComponentSet.instance_variable_get('@components')
    end
    
    # ----------------------------------------
    # Test the component tree
    # ----------------------------------------
    should "have five components" do
      assert_equal 5, @components.size
    end
    
    should "have the undefined rfc component automatically created" do
      assert_not_nil @components['rfc']
    end
    
    should "have the test component have test.one and test.two as children" do
      assert @components['test'].children.include?(@components['test.one'])
      assert @components['test'].children.include?(@components['test.two'])
      assert_equal @components['test'], @components['test.one'].parent
      assert_equal @components['test'], @components['test.two'].parent
    end
    
    should "have the rfc component have rfc.one as a child" do
      assert @components['rfc'].children.include?(@components['rfc.one'])
      assert_equal @components['rfc'], @components['rfc.one'].parent
    end
    
    # ----------------------------------------
    # Test namespaces
    # ----------------------------------------
    should "set the test namespaces correctly" do
      assert_equal 'Test', @components['test'].namespace
      assert_equal 'Test::Two', @components['test.two'].namespace
    end
    
    should "set the rfc namespaces correctly" do
      assert_equal 'RFC822', @components['rfc.one'].namespace
    end
    
    
    # ----------------------------------------
    # Test requires are correctly resolved
    # ----------------------------------------
    should "have the test.one requirements correctly resolved" do
      assert @components['test.one'].requirements.include?(@components['test.two'])
      assert @components['test.one'].requirements.include?(@components['rfc.one'])
    end
    
    # ----------------------------------------
    # Test freezing
    # ----------------------------------------
    should "have all components frozen" do
      @components.values.each do |component|
        assert component.frozen?
      end
    end
  end
end
