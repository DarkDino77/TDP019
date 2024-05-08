require_relative "./variable_nodes.rb"


#   Special node for calling member functions
# =============================================

# node that calles a member function
class BLMemberCall
    def initialize(var, name, params)
        @var = var
        @name = name.to_sym
        @params = params
    end

    # Helper function for evaluating the parameters
    def eval_params(scope)
        # Goes through and evaluates all the parameters
        evaled_params = []
        @params.each do |param|
            evaled_params.append(param.eval(scope))
        end
        return evaled_params
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluates all the parameters and gets what type they are
        evaled_params = eval_params(scope)
        param_types = []
        evaled_params.each do |param|
            param_types.append(scope.type(param))
        end

        # Evaluate the node that gives the address and type of the variable whos member function we want to call
        var_addr = @var.eval(scope)
        var_type = scope.type(var_addr)

        # Check if the variable we want to call supports the function we want to call with the parameters we have
        if(not var_type.implements_method?(BLMethodSignature.new(@name, nil, param_types)))
            raise RuntimeError.new("#{var_type.type} does not implement #{@name}")
        end

        # Call the member function using send
        return var_type.send(@name, var_addr, *evaled_params, scope)
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts  "Member call"
        puts  level + "┠─Base"
        print level +  "┃ ┖─"
        @var.print_tree(level + "┃   ")
        puts  level + "┠─Member name: #{@name}"
        puts  level + "┖─Parameters"
        @params.each_with_index do |parameter, index| 
            if(index + 1 < @params.length)
                print level + "  ┠─"
                parameter.print_tree(level + "  ┃ ") 
            else
                print level + "  ┖─"
                parameter.print_tree(level + "    ") 
            end
        end
    end
end

#         Common nodes for operators
# =============================================

class BLBinaryOperator 
    def initialize(lh, rh)
        @rh = rh
        @lh = lh
    end

    # Common function for evaluating the prameters for the node
    def eval_params(scope)
        left = @lh.eval(scope)
        right = @rh.eval(scope)
        return left, right
    end

    # Function for printing a tree representation of the program
    # Common function for all binary methods because they all are built similarly
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┠─Right side"
        print level + "┃ ┖─"
        @rh.print_tree(level + "┃   ")
        puts level + "┖─Left side"
        level += "  "
        print level + "┖─"
        @lh.print_tree(level + "  ")
    end
end

class BLUnaryOperator 
    def initialize(node)
        @node = node
    end

    # Function for printing a tree representation of the program
    # Common function for all unary methods because they all contain the same data
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┖─Right side"
        level += "  "
        print level + "┖─"
        @node.print_tree(level + "  ")
    end
end

#               Assignment node
# =============================================

class BLAssignment < BLBinaryOperator
    def initialize(lh, rh)
        @lh = lh
        @rh = rh
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate the parameters and get their types
        left, right = eval_params(scope)
        left_type, right_type = scope.type(left), scope.type(right)
        # Check that the variables are the same type
        if(left_type != right_type)
            raise RuntimeError.new("Assignment of wrong type, tried assigning #{right_type} to #{left_type}")
        end
        # Copy the value of right into left
        left_type.copy(right, left)
        scope.remove_temp(right)
        # Return the address of left so assignments can be stacked
        return left
    end
end

#   Unary and binary nodes for the arithmetic
# =============================================

class BLBinaryMethod < BLBinaryOperator
    def initialize(lh, rh, name)
        @lh = lh
        @rh = rh
        @name = name.to_sym
    end
    
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate the parameters and get their types
        left, right = eval_params(scope)
        left_type, right_type = scope.type(left), scope.type(right)
        
        # Check if the variable supports the operation
        if(not left_type.implements_method?(BLMethodSignature.new(@name, nil, [left_type, right_type])))
            raise RuntimeError.new("#{left_type.type} does not implement #{@name} with #{right_type.type}")
        end

        # Call the function to preform the operation
        result = left_type.send(@name, left, right, scope)
        scope.remove_temp(left)
        scope.remove_temp(right)

        # Return the address where the result is stored
        return result
    end

    # Function for printing a tree representation of the program
    # Special function because the node can represent multiple operators
    def print_tree(level = "")
        puts "#{self.class} #{@name}"
        puts level + "┠─Right side"
        print level + "┃ ┖─"
        @rh.print_tree(level + "┃   ")
        puts level + "┖─Left side"
        level += "  "
        print level + "┖─"
        @lh.print_tree(level + "  ")
    end
end

class BLUnaryMethod < BLBinaryOperator
    def initialize(lh, name)
        @lh = lh
        @name = name.to_sym
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate the input parameter ang get its type
        left = lh.eval(scope)
        left_type = scope.type(left)

        # Check if the variable supports the given function
        if(not left_type.implements_method?(BLMethodSignature.new(@name, nil, [left_type])))
            raise RuntimeError.new("#{left_type.type} does not implement #{@name}")
        end

        # call the given function
        result = left.send(@name, left, scope)
        scope.remove_temp(left)

        # Return the address where the result is stored
        return result
    end
end

#              Comparison nodes
# =============================================

class BLBinaryComparison < BLBinaryOperator
    # Common function for evaluating the prameters for the node
    # Does comparison using the spaceship operator and returns the result of the comparison
    def eval_comparison(scope)
        left = @lh.eval(scope)
        right = @rh.eval(scope)
        result = $memory.get(left) <=> $memory.get(right)
        if(result == nil)
            raise "Comparison between #{left.class.type} and #{right.class.type} is not possible"
        end
        scope.remove_temp(left)
        scope.remove_temp(right)
        return result
    end
end

class BLEqual < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) == 0)
    end
end

class BLNotEqual < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) != 0)
    end
end

class BLLessThan < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) == -1)
    end
end

class BLLessThanOrEqual < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) != 1)
    end
end

class BLGreaterThan < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) == 1)
    end
end

class BLGreaterThanOrEqual < BLBinaryComparison
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        return scope.temp(BLBool, eval_comparison(scope) != -1)
    end
end

#             Logic operator nodes
# =============================================

class BLBinaryLogicOperator < BLBinaryOperator
    # Common function for evaluating the prameters for the node
    def eval_params(scope)
        # Evaluate the params
        left = @lh.eval(scope)
        right = @rh.eval(scope)

        # Check that both parameters are boolean because this function if for logic operators
        if(scope.type(left) != BLBool  || scope.type(right) != BLBool)
            raise "#{self.class.type} given an argument that is not a bool, argument types were #{scope.type(left).type} and #{scope.type(right).type}"
        end

        # Return the addresses where the results are stored
        return left, right
    end
end

class BLUnaryLogicOperator < BLUnaryOperator
    # Common function for evaluating the prameters for the node
    def eval_params(scope)
        # Evaluate the param
        value = @node.eval(scope)

        # Check that the value is a boolean because this is for logic
        if(scope.type(value) != BLBool)
            raise "Cannot preform #{self.class.type} operation on #{scope.type(value).type}, has to be a bool"
        end

        # Return the addresses where the result is stored
        return value
    end
end

class BLLogicAnd < BLBinaryLogicOperator
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        left, right = eval_params(scope)
        result = scope.temp(BLBool, $memory.get(left) && $memory.get(right))
        scope.remove_temp(left)
        scope.remove_temp(right)
        return result
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "And"
    end
end

class BLLogicOr < BLBinaryLogicOperator
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        left, right = eval_params(scope)
        result = scope.temp(BLBool, $memory.get(left) || $memory.get(right))
        scope.remove_temp(left)
        scope.remove_temp(right)
        return result
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "Or"
    end
end

class BLLogicNot < BLUnaryLogicOperator
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        left = eval_params(scope)
        result = scope.temp(BLBool, !$memory.get(left))
        scope.remove_temp(left)
        return result
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "Not"
    end
end