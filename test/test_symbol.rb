require 'helper'

class TestResource < Test::Unit::TestCase
  context "A symbol" do
    setup { @symbol = :ASymbolWhichDoesntNormallyExist }
    
    # ----------------------------------------
    # API
    # ----------------------------------------
    should "respond to nested?" do
      assert_respond_to @symbol, :nested?
    end
    
    should "respond to unnested?" do
      assert_respond_to @symbol, :unnested?
    end
    
    should "respond to nested_symbols" do
      assert_respond_to @symbol, :nested_symbols
    end
    
    should "respond to base_symbol" do
      assert_respond_to @symbol, :base_symbol
    end
    
    should "respond to root_symbol" do
      assert_respond_to @symbol, :root_symbol
    end
    
    should "respond to each_namespaced_symbol" do
      assert_respond_to @symbol, :each_namespaced_symbol
    end
    
    # ----------------------------------------
    # Unnested symbol
    # ----------------------------------------
    context "which isn't nested" do
      should "return false for nested?" do
        assert_equal false, @symbol.nested?
      end
      
      should "return true for unnested?" do
        assert @symbol.unnested?
      end
      
      should "return an array of a single symbol from nested_symbols" do
        assert_instance_of Array, @symbol.nested_symbols
        assert_equal 1, @symbol.nested_symbols.size
        assert_instance_of Symbol, @symbol.nested_symbols.first
      end
      
      should "return itself for base_symbol" do
        assert_equal @symbol, @symbol.base_symbol
      end
      
      should "return itself for root_symbol" do
        assert_equal @symbol, @symbol.root_symbol
      end
    end
    
    # ----------------------------------------
    # Nested symbol
    # ----------------------------------------
    context "which is nested" do
      setup { @symbol = :'TopLevel::BottomLevel' }
      should "return true for nested?" do
        assert @symbol.nested?
      end
      
      should "return false for unnested?" do
        assert_equal false, @symbol.unnested?
      end
      
      should "return an array of multiple symbols from nested_symbols" do
        assert_instance_of Array, @symbol.nested_symbols
        assert_equal 2, @symbol.nested_symbols.size
        assert_instance_of Symbol, @symbol.nested_symbols[0]
        assert_instance_of Symbol, @symbol.nested_symbols[1]
      end
      
      should "return the first nested name for root_symbol" do
        assert_equal :TopLevel, @symbol.root_symbol
      end
      
      should "return the last nested name for base_symbol" do
        assert_equal :BottomLevel, @symbol.base_symbol
      end
      
      should "return consecutive namespaced symbols when calling each_namespaced_symbol" do
        symbols = []
        @symbol.each_namespaced_symbol do |symbol|
          symbols << symbol
        end
        
        assert_equal [:TopLevel, :'TopLevel::BottomLevel'], symbols
      end
    end
  end  
end
