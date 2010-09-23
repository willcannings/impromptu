require 'helper'

class TestOrderedSet < Test::Unit::TestCase
  context "An ordered set" do
    setup { @set = Impromptu::OrderedSet.new }
    
    # ----------------------------------------
    # API
    # ----------------------------------------
    should "respond to push" do
      assert_respond_to @set, :push
    end
    
    should "respond to <<" do
      assert_respond_to @set, :<<
    end
    
    should "respond to merge" do
      assert_respond_to @set, :merge
    end
    
    should "respond to delete" do
      assert_respond_to @set, :delete
    end
    
    should "respond to to_a" do
      assert_respond_to @set, :to_a
    end
    
    should "respond to each" do
      assert_respond_to @set, :each
    end
    
    should "respond to size" do
      assert_respond_to @set, :size
    end
    
    should "respond to empty?" do
      assert_respond_to @set, :empty?
    end
    
    # ----------------------------------------
    # Core usage
    # ----------------------------------------
    should "be able to have items added" do
      assert_equal 1, @set << 1
      assert_equal 2, @set.push(2)
      assert_equal 2, @set.size
    end
    
    should "only allow an item to be added once" do
      assert_equal 1, @set << 1
      assert_equal 1, @set.push(1)
      assert_equal 1, @set.size
    end
    
    should "store items in order" do
      @set << 1
      @set << 2
      assert_equal [1,2], @set.to_a
    end
    
    should "be able to delete items" do
      @set << 1
      assert_equal 1, @set.size
      @set.delete(1)
      assert_equal 0, @set.size
      assert_equal true, @set.empty?
    end
    
    should "correctly implement empty?" do
      assert_equal true, @set.empty?
      @set << 1
      assert_equal false, @set.empty?
    end
    
    should "correctly implement include?" do
      @set << 1
      assert_equal true, @set.include?(1)
      assert_equal false, @set.include?(2)
    end
    
    should "be able to be iterated over, in order of insertion" do
      items = []
      @set << 1
      @set << 2
      @set.each do |item|
        items << item
      end
      assert_equal [1,2], items
    end
  end
end
