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
          component 'demo.one' do
            requires 'demo.two'
          end
          component 'demo.two' do
            requires 'demo.one'
          end
        end
      end
    end
    
    should "raise an exception with distant circular dependencies" do
      assert_raise RuntimeError do
        Flow::ComponentSet.define_components do
          # first set of components are valid (here to ensure we catch circular dependencies on latter roots)
          component 'demo.one' do
            requires 'demo.two'
          end
          component 'demo.two' do
          end
          
          # second graph with more distant dependencies
          component 'demo.one' do
            requires 'demo.two'
          end
          component 'demo.two' do
            requires 'demo.three', 'demo.four'
          end
          component 'demo.three' do
          end
          component 'demo.four' do
            requires 'demo.one'
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
      @modules = Flow::ComponentSet.instance_variable_get('@modules')
    end
    
    # ----------------------------------------
    # Test the component tree
    # ----------------------------------------
    should "have five components" do
      assert_equal 6, @components.size
    end
    
    should "have the undefined rfc component automatically created" do
      assert_not_nil @components['rfc']
    end
    
    should "have the impromptu component have impromptu.one and impromptu.two as children" do
      assert @components['impromptu'].children.include?(@components['impromptu.one'])
      assert @components['impromptu'].children.include?(@components['impromptu.two'])
      assert_equal @components['impromptu'], @components['impromptu.one'].parent
      assert_equal @components['impromptu'], @components['impromptu.two'].parent
    end
    
    should "have the rfc component have rfc.one and rfc.two as a child" do
      assert @components['rfc'].children.include?(@components['rfc.one'])
      assert @components['rfc'].children.include?(@components['rfc.two'])
      assert_equal @components['rfc'], @components['rfc.one'].parent
      assert_equal @components['rfc'], @components['rfc.two'].parent
    end
    
    # ----------------------------------------
    # Test namespaces
    # ----------------------------------------
    should "set the impromptu namespaces correctly" do
      assert_equal 'Impromptu', @components['impromptu'].namespace
      assert_equal 'Impromptu::Two', @components['impromptu.two'].namespace
    end
    
    should "set the rfc namespaces correctly" do
      assert_equal 'RFC', @components['rfc.one'].namespace
      assert_equal '', @components['rfc.two'].namespace
    end
    
    
    # ----------------------------------------
    # Test requires are correctly resolved
    # ----------------------------------------
    should "have the impromptu.one requirements correctly resolved" do
      assert @components['impromptu.one'].requirements.include?(@components['impromptu.two'])
      assert @components['impromptu.one'].requirements.include?(@components['rfc.one'])
    end
    
    # ----------------------------------------
    # Test freezing
    # ----------------------------------------
    should "have all components frozen" do
      @components.values.each do |component|
        assert component.frozen
      end
    end
    
    # ----------------------------------------
    # Test module -> component references
    # ----------------------------------------
    should "have modules A and B reference impromptu.one" do
      assert_equal @components['impromptu.one'], @modules['Impromptu::A']
      assert_equal @components['impromptu.one'], @modules['Impromptu::B']
    end
    
    should "have modules C and D reference impromptu.two" do
      assert_equal @components['impromptu.two'], @modules['Impromptu::Two::C']
      assert_equal @components['impromptu.two'], @modules['Impromptu::Two::D']
    end
    
    should "have module E reference rfc.one" do
      assert_equal @components['rfc.one'], @modules['RFC::E']
    end
    
    should "have module F and RFC822::G reference rfc.two" do
      assert_equal @components['rfc.two'], @modules['F']
      assert_equal @components['rfc.two'], @modules['RFC822::G']
    end
    
    # ----------------------------------------
    # Test no modules currently exist
    # ----------------------------------------
    should "have no modules initially available in the object space" do
      assert_equal false, Module.constants.include?("Impromptu")
      assert_equal false, Module.constants.include?("RFC")
      assert_equal false, Module.constants.include?("F")
      assert_equal false, Module.constants.include?("RFC822")
    end
    
    should "not raise any exceptions when requesting modules provided by components" do
      assert_nothing_raised do
        Object.const_missing :'Impromptu::A'
        Impromptu::A
        
        Object.const_missing :'Impromptu::B'
        Impromptu::B
        
        Object.const_missing :'Impromptu::Two::C'
        Impromptu::Two::C
        
        Object.const_missing :'Impromptu::Two::D'
        Impromptu::Two::D
        
        Object.const_missing :'RFC::E'
        RFC::E
        
        Object.const_missing :'F'
        F
        
        Object.const_missing :'RFC822::G'
        RFC822::G
      end
    end
  end
end
