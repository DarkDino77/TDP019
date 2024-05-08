require 'test/unit'

require_relative "../nodes/operator_nodes.rb"


class TestArithmetic < Test::Unit::TestCase

    def test_adition
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 3)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        add_node1 = BLBinaryMethod.new(lh1, rh1, "addition")
        result = add_node1.eval(scope)

        assert_equal(8, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLFloat)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 3.2)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        add_node2 = BLBinaryMethod.new(lh2, rh2, "addition")
        result = add_node2.eval(scope)

        assert_equal(8, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh3 = scope.add(:lh3, BLFloat)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 4.6)
        $memory.set(addr_rh3, 3)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        add_node3 = BLBinaryMethod.new(lh3, rh3, "addition")
        result = add_node3.eval(scope)

        assert_in_delta(7.6, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))
    end

    def test_subtraction
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
       
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 3)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        add_node1 = BLBinaryMethod.new(lh1, rh1, "subtraction")
        result = add_node1.eval(scope)

        assert_equal(2, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLFloat)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 3.2)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        add_node2 = BLBinaryMethod.new(lh2, rh2, "subtraction")
        result = add_node2.eval(scope)

        assert_equal(1, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh3 = scope.add(:lh3, BLFloat)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 4.6)
        $memory.set(addr_rh3, 3)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        add_node3 = BLBinaryMethod.new(lh3, rh3, "subtraction")
        result = add_node3.eval(scope)

        assert_in_delta(1.6, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))
    end

    def test_multiplication
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 3)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        add_node1 = BLBinaryMethod.new(lh1, rh1, "multiplication")
        result = add_node1.eval(scope)

        assert_equal(15, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))
        
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLFloat)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 3.3)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        add_node2 = BLBinaryMethod.new(lh2, rh2, "multiplication")
        result = add_node2.eval(scope)

        assert_equal(16, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))


        addr_lh3 = scope.add(:lh3, BLFloat)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 4.6)
        $memory.set(addr_rh3, 3)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        add_node3 = BLBinaryMethod.new(lh3, rh3, "multiplication")
        result = add_node3.eval(scope)

        assert_in_delta(13.8, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))

    end

    def test_divition
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 3)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        add_node1 = BLBinaryMethod.new(lh1, rh1, "divition")
        result = add_node1.eval(scope)

        assert_in_delta(1.6666666, $memory.get(result), 0.000001)
        assert_equal(BLFloat, scope.type(result))

        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLFloat)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 3.3)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        add_node2 = BLBinaryMethod.new(lh2, rh2, "divition")
        result = add_node2.eval(scope)

        assert_in_delta(1.51515151, $memory.get(result), 0.00001)
        assert_equal(BLFloat, scope.type(result))

        addr_lh3 = scope.add(:lh3, BLFloat)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 9.0)
        $memory.set(addr_rh3, 4)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        add_node3 = BLBinaryMethod.new(lh3, rh3, "divition")
        result = add_node3.eval(scope)

        assert_in_delta(2.25, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))

    end

    def test_modulo
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 3)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        add_node1 = BLBinaryMethod.new(lh1, rh1, "modulo")
        result = add_node1.eval(scope)

        assert_equal(2, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLFloat)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 3.3)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        add_node2 = BLBinaryMethod.new(lh2, rh2, "modulo")
        result = add_node2.eval(scope)

        assert_equal(1, $memory.get(result))
        assert_equal(BLInteger, scope.type(result))

        addr_lh3 = scope.add(:lh3, BLFloat)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 9.2)
        $memory.set(addr_rh3, 4)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        add_node3 = BLBinaryMethod.new(lh3, rh3, "modulo")
        result = add_node3.eval(scope)

        assert_in_delta(1.2, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))

    end

    def test_combined_statement
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        # ((2.5 * 3) - (4 + 2)) / 3 = 0.5

        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 4)
        $memory.set(addr_rh1, 2)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")

        addr_lh2 = scope.add(:lh2, BLFloat)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 2.5)
        $memory.set(addr_rh2, 3)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")

        lh3 = BLBinaryMethod.new(lh2, rh2, "multiplication") #7.5
        rh3 = BLBinaryMethod.new(lh1, rh1, "addition") #6

        lh4 = BLBinaryMethod.new(lh3, rh3, "subtraction") #1.5

        addr_rh4 = scope.add(:rh4, BLInteger)
        $memory.set(addr_rh4, 3)
        rh4 = BLVarNode.new("rh4")

        final = BLBinaryMethod.new(lh4, rh4, "divition") #0.5
        
        result = final.eval(scope)

        assert_in_delta(0.5, $memory.get(result), 0.0000001)
        assert_equal(BLFloat, scope.type(result))

    end

end

class TestComparisonNodes < Test::Unit::TestCase

    def test_BLEqual
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLEqual.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(false, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLEqual.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(true, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLEqual.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(false, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

        
    end

    def test_BlNotEqual
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLNotEqual.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(true, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLNotEqual.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(false, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLNotEqual.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(true, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

    end 

    def test_BLLessThan
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLLessThan.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(true, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLLessThan.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(false, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLLessThan.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(false, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))
    end

    def test_BLLessThanOrEqual
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLLessThanOrEqual.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(true, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLLessThanOrEqual.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(true, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLLessThanOrEqual.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(false, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

    end

    def test_BLGreaterThan
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLGreaterThan.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(false, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLGreaterThan.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(false, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLGreaterThan.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(true, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

    end

    def test_BLGreaterThanOrEqual
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)
        
        #lh < rh
        addr_lh1 = scope.add(:lh1, BLInteger)
        addr_rh1 = scope.add(:rh1, BLInteger)
        $memory.set(addr_lh1, 5)
        $memory.set(addr_rh1, 7)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLGreaterThanOrEqual.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(false, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))
        

        #lh == rh
        addr_lh2 = scope.add(:lh2, BLInteger)
        addr_rh2 = scope.add(:rh2, BLInteger)
        $memory.set(addr_lh2, 5)
        $memory.set(addr_rh2, 5)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLGreaterThanOrEqual.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(true, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))
        
        
        #lh > rh
        addr_lh3 = scope.add(:lh3, BLInteger)
        addr_rh3 = scope.add(:rh3, BLInteger)
        $memory.set(addr_lh3, 7)
        $memory.set(addr_rh3, 5)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLGreaterThanOrEqual.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(true, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

    end
end

class TestLogicNodes < Test::Unit::TestCase
    def test_BLLogicAnd
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        # true, true
        addr_lh1 = scope.add(:lh1, BLBool)
        addr_rh1 = scope.add(:rh1, BLBool)
        $memory.set(addr_lh1, true)
        $memory.set(addr_rh1, true)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLLogicAnd.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(true, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))

        # true, false
        addr_lh2 = scope.add(:lh2, BLBool)
        addr_rh2 = scope.add(:rh2, BLBool)
        $memory.set(addr_lh2, true)
        $memory.set(addr_rh2, false)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLLogicAnd.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(false, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))

        # false, true
        addr_lh3 = scope.add(:lh3, BLBool)
        addr_rh3 = scope.add(:rh3, BLBool)
        $memory.set(addr_lh3, false)
        $memory.set(addr_rh3, true)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLLogicAnd.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(false, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

        # false, false
        addr_lh4 = scope.add(:lh4, BLBool)
        addr_rh4 = scope.add(:rh4, BLBool)
        $memory.set(addr_lh4, false)
        $memory.set(addr_rh4, false)
        lh4 = BLVarNode.new("lh4")
        rh4 = BLVarNode.new("rh4")
        node4 = BLLogicAnd.new(lh4, rh4)
        result4 = node4.eval(scope)

        assert_equal(false, $memory.get(result4))
        assert_equal(BLBool, scope.type(result4))

        # testing error
        # bool, integer
        addr_lh5 = scope.add(:lh5, BLBool)
        addr_rh5 = scope.add(:rh5, BLInteger)
        $memory.set(addr_lh5, true)
        $memory.set(addr_rh5, 1)
        lh5 = BLVarNode.new("lh5")
        rh5 = BLVarNode.new("rh5")
        node5 = BLLogicAnd.new(lh5, rh5)

        #assert_equal(true, $memory.get(result5))
        #assert_equal(BLBool, scope.type(result5))

        #result6 = BLLogicAnd.new(lh6, rh6)
        assert_raise(RuntimeError.new("And given an argument that is not a bool, argument types were bool and integer")){node5.eval(scope)}

        # integer, bool

        addr_lh7 = scope.add(:lh7, BLInteger)
        addr_rh7 = scope.add(:rh7, BLBool)
        $memory.set(addr_lh7, 1)
        $memory.set(addr_rh7, true)
        
        #lh7 = BLInteger.new(1)
        #rh7 = BLBool.new(true)
        lh7 = BLVarNode.new("lh7")
        rh7 = BLVarNode.new("rh7")
        node7 = BLLogicAnd.new(lh7, rh7)
        assert_raise(RuntimeError.new("And given an argument that is not a bool, argument types were integer and bool")){node7.eval(scope)}

        # float, float

        addr_lh8 = scope.add(:lh8, BLFloat)
        addr_rh8 = scope.add(:rh8, BLFloat)
        $memory.set(addr_lh8, 0.0)
        $memory.set(addr_rh8, 0.0)

        #lh8 = BLFloat.new(0)
        #rh8 = BLFloat.new(0)
        lh8 = BLVarNode.new("lh8")
        rh8 = BLVarNode.new("rh8")
        node8 = BLLogicAnd.new(lh8, rh8)
        assert_raise(RuntimeError.new("And given an argument that is not a bool, argument types were float and float")){node8.eval(scope)}
        
    end

    def test_BLLogicOr
        $memory = BLMemoryManager.new()
        scope = BLScope.new(1)

        # true, true
        addr_lh1 = scope.add(:lh1, BLBool)
        addr_rh1 = scope.add(:rh1, BLBool)
        $memory.set(addr_lh1, true)
        $memory.set(addr_rh1, true)
        lh1 = BLVarNode.new("lh1")
        rh1 = BLVarNode.new("rh1")
        node1 = BLLogicOr.new(lh1, rh1)
        result1 = node1.eval(scope)

        assert_equal(true, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))

        # true, false
        addr_lh2 = scope.add(:lh2, BLBool)
        addr_rh2 = scope.add(:rh2, BLBool)
        $memory.set(addr_lh2, true)
        $memory.set(addr_rh2, false)
        lh2 = BLVarNode.new("lh2")
        rh2 = BLVarNode.new("rh2")
        node2 = BLLogicOr.new(lh2, rh2)
        result2 = node2.eval(scope)

        assert_equal(true, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))

        # false, true
        addr_lh3 = scope.add(:lh3, BLBool)
        addr_rh3 = scope.add(:rh3, BLBool)
        $memory.set(addr_lh3, false)
        $memory.set(addr_rh3, true)
        lh3 = BLVarNode.new("lh3")
        rh3 = BLVarNode.new("rh3")
        node3 = BLLogicOr.new(lh3, rh3)
        result3 = node3.eval(scope)

        assert_equal(true, $memory.get(result3))
        assert_equal(BLBool, scope.type(result3))

        # false, false
        addr_lh4 = scope.add(:lh4, BLBool)
        addr_rh4 = scope.add(:rh4, BLBool)
        $memory.set(addr_lh4, false)
        $memory.set(addr_rh4, false)
        lh4 = BLVarNode.new("lh4")
        rh4 = BLVarNode.new("rh4")
        node4 = BLLogicOr.new(lh4, rh4)
        result4 = node4.eval(scope)

        assert_equal(false, $memory.get(result4))
        assert_equal(BLBool, scope.type(result4))


        # testing error
        # bool, integer
        addr_lh5 = scope.add(:lh5, BLBool)
        addr_rh5 = scope.add(:rh5, BLInteger)
        $memory.set(addr_lh5, true)
        $memory.set(addr_rh5, 1)
        lh5 = BLVarNode.new("lh5")
        rh5 = BLVarNode.new("rh5")
        node5 = BLLogicOr.new(lh5, rh5)

        assert_raise(RuntimeError.new("Or given an argument that is not a bool, argument types were bool and integer")){node5.eval(scope)}

        # integer, bool
        addr_lh6 = scope.add(:lh6, BLInteger)
        addr_rh6 = scope.add(:rh6, BLBool)
        $memory.set(addr_lh6, true)
        $memory.set(addr_rh6, 1)
        lh6 = BLVarNode.new("lh6")
        rh6 = BLVarNode.new("rh6")
        node6 = BLLogicOr.new(lh6, rh6)

        assert_raise(RuntimeError.new("Or given an argument that is not a bool, argument types were integer and bool")){node6.eval(scope)}

        # float, float
        addr_lh7 = scope.add(:lh7, BLFloat)
        addr_rh7 = scope.add(:rh7, BLFloat)
        $memory.set(addr_lh7, 0.0)
        $memory.set(addr_rh7, 1.0)
        lh7 = BLVarNode.new("lh7")
        rh7 = BLVarNode.new("rh7")
        node7 = BLLogicOr.new(lh7, rh7)

        assert_raise(RuntimeError.new("Or given an argument that is not a bool, argument types were float and float")){node7.eval(scope)}
        
    end

    def test_BLLogicNot
        $memory = BLMemoryManager.new()

        scope = BLScope.new(1)

        #true
        addr1 = scope.add(:var1, BLBool)
        $memory.set(addr1, true)
        var1 = BLVarNode.new("var1")
        node1 = BLLogicNot.new(var1)
        result1 = node1.eval(scope)

        assert_equal(false, $memory.get(result1))
        assert_equal(BLBool, scope.type(result1))

        #false
        addr2 = scope.add(:var2, BLBool)
        $memory.set(addr2, false)
        var2 = BLVarNode.new("var2")
        node2 = BLLogicNot.new(var2)
        result2 = node2.eval(scope)

        assert_equal(true, $memory.get(result2))
        assert_equal(BLBool, scope.type(result2))


        #integer
        addr3 = scope.add(:var3, BLInteger)
        $memory.set(addr3, 137)
        var3 = BLVarNode.new("var3")
        node3 = BLLogicNot.new(var3)
        assert_raise(RuntimeError.new("Cannot preform Not operation on integer, has to be a bool")){node3.eval(scope)}
    end
end