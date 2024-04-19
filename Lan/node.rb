#!/usr/bin/env ruby

# ---------------------------------------[Base]---------------------------------------
class Node
    @@variable_stack = [{}]
    @@function_stack = [{}]
    @@current_scope = 0
    def evaluate()
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
    
    def new_scope
        @@variable_stack << {}
        @@function_stack << {}
        @@current_scope += 1
    end
    
    def close_scope
        @@variable_stack.pop()
        @@function_stack.pop()
        @@current_scope -= 1
    end

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
    
    def true_or_false(value)
        if value == 0 || (value.is_a?(Array) && value.empty?()) || value == ""
            return false
        end
        return value 
    end
end

class Node_statement_list < Node
    def initialize(statement, statement_list = nil)
        @statement = statement
        @statement_list = statement_list
    end

    def evaluate()
        return_value = @statement.evaluate()
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

class Node_standalone_scope < Node
    def initialize(stmt)
        @stmt = stmt
    end

    def evaluate()
        new_scope()
        @stmt.evaluate
        close_scope()
    end
end

# ---------------------------------------[Variables]---------------------------------------
class Node_datatype < Node
    attr_accessor :value, :type
    def initialize(value, type)
        @value = eval(value)
        @type = type
    end

    def get_type()
        return @type
    end

    def evaluate()
        return @value
    end
end

class Node_variable < Node
    attr_accessor :name
    def initialize(name)
        @name = name
    end

    def get_type()
        return look_up_var(@name)["type"]
    end
    
    def evaluate()
        return look_up_var(@name)["value"]
    end
end

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
    
    def remove_const()
        @const = false
    end
end

class Node_auto_assignment < Node_assignment
    def initialize(name, value)
        @name = name
        @value = value
        @type = "nil"
        @const = true
    end

    def evaluate
        @type = @value.get_type
        super
    end
end

class Node_re_assignment < Node
    def initialize(name, value)
        @name = name
        @value = value
    end

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
        nil
    end
end

# ---------------------------------------[Arrays]---------------------------------------
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
                   # pp @type
                    raise TypeError, "Array expected #{@type.split("_")[1]} but got a #{m.get_type()}"
                end
            end
            output << m.evaluate
        end
        return output
    end

    def update_type(type)
        @type = type
    end
end

class Node_array_accessor < Node
    attr_accessor :name, :index
    def initialize(name, index)
        @name = name
        @index = index
    end

    def evaluate()
        target_array = look_up_var(@name)
        return_value = "nil"

        index = @index[0].evaluate # [0] -> [-1]


        if @index.size == 2
            #pp " tryig: #{target_array["value"][index]} [#{@index[1].evaluate}]"
            # pp "First: #{target_array["value"][index]}, second: #{@index[1].evaluate}"
            index = target_array["value"][index][@index[1].evaluate]
        end

        unless target_array["type"].include?("array")
            raise TypeError, "Variable with the name #{@name} is not a Array"
        end

        unless index <= target_array["value"].size-1 && index >= 0 
            raise IndexError, "outofrange"
        end

        return_value = target_array["value"][index]

        return return_value
    end
end

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



class Node_array_add < Node
    def initialize(target_variable, var)
        @target_variable = target_variable
        @var = var
    end

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

        target_array["value"]
    end
end



class Node_array_remove < Node
    def initialize(target_variable, index = "nil")
        @target_variable = target_variable
        @index = index
    end
    
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

    def remove_index(index)
        current_value = @target_variable.evaluate
        return_value = current_value[index]
        current_value.delete_at(index)

        return return_value
    end
end

# ---------------------------------------[Control]---------------------------------------
class Node_if < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end
    
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
        nil
    end
end

class Node_while < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end

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
        nil
    end
end

# ---------------------------------------[Functions]---------------------------------------
class Node_function < Node
    attr_accessor :name, :variable_list, :function_body, :type
    def initialize(name, variable_list, function_body, type = "nil")
        @name = name
        @variable_list = variable_list 
        @function_body = function_body
        @type = type
    end

    def evaluate()
        @@function_stack[@@current_scope][@name] = self
        nil
    end
end

class Node_function_call < Node
    attr_accessor :type
    def initialize(name, variable_list)
        @name = name
        @variable_list = variable_list
        @type = "nil"
    end

    def get_type()
        @type = look_up_fun(@name).type unless look_up_fun(@name).type == "nil"
        if @type == "nil" 
            evaluate()
        end
        return @type
    end

    def evaluate()
        fun = look_up_fun(@name)

        unless fun != nil
            raise "The function with the name #{@name} does not exist"
        end
        
        if @variable_list.size != fun.variable_list.size
            raise "Wrong number of arguments, #{fun.name} expected #{fun.variable_list.size} arguments"
        end
        
        counter = 0
        @variable_list.each do |var|
            if var.get_type != fun.variable_list[counter].get_type
                raise "#{fun.name} expected a #{fun.variable_list[counter].get_type} at index #{counter}"
            end
            fun.variable_list[counter].value = var
            counter = counter + 1
        end

        new_scope()
        
        fun.variable_list.each do |var|
            var.evaluate()
        end
        
        if @type == "void"
            return nil
        end

        return_value = fun.function_body.evaluate

        if fun.function_body.is_a?(Node_return)
            set_type(fun.function_body)
        elsif return_value.is_a?(Node_return)
            set_type(return_value)
            return_value = return_value.evaluate
        else 
            return_value = nil
        end

        close_scope()

        return return_value
    end

    def set_type(value)

        @type = value.get_type
    end
end

class Node_return < Node
    def initialize(expr)
        @expr = expr
    end
    def get_type()
        @expr.get_type
    end
    def evaluate()
        @expr.evaluate
    end
end

# ---------------------------------------[Expressions]---------------------------------------
class Node_expression < Node
    attr_accessor :operator, :lhs, :rhs, :type
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @type = "nil"
    end

    def get_type()
        if @lhs.get_type=="float" && @rhs.get_type == "int"
            @type = "float"
        elsif @rhs.get_type=="float" && @lhs.get_type == "int"
            @type = "float"
        elsif @lhs.get_type() == @rhs.get_type()
            @type = @lhs.get_type()
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end

    def array_construction(element, type)
        element_arr_list = []

        element.each do |sub_element|
            if sub_element.is_a? (Array)
                element_arr_list << Node_array.new(type, array_construction(sub_element, type))
            else
                element_arr_list << Node_datatype.new(sub_element.to_s,type.split("_")[1])     
            end             
        end
        return element_arr_list
    end

    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type
        # pp lhs, rhs,lhs_type, rhs_type
        if lhs_type.include?("array") and rhs_type.include?("array")
            if lhs.size != rhs.size
                raise "Arithmetic operations between arrays with different sizes are not supported"
            end

            output_array = []

            for i in 1..lhs.size do
                if lhs[i-1].is_a?(Array) and rhs[i-1].is_a?(Array)

                    # Room for improvement
                    # pp "lhs: #{lhs[i-1]}, rhs: #{rhs[i-1]}"

                    lhs_arr_list = array_construction(lhs[i-1],lhs_type)
                    rhs_arr_list = array_construction(rhs[i-1],rhs_type)

                    # pp lhs_arr_list
                    lhs_array = Node_array.new(lhs_type, lhs_arr_list)
                    rhs_array = Node_array.new(rhs_type, rhs_arr_list)


                    output_array << (Node_expression.new(lhs_array, @operator, rhs_array).evaluate)
                else
                    output_array << (Node_expression.new(Node_datatype.new(lhs[i-1].to_s, lhs_type.split("_")[1]), @operator, Node_datatype.new(rhs[i-1].to_s, rhs_type.split("_")[1])).evaluate)
                end
            end

            return output_array
        end

        if !lhs.is_a?(String)
            lhs = lhs.to_s
        end
        
        if !rhs.is_a?(String)
            rhs = rhs.to_s
        end
        
        if get_type === "char"
            raise TypeError, "The char type can not be used in expressions"
        end

        if lhs_type=="float" && rhs_type == "int"
            @rhs.type = "float"
            return eval(lhs + @operator + rhs + ".0")

        elsif rhs_type == "float" && lhs_type == "int"
            @lhs.type = "float"
            return eval(lhs + ".0" + @operator + rhs)

        # elsif get_type === "bool"
        #     return eval(true_or_false(lhs) + @operator + true_or_false(rhs))            
            
        elsif lhs_type == rhs_type
            if lhs_type === "char"
                return eval("'" + lhs + "'" + @operator + "'" + rhs + "'")
            end
        
            return eval(lhs + @operator + rhs)
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end
end

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

    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        if lhs_type.include?("array") and rhs_type.include?("array")
            lhs = lhs.empty? ?  false : true
            rhs = rhs.empty? ?  false : true
                
            return Node_expression.new(Node_datatype.new(lhs.to_s, "bool"), @operator, Node_datatype.new(rhs.to_s, "bool")).evaluate
        end

        super()
    end
end

class Node_comparison_expression < Node_expression
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

    def evaluate()
        lhs = @lhs.evaluate()
        rhs = @rhs.evaluate()
        
        lhs_type = @lhs.get_type
        rhs_type = @rhs.get_type

        if (lhs_type.include?("array")||lhs_type == "nil") and (rhs_type.include?("array")||rhs_type == "nil")
            min = lhs.size >= rhs.size ? rhs.size : lhs.size

            for i in 1..min do
                if lhs[i-1] != rhs[i-1]
                    if lhs[i-1].is_a?(Array) and rhs[i-1].is_a?(Array)
                        lhs_arr_list = array_construction(lhs[i-1],lhs_type)
                        rhs_arr_list = array_construction(rhs[i-1],rhs_type)
    
                        lhs_array = Node_array.new(lhs_type, lhs_arr_list)
                        rhs_array = Node_array.new(rhs_type, rhs_arr_list)
    
                        return (Node_comparison_expression.new(lhs_array, @operator, rhs_array).evaluate)
                    else
                        if lhs_type.include?("char")
                            return Node_expression.new(Node_datatype.new(("'"+lhs[i-1]+"'"), lhs_type.split("_")[1]), @operator, Node_datatype.new(("'"+rhs[i-1]+"'"), rhs_type.split("_")[1])).evaluate
                        end
                        return Node_expression.new(Node_datatype.new(lhs[i-1].to_s, lhs_type.split("_")[1]), @operator, Node_datatype.new(rhs[i-1].to_s, rhs_type.split("_")[1])).evaluate
                    end
                end
            end
            return Node_expression.new(Node_datatype.new(lhs.size.to_s, "int"), @operator, Node_datatype.new(rhs.size.to_s, "int")).evaluate
        end

        

        super()
    end
end

class Node_not < Node
    def initialize(value)
        @value = value
        @type = "bool"
    end
    def get_type()
        return @type
    end
    def evaluate()
        return !@value.evaluate
    end
end

class Node_negative < Node
    def initialize(value)
        @value = value
    end

    def get_type()
        return @value.get_type
    end

    def evaluate()
        return -@value.evaluate
    end
end

# ---------------------------------------[Conversions]---------------------------------------

class Node_to_char < Node
  def initialize(value)
    @value = value
  end

  def evaluate()
    return_value = @value.evaluate
    return_value = return_value.to_s[0]
    return return_value
  end
end

class Node_to_int < Node
    def initialize(value)
      @value = value
    end
    
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

class Node_to_float < Node
    def initialize(value)
        @value = value
    end

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
  
class Node_to_bool < Node
    def initialize(value)
      @value = value
    end
    
    def evaluate()
        if true_or_false(@value.evaluate)
            return true
        end

        return false
    end
end

class Node_to_array < Node
    def initialize(value)
      @value = value
    end
    
    def evaluate()
        return Node_array.new("nil", [@value]).evaluate
    end
end

# ---------------------------------------[Print]---------------------------------------

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