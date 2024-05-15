#!/usr/bin/env ruby

# =============================================[Base]=============================================
# Base class for all nodes in the abstract syntax tree
class Node
    # Class variables to keep track of variable and function scopes
    @@variable_stack = [{}]
    @@function_stack = [{}]
    @@current_scope = 0
    
    # "Pure virtual" function to be implemented by subclasses
    def evaluate()
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
    
    # Creates a new scope by pushing new hashes onto the stacks
    def new_scope
        @@variable_stack << {}
        @@function_stack << {}
        @@current_scope += 1
    end
    
    # Closes the current scope by removing the last hashes from the stacks
    def close_scope
        @@variable_stack.pop()
        @@function_stack.pop()
        @@current_scope -= 1
    end

    # Looks up a variable in the variable stack
    def look_up_var(name)
        stack_counter = @@variable_stack.size-1    
        @@variable_stack.reverse_each do |variables|
            if variables.has_key?(name)

                temp = @@variable_stack[stack_counter][name]
                return temp
            end
            stack_counter -=1
        end
        raise "Variable with the name #{name} was not found in scope with variables: #{@@variable_stack[@@current_scope]}, all scopes: #{@@variable_stack}"
    end

    # Looks up a function in the function stack
    def look_up_fun(name)
        stack_counter = @@function_stack.size-1    
        @@function_stack.reverse_each do |variables|
            if variables.has_key?(name)
                temp = @@function_stack[stack_counter][name]
                return temp
            end
            stack_counter -=1
        end
        raise "Function with the name #{name} was not found, function stack: #{@@function_stack[0-@@current_scope]}"
    end
    
    # Helper function to determine if a value is true or false
    def true_or_false(value)
        if value == 0 || (value.is_a?(Array) && value.empty?()) || value == "" || value == 0.0 || value == false
            return false
        end
        return true 
    end

    # Helper function to create datatype nodes based on type (Used by arrays)
    def create_datatype_node(value, type)
        case type
        when "int"
            return Node_int.new(value)
        when "float"
            return Node_float.new(value)
        when "bool"
            return Node_bool.new(value)
        when "char"
            return Node_char.new(value)
        end
    end
end

# Represents a list of statements
class Node_statement_list < Node
    def initialize(statement, statement_list = nil)
        @statement = statement
        @statement_list = statement_list
    end

    # Evaluates the statement list
    def evaluate()
        return_value = @statement.evaluate()
        
        # Breaks if statement returns- or is a return node
        if @statement.is_a?(Node_return)
            return @statement
        elsif return_value.is_a?(Node_return)
            return return_value
        end

        if @statement_list != nil
            return_value = @statement_list.evaluate()
        end

        return return_value
    end
end

# Represents a standalone scope
class Node_standalone_scope < Node
    def initialize(stmt)
        @stmt = stmt
    end

    # Evaluates the body within a new scope
    def evaluate()
        new_scope()
        @stmt.evaluate
        close_scope()
    end
end

# =============================================[Variables]=============================================
# Base class for datatype nodes
class Node_datatype < Node
    def initialize()
        raise NotImplementedError, "Must implement #{self.class}.initialize"
    end

    def get_type()
        return @type
    end

    def evaluate()
        return @value
    end
end

# Represents an integer node
class Node_int < Node_datatype
    attr_accessor :value, :type
    def initialize(value)
        @value = value.to_i
        @type = "int"
    end
end

# Represents a float node
class Node_float < Node_datatype
    attr_accessor :value, :type
    def initialize(value)
        @value = value.to_f
        @type = "float"
    end
end

# Represents a character node
class Node_char < Node_datatype
    attr_accessor :value, :type
    def initialize(value)
        @value = value
        @type = "char"
    end
end

# Represents a bool node
class Node_bool < Node_datatype
    attr_accessor :value, :type
  
    def initialize(value)
        @value = convert_to_boolean(value)
        @type = "bool"
    end
  
    # Helper function to convert a string value to a boolean
    def convert_to_boolean(value)
        case value.downcase
        when "true"
            true
        when "false"
            false
        else
            raise ArgumentError, "Invalid value for boolean: '#{value}'"
        end
    end
end

# Represents a variable node
class Node_variable < Node
    attr_accessor :name,:type
    def initialize(name)
        @name = name
        @type = nil
    end

    # Returns the type of the variable, evaluates if type is nil
    def get_type()
        if @type == nil
            @type = look_up_var(@name)["type"]
        end
        return @type
    end
    
    # Evaluates the variable node
    def evaluate()
        return look_up_var(@name)["value"]
    end
end

# Represents an assignment node
class Node_assignment < Node
    attr_accessor :value
    def initialize(type, name, value)
        @name = name
        @type = type
        @value = value
        @const = true
    end
    
    def get_type()
        return @type
    end

    # Evaluates the assignment node, makes sure that there's no variable with that name already in the scope and that the type is correct
    def evaluate()
        if @@variable_stack.any? { |hash| hash.value?(@name) }
            raise "Variable with name #{@name} already exists"
        else
            if @value.get_type() != @type
                raise TypeError, "Variable assignment for '#{@name}' expected a #{@type} value, but got a #{@value.get_type} value."
            end
            @@variable_stack[@@current_scope][@name] = {"value" => @value.evaluate, "type" => @type, "const" => @const}
            return @value.evaluate
        end
    end
    
    # Removes the const property from the variable (If mod flag detected in parser)
    def remove_const()
        @const = false
    end
end

# Represents an auto assignment node
class Node_auto_assignment < Node_assignment
    def initialize(name, value)
        @name = name
        @value = value
        @type = "nil"
        @const = true
    end

    # Evaluates the auto assignment node, updates the type based on the type of the value node
    def evaluate
        @type = @value.get_type
        super
    end
end

# Represents a re-assignment node
class Node_re_assignment < Node
    def initialize(name, value)
        @name = name
        @value = value
    end

    # Evaluates the re-assignment node, makes sure type is correct and variable is not constant
    def evaluate()
        stack_counter = @@variable_stack.size-1
        var = look_up_var(@name)

        if var
            if var["type"] != @value.get_type
                raise TypeError, "Variable assignment for '#{@name}' expected a #{@type} value, but got a #{@value.get_type} value."
            end
            if var["const"] == false
                var["value"] = @value.evaluate
                return var["value"]
            else
                raise "Variable with name #{@name} is const"
            end
        else
            raise "Variable with name #{@name} not found in scope with variables: #{@@variable_stack[@@current_scope]}"
        end
        return nil
    end
end

# =============================================[Arrays]=============================================
# Represents an array node
class Node_array < Node
    attr_accessor :values
    def initialize(type, values)
        @type = type
        @values = values
    end

    def get_type
        if @type == "nil" 
            evaluate()
        end
        return @type
    end

    # Evaluates the array node, makes sure elements are of correct type
    def evaluate()
        output = []
        @values.each do |m|
            if m.is_a?(Node_array) && m.get_type == "nil"
                m.update_type("array_"+m.values[0].get_type)
            end
            if @type === "nil"
                update_type(m.get_type.include?("array") ? m.get_type : "array_"+m.get_type)
            end
            if m.get_type != @type  
                if m.get_type() != @type.split("_")[1]
                    raise TypeError, "Array expected #{@type.split("_")[1]} but got a #{m.get_type()}"
                end
            end
            output << m.evaluate
        end
        return output
    end

    # Updates the type of the array
    def update_type(type)
        @type = type
    end
end

# Represents an array accessor node
class Node_array_accessor < Node
    attr_accessor :name, :index
    def initialize(name, index)
        @name = name
        @index = index
        @type = "nil"
    end

    def get_type()
        if @type == "nil"
            evaluate
        end
        return @type
    end

    # Evaluates the array accessor node, returns the targeted element
    def evaluate()
        target_array = look_up_var(@name)
        return_value = "nil"
        index = @index[0].evaluate
        unless target_array["type"].include?("array")
            raise TypeError, "Variable with the name #{@name} is not a Array"
        end

        unless index <= target_array["value"].size-1 && index >= 0
            raise IndexError, "outofrange"
        end

        return_value = target_array["value"][index]
        @type = (return_value.is_a?(Array) ? target_array["type"] : target_array["type"].split("_")[1])


        for i in 1..@index.size-1 do
            index = @index[i].evaluate
            unless return_value.is_a?(Array)
                raise TypeError, "Variable with the name #{@name} is not a Array"
            end

            unless index <= return_value.size-1 && index >= 0
                raise IndexError, "outofrange"
            end

            return_value = return_value[index]
            @type = (return_value.is_a?(Array) ? target_array["type"] : target_array["type"].split("_")[1])
            
        end

        return return_value
    end
end

# Represents an array addition node
class Node_array_add < Node
    def initialize(target_variable, var)
        @target_variable = target_variable
        @var = var
    end

    # Evaluates the array addition node, ensures variable is an array, can be modified and the sent in value is of correct type
    def evaluate()
        target_array = look_up_var(@target_variable.name)

        unless target_array["type"].include?("array") || target_array["type"] == "nil"
            raise TypeError, "Variable with the name #{@target_variable.name} is not an Array"
        end

        if target_array["const"]
            raise "Variable with name #{@target_variable.name} is const and cannot be modified"
        end

        if target_array["type"] == "nil" && @var[0].get_type != "nil"
            target_array["type"] = "array_" + @var[0].get_type 
        end

        @var.each do |m|
            unless m.get_type == "nil" || target_array["type"].include?(m.get_type)
                raise TypeError, "Array of type #{target_array["type"].split("_")[1]} cannot include elements of type #{m.get_type}"
            end
        end

        @var.each do |m|
            @target_variable.evaluate << m.evaluate
        end

        return target_array["value"]
    end
end

# Represents an array removal node
class Node_array_remove < Node
    def initialize(target_variable, index = "nil")
        @target_variable = target_variable
        @index = index
    end
    
    # Evaluates the array removal node, returns the element at the targeted index
    def evaluate()
        target_array = look_up_var(@target_variable.name)
        return_value = "nil"

        unless target_array["type"].include?("array")
            raise TypeError, "Variable with the name #{@target_variable.name} is not a Array"
        end

        if target_array["const"]
            raise "Variable with name #{@target_variable.name} is const and cannot be modified"
        end

        if @index != "nil"
            index = @index.evaluate
            unless index <= target_array["value"].size-1 && index >= 0
                if @target_variable.is_a?(Node_variable)
                    raise IndexError, "Index out of range for array with the name #{@target_variable.name}"
                end
            end
            return_value = remove_index(index)
        else
            return_value = remove_index(target_array["value"].size-1)
        end

        return  return_value
    end

    # Helper function to remove an element at a specific index
    def remove_index(index)
        current_value = @target_variable.evaluate
        return_value = current_value[index]
        current_value.delete_at(index)

        return return_value
    end
end

# =============================================[Control]=============================================
# Represents an if statement node
class Node_if < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end
    
    # Evaluates the if statement, returns a return node if one of the statement produces one, else return nil
    def evaluate
        new_scope()
        if true_or_false(@expression.evaluate)
            return_value = @statement_list.evaluate()
            close_scope()
            if @statement_list.is_a?(Node_return)
                return @statement_list
            end
            return return_value
        end
        close_scope()

        return nil
    end
end

# Represents a while loop node
class Node_while < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end

    # Evaluates the while loop, returns a return node if one of the statement produces one, else return nil
    def evaluate
        new_scope()
        while true_or_false(@expression.evaluate) do
            evaluated_expression = @statement_list.evaluate
            if evaluated_expression.is_a?(Node_return)
                close_scope()
                return evaluated_expression
            end
        end

        close_scope()

        return nil
    end
end

# =============================================[Functions]=============================================
# Represents a function definition node
class Node_function < Node
    attr_accessor :name, :variable_list, :function_body, :type
    def initialize(name, variable_list, function_body, type = "nil")
        @name = name
        @variable_list = variable_list 
        @function_body = function_body
        @type = type
    end

    # Evaluates the function definition, always returns nil
    def evaluate()
        @@function_stack[@@current_scope][@name] = self

        return nil
    end
end

# Represents a function call node
class Node_function_call < Node
    attr_accessor :type, :cache

    def initialize(name, variable_list)
        @name = name
        @variable_list = variable_list
        @type = "nil"
        @cache = {} # Used to speed up recursive calls
    end

    def get_type()
        if @type == "nil" 
            evaluate()
        end
        return @type
    end

    # Evaluates the function call, breaks and returns if a return node is evaluated
    def evaluate
        evaluated_arguments = @variable_list.map(&:evaluate)

        # Create a unique key for caching the function call based on the function name and evaluated arguments
        arguments_key = evaluated_arguments.join("-")
        cache_key = "#{@name}-#{arguments_key}"

        return @cache[cache_key] if @cache.has_key?(cache_key)

        fun = look_up_fun(@name)
        raise "The function with the name #{@name} does not exist" unless fun

        unless @variable_list.size == fun.variable_list.size
            raise "Wrong number of arguments, #{fun.name} expected #{fun.variable_list.size} arguments"
        end

        # Validate the type of each argument against the expected type in the function definition
        @variable_list.each_with_index do |var, index|
            expected_type = fun.variable_list[index].get_type
            unless var.get_type == expected_type
                raise "#{fun.name} expected a #{expected_type} at index #{index}"
            end
            fun.variable_list[index].value = var
        end

        new_scope()

        fun.variable_list.map(&:evaluate)

        if @type == "void"
            close_scope
            return nil 
        end

        return_value = fun.function_body.evaluate

        if return_value.is_a?(Node_return)
            set_type(return_value)
            return_value = return_value.evaluate
        else 
            return_value = nil
        end

        close_scope()

        @cache[cache_key] = return_value

        return return_value
    end

    # Sets the type of the function call
    def set_type(return_node)
        @type = return_node.get_type unless @type != "nil"
    end
end

# Represents a return statement node
class Node_return < Node
    def initialize(expr)
        @expr = expr
    end

    def get_type()
        return @expr.get_type
    end

    # Evaluates the return statement
    def evaluate()
        return @expr.evaluate
    end
end

# =============================================[Expressions]=============================================
# Represents a general expression node
class Node_expression < Node
    attr_accessor :operator, :lhs, :rhs, :type
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @type = "nil"
    end

    # Returns the type, if one side is int while the other is float, convert the int side to float
    def get_type()
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        if lhs_type == "float" && rhs_type == "int"
            @type = "float"
        elsif rhs_type == "float" && lhs_type == "int"
            @type = "float"
        elsif lhs_type == rhs_type
            @type = lhs_type
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end

    # Constructs an array of nodes for array operations
    def array_construction(element, type)
        element_arr_list = []

        element.each do |sub_element|
            if sub_element.is_a? (Array)
                element_arr_list << Node_array.new(type, array_construction(sub_element, type))
            else
                element_arr_list << create_datatype_node(sub_element.to_s,type.split("_")[1])  
            end             
        end

        return element_arr_list
    end

    # Evaluates the expression
    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        # Handle array operations
        if lhs_type.include?("array") and rhs_type.include?("array")
            if lhs.size != rhs.size
                raise "Arithmetic operations between arrays with different sizes are not supported"
            end

            output_array = []

            for i in 1..lhs.size do
                if lhs[i-1].is_a?(Array) and rhs[i-1].is_a?(Array)

                    lhs_arr_list = array_construction(lhs[i-1],lhs_type)
                    rhs_arr_list = array_construction(rhs[i-1],rhs_type)

                    lhs_array = Node_array.new(lhs_type, lhs_arr_list)
                    rhs_array = Node_array.new(rhs_type, rhs_arr_list)

                    output_array << (Node_expression.new(lhs_array, @operator, rhs_array).evaluate)
                else
                    output_array << (Node_expression.new(create_datatype_node(lhs[i-1].to_s, lhs_type.split("_")[1]), @operator, create_datatype_node(rhs[i-1].to_s, rhs_type.split("_")[1])).evaluate)
                end
            end

            return output_array
        end
        
        # Don't allow char type in expressions
        if get_type === "char"
            raise TypeError, "The char type can not be used in expressions"
        end

        # Handle type conversion and evaluation
        if lhs_type=="float" && rhs_type == "int"
            @rhs.type = "float"
            return lhs.send(@operator,rhs.to_f)

        elsif rhs_type == "float" && lhs_type == "int"
            @lhs.type = "float"
            return lhs.to_f.send(@operator,rhs)

        elsif lhs_type == "bool" && rhs_type != "bool"
            return lhs.send(@operator,true_or_false(rhs))

        elsif rhs_type == "bool" && lhs_type != "bool"
            return true_or_false(lhs).send(@operator,rhs)

        elsif lhs_type == rhs_type
            if lhs_type === "char"
                return lhs.send(@operator,rhs)

            end

            return lhs.send(@operator,rhs)
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end
end

# Represents a logical expression node
class Node_logical_expression < Node_expression
    attr_accessor :operator, :lhs, :rhs, :type
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @type = "bool"
    end

    def get_type
        return @type
    end

    # Evaluates the logical expression
    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        if lhs_type.include?("array") and rhs_type.include?("array")
            lhs = lhs.empty? ?  false : true
            rhs = rhs.empty? ?  false : true
                
            return Node_expression.new(Node_bool.new(lhs.to_s), @operator, Node_bool.new(rhs.to_s)).evaluate
        end

        super()
    end
end

# Represents a comparison expression node
class Node_comparison_expression < Node_expression
    attr_accessor :operator, :lhs, :rhs, :type
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @type = "bool" # Comparison expressions always evaluate to boolean
    end

    def get_type
        return @type
    end

    # Evaluates the comparison expression
    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        # Handle comparisons involving arrays
        if (lhs_type.include?("array")||lhs_type == "nil") and (rhs_type.include?("array")||rhs_type == "nil")
            min = lhs.size >= rhs.size ? rhs.size : lhs.size

            # Compare each element in the arrays
            for i in 1..min do
                if lhs[i-1] != rhs[i-1]
                    if lhs[i-1].is_a?(Array) and rhs[i-1].is_a?(Array)
                        lhs_arr_list = array_construction(lhs[i-1],lhs_type)
                        rhs_arr_list = array_construction(rhs[i-1],rhs_type)
    
                        lhs_array = Node_array.new(lhs_type, lhs_arr_list)
                        rhs_array = Node_array.new(rhs_type, rhs_arr_list)
    
                        return (Node_comparison_expression.new(lhs_array, @operator, rhs_array).evaluate)
                    else
                        return Node_expression.new(create_datatype_node(lhs[i-1].to_s, lhs_type.split("_")[1]), @operator, create_datatype_node(rhs[i-1].to_s, rhs_type.split("_")[1])).evaluate
                    end
                end
            end
            return Node_expression.new(create_datatype_node(lhs.size.to_s, "int"), @operator, create_datatype_node(rhs.size.to_s, "int")).evaluate
        end

        super()
    end
end

# Represents a logical NOT node
class Node_not < Node
    def initialize(value)
        @value = value
        @type = "bool"
    end

    def get_type()
        return @type
    end

    # Evaluates the NOT expression
    def evaluate()
        return !@value.evaluate
    end
end

# Represents a negative value node
class Node_negative < Node
    def initialize(value)
        @value = value
    end

    def get_type()
        return @value.get_type
    end

    # Evaluates the negative value expression
    def evaluate()
        return -@value.evaluate
    end
end

# =============================================[Conversions]=============================================
# Represents a conversion to character node
class Node_to_char < Node
    def initialize(value)
        @value = value
    end

    def get_type()
        return "char"
    end

    # Evaluates the conversion to character
    def evaluate()
        return_value = @value.evaluate
        return_value = return_value.to_s[0]

        return return_value
    end
end

# Represents a conversion to integer node
class Node_to_int < Node
    def initialize(value)
      @value = value
    end
    
    def get_type()
        return "int"
    end

    # Evaluates the conversion to integer
    def evaluate()
        case @value.get_type
        in "float"
            return @value.evaluate.floor
        in "bool"
            return @value.evaluate ? 1 : 0
        in "char"
            return (@value.evaluate =~ /\d/) ? @value.evaluate.to_i : raise(TypeError, "Type conversion is not supported for this type")
        in "int"
            return @value.evaluate    
        else
            raise TypeError, "Type conversion is not supported for this type"
        end
    end
end

# Represents a conversion to float node
class Node_to_float < Node
    def initialize(value)
        @value = value
    end

    def get_type()
        return "float"
    end
    
    # Evaluates the conversion to float
    def evaluate()
        case @value.get_type
        in "float"
            return @value.evaluate
        in "bool"
            return @value.evaluate ? 1.0 : 0.0
        in "char"
            return (@value.evaluate =~ /\d/) ? @value.evaluate.to_f : raise(TypeError, "Type conversion is not supported for this type")
        in "int"
            return @value.evaluate.to_f   
        else
            raise TypeError, "Type conversion is not supported for this type"
        end
    end
end

# Represents a conversion to boolean node
class Node_to_bool < Node
    def initialize(value)
      @value = value
    end
    
    def get_type()
        return "bool"
    end

    # Evaluates the conversion to boolean using the true_or_false helper function
    def evaluate()
        if true_or_false(@value.evaluate)
            return true
        end

        return false
    end
end

# Represents a conversion to array node
class Node_to_array < Node
    def initialize(value)
      @value = value
      @type = "nil"
    end
    
    def get_type
        if @type == "nil"
            evaluate()
        end

        return @type
    end
    
    # Evaluates the conversion to array 
    def evaluate()
        @value = Node_array.new("nil", [@value])
        @type = @value.get_type 

        return @value.evaluate
    end
end

# =============================================[Print]=============================================
# Represents a print statement node
class Node_print < Node
    def initialize(exp)
        @exp = exp
    end

    def evaluate()
        @exp.each do |e|
            print e.evaluate
        end
        print("\n")
        
        return nil
    end
end
