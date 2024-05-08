require_relative "./nodes.rb"
require_relative "../runtime.rb"

class BLVarInit
    def initialize(type, name, extra = nil)
        @type = type
        @name = name.to_sym
        @extra = extra
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        addr = scope.add(@name, @type)
        if(@type < BLDataStructure)
            @type.init(addr, scope.signature, @extra)
        else
            @type.init(addr, scope.signature)
        end
        return addr
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        if(@extra != nil)
            puts "Var init: #{@type}<#{@extra}> #{@name}"
        else
            puts "Var init: #{@type} #{@name}"
        end
    end
end

class BLVarNode
    def initialize(name)
        @name = name.to_sym
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.address(@name)
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Variable: #{@name}"
    end
end

class BLConstValue
    def initialize(value, type)
        @value = value
        @type = type
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Creates a temp variable with the correct value and type and then returns its address
        return scope.temp(@type, @value)
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Constant value: #{@type} #{@value}"
    end
end

# Base class for all varaible types
# The variable classes are never initialized; insted they are just used to make it easier to call the correct functions for each variable
class BLVar 
    @@method_table = Hash.new

    # Adds a method signature to a variable so other parts of the program knows that the variable supports it
    def self.add_method(method_signature)
        if(not @@method_table.key?(self.name))
            @@method_table[self.name] = Hash.new
        end

        if(@@method_table[self.name].key?(method_signature.name))
            @@method_table[self.name][method_signature.name] += [method_signature]
        else
            @@method_table[self.name][method_signature.name] = [method_signature]
        end
    end

    # Other parts of the program uses this function to ask if a variable supports a method
    def self.implements_method?(method_signature)
        return false if(method_signature == nil)
        return false if(not @@method_table.key?(self.name))
        return false if(not @@method_table[self.name].key?(method_signature.name))

        @@method_table[self.name][method_signature.name].each do |signature|
            return true if(signature.eql?(method_signature))
        end

        return false
    end

    attr_reader :parent_signature
    def self.get(addr)
        raise RuntimeError.new("Base variable class cannot get from memory")
    end
    def self.set(addr, value)
        raise RuntimeError.new("Base variable class cannot set memory")
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "variable"
    end
end

class BLDataStructure < BLVar
    attr_reader :parent_signature
    def self.get(addr)
        raise RuntimeError.new("#{self.type} cannot get from memory")
    end
    def self.set(addr, value)
        raise RuntimeError.new("#{self.type} cannot set memory")
    end
    def self.copy(addr, to_addr)
        raise RuntimeError.new("#{self.type} cannot copy")
    end
    def self.output(addr)
        raise RuntimeError.new("#{self.type} does not support print")
    end
end



class BLList < BLDataStructure
    # === Initializations ===
    # Reserves memory and sets the necessary variables
    def self.reserve(signature, type)
        addr = $memory.reserve(signature, 4, nil)
        $memory.set(addr, signature)
        $memory.set(addr + 1, type)
        $memory.set(addr + 2, 0)
        return addr
    end
    
    # Sets som necesarry variables in already reserved memory
    def self.init(addr, signature, extra = nil)
        $memory.set(addr, signature)
        $memory.set(addr + 1, extra)
        $memory.set(addr + 2, 0)
        $memory.set(addr + 3, nil)
        return nil
    end

    # === Internal help functions ===
    # Used to copy a list from one address to another address
    def self.copy(addr, to_addr)
        # Copy the base data in the base of the list
        $memory.set(to_addr + 1, $memory.get(addr + 1))
        $memory.set(to_addr + 2, $memory.get(addr + 2))
        
        data_type = $memory.get(addr + 1)
        next_node = $memory.get(addr + 3)
        new_next = to_addr + 3
        while(next_node != nil)
            # Reserve enough memory for a node and set the new list to point to that node
            new_addr = $memory.reserve($memory.get(to_addr), data_type.length + 1)
            
            # Set the addr that has the addr to the next node to the addr of the next node
            $memory.set(new_next, new_addr)
            new_next = new_addr
            
            # Copy over the data in the node
            for i in 1...data_type.length + 1
                $memory.set(new_next + i, $memory.get(next_node + i))
            end
            
            # Move forward to the next node
            next_node = $memory.get(next_node)
        end
        return nil
    end

    # Help function that returns the address of the specified element
    def self.element(addr, index)
        # Get the addr of the first node
        next_element = $memory.get(addr + 3)
        if(next_element == nil)
            raise RuntimeError.new("Index out of range")
        end
        # While index > 0, move to the next node
        while(index > 0)
            next_element = $memory.get(next_element)
            index -= 1
            if(next_element == nil)
                raise RuntimeError.new("Index out of range")
            end
        end

        return $memory.get(next_element)
    end

    # Other parts of the program use this to find out how many memory spaces this class takes up
    def self.length()
        return 4
    end

    # Printing function
    def self.output(addr)
        print '['
        next_element = $memory.get(addr + 3)
        data_type = $memory.get(addr + 1)
        while(next_element != nil)
            data_type.output(next_element + 1)
            next_element = $memory.get(next_element)
            break if(next_element == nil)
            print ', '
        end
        print ']'
    end

    # === Memeber functions the user can access ===
    # Returns a refrence to the data at a specified index
    def self.index(addr, index_addr, scope)
        if(scope.type(index_addr) != BLInteger)
            raise RuntimeError.new("Can only index using integer")
        end
        index = $memory.get(index_addr)
        # Get the addr of the first node
        next_element = $memory.get(addr + 3)
        if(next_element == nil)
            raise RuntimeError.new("Index out of range")
        end
        # While index > 0, move to the next node
        while(index > 0)
            next_element = $memory.get(next_element)
            index -= 1
            if(next_element == nil)
                raise RuntimeError.new("Index out of range")
            end
        end

        # Create a refrence to the place in memory where the data at the specified index begins
        scope.refrence($memory.get(addr + 1), next_element + 1)
        return next_element + 1
    end

    # Takes the addr of the list, what index to insert at, and the addr where the value to insert is stored
    def self.insert(addr, index_addr, value_addr, scope)
        data_type = $memory.get(addr + 1)
        if(data_type != scope.type(value_addr))
            raise "Tried adding wrong type of value to list. Contains #{data_type}, given #{scope.type(value_addr)}."
        end 
        signature = $memory.get(addr)
        to_assign = nil
        
        if(scope.type(index_addr) != BLInteger)
            raise RuntimeError.new("Can only index using integer")
        end
        index = $memory.get(index_addr)

        if(index == 0)
            to_assign = addr + 3 
        elsif(index == 1)
            to_assign = $memory.get(addr + 3)
        else
            # Use the element function to find the correct element
            to_assign = self.element(addr, index - 2)
        end
        # Creates a new element in the list and initializes it
        # It then copies the value that is going to be stored at that addr from the value addr that was given
        old_next = $memory.get(to_assign)
        new_addr = $memory.reserve(signature, data_type.length + 1) 
        $memory.set(new_addr, old_next)
        $memory.set(to_assign, new_addr)
        data_type.init(new_addr + 1, $memory.get(addr))
        data_type.copy(value_addr, new_addr + 1)
        $memory.set(addr + 2, $memory.get(addr + 2) + 1)
        return nil
    end

    # Takes the addr of the list and the index of the element to remove
    def self.remove(addr, index_addr, scope)
        data_type = $memory.get(addr + 1)
        signature = $memory.get(addr)
        if($memory.get(addr + 3) == nil)
            raise RuntimeError.new("Index out of range")
        end
        to_assign = nil

        if(scope.type(index_addr) != BLInteger)
            raise RuntimeError.new("Can only index using integer")
        end
        index = $memory.get(index_addr)

        if(index == 0)
            to_assign = addr + 3
        elsif(index == 1)
            to_assign = $memory.get(addr + 3)
        else
            to_assign = self.element(addr, index - 2)
        end
        to_remove = $memory.get(to_assign)
        new_next = $memory.get(to_remove)
        $memory.release(signature, to_remove, data_type.length + 1)
        $memory.set(to_assign, new_next)
        return nil
    end

    # Get the number of elements in the list
    def self.count(addr, scope)
        return $memory.get(addr + 2)
    end

    # === Extra stuff ===
    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "list"
    end
end



# Base class for simple variables
# Simple variablesa re variables that only take up one memory address
# Because they all have the same structure, most of their functions are shared from the base class
class BLSimpleVar < BLVar
    # Reserve enough memory for itself and return the address that was reserved for it
    def self.reserve(signature, extra)
        return $memory.reserve(signature, 1)
    end

    # Get teh value at an address
    def self.get(addr)
        return $memory.get(addr)
    end

    # Copy the value form one address to another
    def self.copy(addr, to_addr)
        $memory.set(to_addr, $memory.get(addr))
    end

    # Set the value at an adress
    def self.set(addr, value)
        $memory.set(addr, value)
    end

    # Initialize an address
    def self.init(addr, signature)
        $memory.set(addr, nil)
        return nil
    end

    #Printing function
    def self.output(addr)
        print $memory.get(addr)
    end

    # How many memory slots the variable uses
    def self.length
        return 1
    end
end

class BLBool < BLSimpleVar
    # Special set function to make sure it contains the correct data
    def self.set(addr, value)
        if(value == true || value == false)
            $memory.set(addr, value)
            return nil
        end
        raise RuntimeError.new("Bool assigned value of wrong type")
    end
    # Initialize to base bool value, false
    def self.init(addr, signature)
        $memory.set(addr, false)
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "bool"
    end
end 

# Class for identifying numbers so integers and floats can be used interchangebly where we want to allow it
class BLNumber < BLSimpleVar
    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "number"
    end
end

class BLInteger < BLNumber
    # Special set function to make sure it contains the correct data
    def self.set(addr, value)
        if(value.is_a?(Integer))
            $memory.set(addr, value)
            return nil
        end
        if(value.is_a?(Float))
            $memory.set(addr, value.to_i)
            return nil
        end
        raise RuntimeError.new("Integer assigned value of wrong type")
    end

    # Initialize to base integer value, 0
    def self.init(addr, signature)
        $memory.set(addr, 0)
    end

    # All arithmetic functions for integer
    def self.addition(lh, rh, scope)
        return scope.temp(BLInteger, ($memory.get(lh) + $memory.get(rh)).to_i)
    end
    def self.subtraction(lh, rh, scope)
        return scope.temp(BLInteger, ($memory.get(lh) - $memory.get(rh)).to_i)
    end
    def self.multiplication(lh, rh, scope)
        return scope.temp(BLInteger, ($memory.get(lh) * $memory.get(rh)).to_i)
    end
    def self.divition(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh).to_f / $memory.get(rh)).to_f)
    end
    def self.modulo(lh, rh, scope)
        return scope.temp(BLInteger, ($memory.get(lh) % $memory.get(rh)).to_i)
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "integer"
    end
end



class BLFloat < BLNumber
    # Special set function to make sure it contains the correct data
    def self.set(addr, value)
        if(value.is_a?(Integer))
            $memory.set(addr, value.to_f)
            return nil
        end
        if(value.is_a?(Float))
            $memory.set(addr, value)
            return nil
        end
        raise RuntimeError.new("Float assigned value of wrong type")
    end

    # Initialize to base float value, 0.0
    def self.init(addr, signature)
        $memory.set(addr, 0.0)
    end

    # All arithmetic functions for float
    def self.addition(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh) + $memory.get(rh)).to_f)
    end
    def self.subtraction(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh) - $memory.get(rh)).to_f)
    end
    def self.multiplication(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh) * $memory.get(rh)).to_f)
    end
    def self.divition(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh) / $memory.get(rh)).to_f)
    end
    def self.modulo(lh, rh, scope)
        return scope.temp(BLFloat, ($memory.get(lh) % $memory.get(rh)).to_f)
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "float"
    end
end

BLList.add_method(BLMethodSignature.new("index", BLVar, [BLInteger]))
BLList.add_method(BLMethodSignature.new("insert", nil, [BLInteger, BLVar]))
BLList.add_method(BLMethodSignature.new("remove", nil, [BLInteger]))
BLList.add_method(BLMethodSignature.new("count", BLInteger, []))

BLInteger.add_method(BLMethodSignature.new("addition", BLInteger, [BLInteger, BLNumber]))
BLInteger.add_method(BLMethodSignature.new("subtraction", BLInteger, [BLInteger, BLNumber]))
BLInteger.add_method(BLMethodSignature.new("multiplication", BLInteger, [BLInteger, BLNumber]))
BLInteger.add_method(BLMethodSignature.new("divition", BLInteger, [BLInteger, BLNumber]))
BLInteger.add_method(BLMethodSignature.new("modulo", BLInteger, [BLInteger, BLNumber]))

BLFloat.add_method(BLMethodSignature.new("addition", BLFloat, [BLFloat, BLNumber]))
BLFloat.add_method(BLMethodSignature.new("subtraction", BLFloat, [BLFloat, BLNumber]))
BLFloat.add_method(BLMethodSignature.new("multiplication", BLFloat, [BLFloat, BLNumber]))
BLFloat.add_method(BLMethodSignature.new("divition", BLFloat, [BLFloat, BLNumber]))
BLFloat.add_method(BLMethodSignature.new("modulo", BLFloat, [BLFloat, BLNumber]))