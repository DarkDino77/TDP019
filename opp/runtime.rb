
require_relative "./managers.rb"

# Initializing the global vars here because almost everything need them to function
$functions = BLFunctionManager.new()
$memory = BLMemoryManager.new()
$signatures = BLSignatureManager.new()

class BLScope
    attr_reader :signature
    def initialize(signature, parent = nil)
        @parent = parent
        @addresses = {}
        @types = {}
        @signature = signature

        @temp_types = {}
        @refrence_types = {}
    end

    # Add a variable to the scope
    def add(name, type)
        # If it already exists and the variable you tried to add is of the same type as the existing one then just return the variable address
        if(@addresses.key?(name))
            addr = @addresses[name]
            if(@types[addr] != type)
                raise RuntimeError.new("Tried initializing already existing variable #{name} with different type")
            else
                return addr
            end
        end
        # If it does not exist then reserve enough memory for the variable
        addr = $memory.reserve(@signature, type.length)
        @addresses[name] = addr
        @types[addr] = type
        # Return the address of the variable
        return addr
    end

    # Removesa a variable from the scope
    def delete(name)
        if(!@addresses.key?(name))
            raise RuntimeError.new("Tried removing nonexistent variable \"#{name}\"")
        end
        addr = @addresses[name]
        @addresses.delete(name)
        @types.delete(addr)
        type.release(addr)
        return nil
    end

    # Takes a memory address and returns what variable type is stored there
    def address(name)
        if(@addresses.key?(name))
            return @addresses[name]
        end
        if(@parent != nil)
            return @parent.address(name)
        end
        raise RuntimeError.new("Tried looking up address for nonexistent variable \"#{name}")
    end

    # Takes a variable name and returns what address corresponds to that variable
    def type(name)
        if(@temp_types.key?(name))
            return @temp_types[name]
        end
        if(@types.key?(name))
            return @types[name]
        end
        if(@parent != nil)
            return @parent.type(name)
        end
        raise RuntimeError.new("Tried looking up type for nonexistent variable with address #{name}")
    end

    # Creates a temporary variable that is used internally for passing around values
    def temp(type, value)
        addr = $memory.reserve(@signature, type.length)
        @temp_types[addr] = type
        type.init(addr, @signature)
        type.set(addr, value)
        return addr
    end

    # Creates a refrence by binding an address to a type, this variable does not have a name
    def refrence(type, addr)
        @types[addr] = type
        return addr
    end

    # Removes all temp values
    def clear_temp()
        @temp_types.each do |addr, type|
            $memory.release(@signature, addr, type.length)
        end
        @temp_types = {}
        if(@parent != nil)
            @parent.clear_temp()
        end
    end

    # Removes one specific temp value
    def remove_temp(addr)
        if(@temp_types.key?(addr))
            $memory.release(@signature, addr, @temp_types[addr].length)
            @temp_types.delete(addr)
        end
        if(@parent != nil)
            @parent.remove_temp(addr)
        end
    end

    # Releases all variables that are connected to this signature
    def cleanup()
        $memory.release(@signature)
        $signatures.release(@signature)
    end

    def to_s
        return "Signature: #{@signature}\nAddresses: #{@addresses}\nTypes: #{@types}\nTemp_types: #{@temp_types}\nParent:\n #{@parent}"
    end
end

class BLProgram
    def initialize(functions, global_vars)
        @funcs = functions
        @global_vars = global_vars
        @global_scope = nil
    end

    # setup functikon that puts all functions in the function manager and initalizes all global vars with global scope
    def setup()
        @global_scope = BLScope.new($signatures.get_global())
        @global_vars.each do |var|
            var.eval(@global_scope)
        end
        $global = @global_scope
        @funcs.each do |func|
            $functions.add(func)
        end
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Global variables"
        @global_vars.each_with_index do |var, index|
            temp_level = level
            if(index + 1 < @global_vars.length)
                print "#{level}┠─"
                var.print_tree(level + "┃ ")
            else
                print "#{level}┖─"
                var.print_tree(level + "  ")
            end
        end

        puts "Functions"
        @funcs.each_with_index do |func, index|
            temp_level = level
            if(index + 1 < @funcs.length)
                print "#{level}┠─"
                func.print_tree(level + "┃ ")
            else
                print "#{level}┖─"
                func.print_tree(level + "  ")
            end
        end
    end


end

class BLRuntime
    def initialize(program)
        @program = program
    end

    # Sets upp everything, runs the program, then cleans everything up
    def run()
        # Resetting the global variables in case the have been used and have old data in them
        $functions = BLFunctionManager.new()
        $memory = BLMemoryManager.new()
        $signatures = BLSignatureManager.new()
        
        @program.setup()

        main = $functions.get(BLFuncSignature.new(:main, nil, []))
        main_scope = BLScope.new($signatures.get(), $global)
        
        out_value_addr = main.eval(main_scope)
        out_value_type = $global.type(out_value_addr)

        print "Output: "
        out_value_type.output(out_value_addr)
        puts

        $global.cleanup
    end
end