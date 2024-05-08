require_relative "./variable_nodes.rb"
require_relative "../runtime.rb"



#        Function nodes
#==============================

# The function node that runs a function
class BLFunc
    attr_reader :signature, :body
    def initialize(signature, body)
        @signature = signature
        @body = body
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Setup a variable for the return value to be put in later
        return_addr = scope.add(:return, @signature.return_type)
        $memory.set(return_addr, nil)

        # Some standard variables loops need to function
        break_addr = scope.add(:break, BLBool)
        continue_addr = scope.add(:continue, BLBool)
        $memory.set(break_addr, false)
        $memory.set(continue_addr, false)

        # The loop that evaluates every line of the function, breaks when a returnvalue has been assigned
        @body.each do |stmt|
            stmt.eval(scope)
            scope.clear_temp()
            break if($memory.get(return_addr) != nil)
        end

        # Raise an error if the return value was never set
        if($memory.get(return_addr) == nil)
            raise "No return statement found in function \"#{@signature.name}\""
        end

        # Raise an error if the return value is of the wrong type
        if(scope.type(return_addr) != @signature.return_type)
            raise RuntimeError.new("Value being returned from #{@signature.name} is of wrong type. Supposed to be #{@signature.return_type}, was #{scope.type(return_addr)}.")
        end

        # Create a temporary variable in the global scope that is used to pass the value back to where the function was called
        return_var = $global.temp(@signature.return_type, $memory.get(return_addr))
        scope.cleanup()
        return return_var
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "#{@signature.return_type.type} #{@signature.name}"

        puts "#{level}┠─Args"
        @signature.args.each_with_index do |arg, index|
            if(index + 1 < @signature.args.length)
                print level + "┃ ┠─"
                arg.print_tree(level + "┃ ┃ ") 
            else
                print level + "┃ ┖─"
                arg.print_tree(level + "┃   ") 
            end
        end

        puts "#{level}┖─Body"
        @body.each_with_index do |stmt, index| 
            if(index + 1 < @body.length)
                print level + "  ┠─"
                stmt.print_tree(level + "  ┃ ") 
            else
                print level + "  ┖─"
                stmt.print_tree(level + "    ") 
            end
        end
    end
end

class BLFuncCall
    attr_reader :name, :args 

    def initialize(name, args)
        @name = name.to_sym
        @args = args
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate all the parameters to find out what type they are
        arguments = []
        @args.each do |arg| 
            arguments.append(arg.eval(scope)) 
        end
        # Get the types of every argument
        arg_types = []
        arguments.each do |arg|
            arg_types.append(scope.type(arg))
        end
        # Make a signature using the name of the function and the types of each argumentz
        func = $functions.get(BLFuncSignature.new(@name, nil, arg_types))
        
        # Setup a new scope for the function
        new_scope = BLScope.new($signatures.get(), $global)
        
        # Create the parameter variables inside the new scope
        arguments.each_with_index do |arg, index| 
            addr = new_scope.add(func.signature.args[index].name, arg_types[index])
            $memory.set(addr, $memory.get(arguments[index]))
        end

        # Run the function and return the address where the return value has been put
        return func.eval(new_scope)
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Func call: #{@name}"
        @args.each_with_index do |arg, index| 
            if(index + 1 < @args.length)
                print level + "┠─"
                arg.print_tree(level + "┃ ") 
            else
                print level + "┖─"
                arg.print_tree(level + "  ") 
            end
        end

    end
end

class BLReturn
    attr_reader :value
    def initialize(value)
        @value = value
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Get the return address
        return_addr = scope.address(:return)
        value_addr = @value.eval(scope)
        if(scope.type(return_addr) != scope.type(value_addr))
            raise RuntimeError.new("Returning value of wrong type!")
        end
        # Copy the return value into the address of the return variable
        scope.type(return_addr).copy(value_addr, return_addr)
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "return"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Return"
        print level + "┖─"
        @value.print_tree(level + "  ")
    end
end

#      Signature nodes
#==============================

# Signature for identifying functions
class BLFuncSignature
    attr_reader :name, :return_type, :args

    def initialize(name, return_type, args)
        @name, @return_type, @args = name.to_sym, return_type, args
    end
    

    def eql?(other)
        if( other != nil &&
            other.is_a?(BLFuncSignature) &&
            other.name == @name &&
            @args.length == other.args.length)

            @args.each_with_index do |arg, index|
                # We check if the list contains a func param or not because that makes it so we can check a list of datatypes against a list of func parameters
                type = (arg.is_a?(BLFuncParam) ? arg.type : arg)
                other_type = (other.args[index].is_a?(BLFuncParam) ? other.args[index].type : other.args[index])
                if(type != other_type)
                    return false
                end
            end

            return true
        end

        return false
    end

    def to_s
        return "Name: #{@name}, Returntype: #{@return_type}, Args: #{@args}"
    end
end

# Signature for identifying member functions
class BLMethodSignature < BLFuncSignature
    def eql?(other)
        if( other != nil &&
            other.is_a?(BLMethodSignature) &&
            other.name == @name)

            if(self.class <= other.class)
                return true
            end
        end

        return false
    end
end

# Class for storing func parameters
class BLFuncParam
    attr_reader :name, :type
    def initialize(name, type)
        @name = name.to_sym
        @type = type
    end

    # The function that is called when running the program to evaluate each node
    def eval(block)
        raise "Eval should not be called on a BLFuncParam object"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Func param, Name: #{@name}, Type: #{@type}"
    end
end

#        Other nodes
#==============================

class BLPrint
    def initialize(rh = nil)
        @rh = rh
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate the statement that is going to be printed
        out_addr = nil
        if(@rh != nil)
            out_addr = @rh.eval(scope)
            if(out_addr == nil)
                raise "Something went wrong with print, statemet evaluated to nil"
            end
            # Get the type of the return value so we can call its output function
            type = scope.type(out_addr)
            type.output(out_addr)
        end
        print "\n"
        return nil 
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "print"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Print"
        if(@rh != nil)
            print level + "┖─"
            @rh.print_tree(level + "  ")
        end
    end
end

    
