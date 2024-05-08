require 'test/unit'

require_relative "../nodes/variable_nodes.rb"

class TestList < Test::Unit::TestCase
    def test_reserve
        $memory = BLMemoryManager.new()
        signature = 100
        scope = BLScope.new(signature)

        addr = BLList.reserve(signature, BLInteger)
        assert_equal(0, addr)
        assert_equal(100, $memory.get(addr))
        assert_equal(BLInteger, $memory.get(addr + 1))
        assert_equal(0, $memory.get(addr + 2))
        assert_equal(nil, $memory.get(addr + 3))
    end
    
    def test_init
        $memory = BLMemoryManager.new()
        signature = 101
        scope = BLScope.new(signature)

        addr = $memory.reserve(signature, 4)
        BLList.init(addr, signature, BLInteger)
        assert_equal(101, $memory.get(addr))
        assert_equal(BLInteger, $memory.get(addr + 1))
        assert_equal(0, $memory.get(addr + 2))
        assert_equal(nil, $memory.get(addr + 3))
    end
    
    def test_index
        $memory = BLMemoryManager.new()
        signature = 1
        scope = BLScope.new(signature)
        
        addr = BLList.reserve(signature, BLInteger)
        BLList.insert(addr, 0, scope.temp(BLInteger, 10), scope)
        BLList.insert(addr, 1, scope.temp(BLInteger, 11), scope)
        BLList.insert(addr, 2, scope.temp(BLInteger, 12), scope)
        
        assert_equal(10, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(12, $memory.get(BLList.index(addr, 2, scope)))
    end

    def test_add
        $memory = BLMemoryManager.new()
        signature = 1
        scope = BLScope.new(signature)

        addr = BLList.reserve(signature, BLInteger)
        BLList.insert(addr, 0, scope.temp(BLInteger, 10), scope)
        BLList.insert(addr, 1, scope.temp(BLInteger, 11), scope)
        BLList.insert(addr, 2, scope.temp(BLInteger, 12), scope)

        assert_equal(10, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(12, $memory.get(BLList.index(addr, 2, scope)))

        BLList.insert(addr, 2, scope.temp(BLInteger, 13), scope)
        BLList.insert(addr, 0, scope.temp(BLInteger, 14), scope)

        assert_equal(14, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(10, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 2, scope)))
        assert_equal(13, $memory.get(BLList.index(addr, 3, scope)))
        assert_equal(12, $memory.get(BLList.index(addr, 4, scope)))

    end

    def test_remove
        $memory = BLMemoryManager.new()
        signature = 1
        scope = BLScope.new(signature)

        addr = BLList.reserve(signature, BLInteger)
        BLList.insert(addr, 0, scope.temp(BLInteger, 10), scope)
        BLList.insert(addr, 1, scope.temp(BLInteger, 11), scope)
        BLList.insert(addr, 2, scope.temp(BLInteger, 12), scope)
        BLList.insert(addr, 3, scope.temp(BLInteger, 13), scope)

        assert_equal(10, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(12, $memory.get(BLList.index(addr, 2, scope)))
        assert_equal(13, $memory.get(BLList.index(addr, 3, scope)))

        BLList.remove(addr, 2, scope)

        assert_equal(10, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(13, $memory.get(BLList.index(addr, 2, scope)))

        BLList.remove(addr, 0, scope)

        assert_equal(11, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(13, $memory.get(BLList.index(addr, 1, scope)))

        BLList.remove(addr, 1, scope)

        assert_equal(11, $memory.get(BLList.index(addr, 0, scope)))
        
        BLList.remove(addr, 0, scope)
        
        assert_equal(nil, $memory.get(addr + 3))
        
        assert_raise(RuntimeError.new("Index out of range")){BLList.remove(addr, 99, scope)}
       
    end

    def test_copy
        $memory = BLMemoryManager.new()
        signature = 1
        scope = BLScope.new(signature)
        
        addr = BLList.reserve(signature, BLInteger)
        BLList.insert(addr, 0, scope.temp(BLInteger, 10), scope)
        BLList.insert(addr, 1, scope.temp(BLInteger, 11), scope)
        BLList.insert(addr, 2, scope.temp(BLInteger, 12), scope)

        assert_equal(10, $memory.get(BLList.index(addr, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr, 1, scope)))
        assert_equal(12, $memory.get(BLList.index(addr, 2, scope)))

        addr_2 = BLList.reserve(1, nil)
        BLList.copy(addr, addr_2)

        assert_equal(10, $memory.get(BLList.index(addr_2, 0, scope)))
        assert_equal(11, $memory.get(BLList.index(addr_2, 1, scope)))
        assert_equal(12, $memory.get(BLList.index(addr_2, 2, scope)))
    end
end