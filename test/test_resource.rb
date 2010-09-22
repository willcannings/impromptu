require 'helper'

class TestResource < Test::Unit::TestCase
  # ----------------------------------------
  # Root resource and API
  # ----------------------------------------
  context "The root resource" do
    should "exist" do
      assert_not_nil Impromptu.root_resource
    end
    
    should "respond to children?" do
      assert_respond_to Impromptu.root_resource, :children?
    end
    
    should "respond to child?" do
      assert_respond_to Impromptu.root_resource, :child?
    end
    
    should "respond to child" do
      assert_respond_to Impromptu.root_resource, :child
    end
    
    should "respond to reference" do
      assert_respond_to Impromptu.root_resource, :reference
    end
    
    should "respond to get_or_create_child" do
      assert_respond_to Impromptu.root_resource, :get_or_create_child
    end
    
    should "be a root resource" do
      assert Impromptu.root_resource.root?
    end
    
    should "reference Object" do
      assert_equal Object, Impromptu.root_resource.reference
    end
  end
  
  # ----------------------------------------
  # Hash and equality
  # ----------------------------------------
  context "Two resources" do
    setup { @one = Impromptu::Resource.new(:Object, nil) }
    context "which refer to the same symbol" do
      setup { @two = Impromptu::Resource.new(:Object, nil) }
      should "be equal" do
        assert @one.eql?(@two)
        assert @two.eql?(@one)
      end
      
      should "have equal hashes" do
        assert @one.hash == @two.hash
      end
    end
    
    context "which refer to different symbols" do
      setup { @two = Impromptu::Resource.new(:Test, @one) }
      should "not be equal" do
        assert_equal false, @one.eql?(@two)
        assert_equal false, @two.eql?(@one)
      end
      
      should "have different hashes if their symbols have different hashes" do
        assert_equal false, @one.hash == @two.hash
      end
    end
  end
  
  # ----------------------------------------
  # Creating and retrieving resources
  # ----------------------------------------
  context "A root resource" do
    setup { @root = Impromptu::Resource.new(:Object, nil) }
    context "with a child resource" do
      setup { @child = @root.get_or_create_child(:Klass) }
      should "have children" do
        assert @root.children?
      end
      
      should "have a child with the name just created" do
        assert @root.child?(:Klass)
      end
      
      should "be able to retrieve a reference to the child resource" do
        assert_not_nil @root.child(:Klass)
        assert_instance_of Impromptu::Resource, @root.child(:Klass)
      end
    end
    
    context "with a deep chain of child resources" do
      setup { @base = @root.get_or_create_child(:'One::Two::Three::Four') }
      should "have children" do
        assert @root.children?
      end
      
      should "be able to retrieve a reference to each resource just created" do
        # One
        assert_not_nil @root.child(:'One')
        assert_instance_of Impromptu::Resource, @root.child(:'One')
        
        # One::Two
        assert_not_nil @root.child(:'One::Two')
        assert_instance_of Impromptu::Resource, @root.child(:'One::Two')
        
        # One::Two::Three
        assert_not_nil @root.child(:'One::Two::Three')
        assert_instance_of Impromptu::Resource, @root.child(:'One::Two::Three')
        
        # One::Two::Three::Four
        assert_not_nil @root.child(:'One::Two::Three::Four')
        assert_instance_of Impromptu::Resource, @root.child(:'One::Two::Three::Four')
      end
    end
  end
end
