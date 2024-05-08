require 'test/unit'

require_relative "../managers.rb"

class TestMemory < Test::Unit::TestCase
    
    #def test_reserve

    #    $memory = BLMemoryManager.new
    #    signature = 100 
    #    addr = BLList.reserve(signature, BLInteger )
    #    assert_equal(100, $memory.get(addr))


    #end  

    def setup
        @memory_manager = BLMemoryManager.new
    end

    def test_reserve_and_release
        
        address = @memory_manager.reserve(1, 3, 100)
        assert_equal(0, address) 
        assert_equal(100, @memory_manager.get(address))

        @memory_manager.release(1, address)
        assert_raise(RuntimeError.new("Accessing unreserved memory at address 0")) {@memory_manager.get(address) } 

        new_address = @memory_manager.reserve(2, 1, 200)
        assert_equal(200, @memory_manager.get(new_address))
    end


    #def test_release

    #end



end