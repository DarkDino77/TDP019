
# The memory manager
# It keeps trach of all the values of all variables in the program
# It assigns every value a unique address
class BLMemoryManager
    attr_reader :memory, :owners

    def initialize
        @memory = {}
        @owners = {}
    end

    # Reserves memory
    # signature: scope signature to keep track of what scope holds what 
    # variables so they can be easily removed when the scope dissapears
    # ammount: is how many consecutive addresses we want to reserve
    # value: is an optional base value to assign to all the variables that gets reserved
    def reserve(signature, ammount, value = nil)
        used = @memory.keys.sort
        addr = nil
        # Special cases for when there are very few variables
        if(used.length() < 1)
            addr = 0
        elsif(used.length() < 2)
            addr = (used[0] > ammount ? 0 : used[0] + 1)
        elsif(used[0] > ammount)
            addr = 0
        else
            # Find the first place where we have enough consecutive addresses free to reserve
            index = 0
            while(index < used.length - 1)
                if(used[index + 1] - used[index] > ammount)
                    addr = used[index] + 1
                    break
                end
                index += 1
            end
            if(addr == nil)
                addr = used[used.length - 1] + 1
            end
        end

        # If its the first time the scope reserves variables
        if(!@owners.key?(signature))
            @owners[signature] = []
        end

        # Reserve the addresses and assign their owner
        for i in addr...(addr + ammount) do
            @memory[i] = value
            @owners[signature] += [i]
        end
        # returns the first address of the consecutive addresses reserved
        return addr
    end

    # Releases already reserved addresses
    # signature: the signature of the scope that reserved the addresses
    # address: what address to release
    # ammount: how many consecutive addresses should be released
    def release(signature, address = nil, ammount = nil)
        # If we don't get an address we release all addresses under the specific signature
        if(address == nil)
            if(!@owners.key?(signature))
                return nil
            end
            @owners[signature].each do |addr| @memory.delete(addr) end
            @owners.delete(signature)
            return nil
        end

        # If we don't get an ammount we only release a singe address
        if(ammount == nil)
            @memory.delete(address)
            @owners[signature].delete(address)
            return nil
        end

        # If we get all three parameters then we release all addresses from the address starting point and ammount forward
        for i in address...(address + ammount) do
            @memory.delete(i)
            @owners[signature].delete(i)
        end
        return nil
    end

    # Get the value stored at a specified address
    def get(address)
        if(@memory.key?(address))
            return @memory[address]
        elsif(address == nil)
            raise RuntimeError.new("Accessing nil address")
        else
            raise RuntimeError.new("Accessing unreserved memory at address #{address}")
        end
    end

    # Set the value of a specified address
    def set(address, value)
        if(@memory.key?(address))
            @memory[address] = value
        elsif(address == nil)
            raise RuntimeError.new("Accessing nil address")
        else
            raise RuntimeError.new("Accessing unreserved memory at address #{address}")
        end
        return nil
    end

    def to_s
        return "Memory: #{@memory}\nOwners: #{@owners}"
    end
end

# Keeps track of all the functions
class BLFunctionManager
    def initialize
        @funcs = {}
    end

    # Add a function
    def add(func)
        # If there are no functions of this name yet then just add it
        if(!@funcs.key?(func.signature.name))
            @funcs[func.signature.name] = [func]
            return nil
        end

        # If there already are functions of this name then that they don't have the same signatures
        @funcs[func.signature.name].each do |existing_func|
            if(func.signature.eql?(existing_func.signature))
                raise SyntaxError.new("Function \"#{func.signature.name}\" declared more than once with the same parameters!")
            end
        end

        # Check if the function we want to add has the same returntype as other functions of the same name
        if(@funcs[func.signature.name][0].signature.return_type != func.signature.return_type)
            raise SyntaxError.new("Function \"#{func.signature.name}\" has a different return type from previously declared versions of it!")
        end

        # If it fufills the requirements we add it
        @funcs[func.signature.name].append(func)
    end

    # Get a function
    def get(signature)
        # If there are no functions with the name given in the signature
        if(not @funcs.key?(signature.name))
            raise RuntimeError.new("No functions matching the given name found.\nSignature: #{signature}")
        end

        # Find a function with a matching signature
        @funcs[signature.name].each do |func|
            if(func.signature.eql?(signature))
                #pp func
                return func
            end
        end
        # If no function was found then error
        raise RuntimeError.new("No functions matching the given signature found.\nSignature: #{signature}")
    end
    
    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Function Manager"
        index1 = 0
        @funcs.each do |key, func_list|
            temp_level = level
            if(index1 + 1 < @funcs.length)
                puts "#{level}#{}┠─#{key}"
                temp_level += "┃ "
            else
                puts "#{level}#{}┖─#{key}"
                temp_level += "  "
            end

            func_list.each_with_index do |func, index2|
                if(index2 + 1 < func_list.length)
                    print temp_level + "┠─"
                    func.print_tree(temp_level + "┃ ")
                else
                    print temp_level + "┖─"
                    func.print_tree(temp_level + "  ")
                end
            end
            index1 += 1
        end
    end
end

# Keeps track of what scope signatures are in use
class BLSignatureManager
    def initialize
        @in_use = []
    end

    # Get a free signature
    def get()
        length = @in_use.length
        if(length < 1)
            @in_use += [1]
            return 1
        elsif(length < 2)
            new_signature = (@in_use[0] == 1 ? 2 : 1)
            @in_use += [new_signature]
            return new_signature
        end
        @in_use.each_with_index do |signature, index|
            if(index > length - 2)
                break
            end
            if(signature + 1 != @in_use[index + 1])
                new_signature = signature + 1
                @in_use += [new_signature]
                return new_signature
            end
        end
        new_signature = @in_use[length - 1] + 1
        @in_use += [new_signature]
        return new_signature
    end

    # Get the signature for global scope
    def get_global()
        if(@in_use.include?(0))
            raise RuntimeError.new("Global scope already in use")
        end
        @in_use += [0]
        return 0
    end

    # Release a signature
    def release(signature)
        @in_use.delete(signature)
        $memory.release(signature)
    end
end