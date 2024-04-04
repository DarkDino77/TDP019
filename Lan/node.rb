#!/usr/bin/env ruby

# --------------------- SCOPE --------------------------

# ---------------------- NODE ---------------------------

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

    # looks up wheter the variable exists in the current scope or any parrent scope
    def look_up_var(name)
        stack_counter = @@variable_stack.size-1    
        @@variable_stack.reverse_each do |variables|
            if variables.has_key?(@name)
                temp = @@variable_stack[stack_counter][@name]
                return temp
            end
            stack_counter -=1
        end
        raise "Variable with the name #{name} was not found in scope with variables: #{@@variable_stack[@@current_scope]}, all scopes: #{@@variable_stack}"
    end

    # looks up wheter the variable exists in the current scope or any parrent scope
    def look_up_fun(name)
        stack_counter = @@function_stack.size-1    
        @@function_stack.reverse_each do |variables|
            if variables.has_key?(@name)
                temp = @@function_stack[stack_counter][@name]
                return temp
            end
            stack_counter -=1
        end
        raise "Function with the name #{name} was not found, function stack: #{@@function_stack[0-@@current_scope]}"
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


class Node_statement_list < Node
    def initialize(statement, statement_list)
        @statement = statement
        @statement_list = statement_list
    end

    def evaluate()
        if @statement.is_a?(Node_return)
            return @statement
        elsif @statement_list.is_a?(Node_return)
            @statement.evaluate
            return @statement_list
        else
            if @statement.evaluate.is_a?(Node_return)
                return @statement.evaluate
            else
                @statement.evaluate
                @statement_list.evaluate 
            end
        end
    end

end


class Node_datatype < Node
    attr_accessor :value, :type
    def initialize(value, type)
        @value = value
        @type = type
    end

    def get_type()
        return @type
    end

    def evaluate()
        return @value
    end
end

class Node_if < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end
    
    def evaluate
        new_scope()
        
        if eval(@expression.evaluate)
            return_value = @statement_list.evaluate()
            close_scope()
            if @statement_list.is_a?(Node_return)
                return @statement_list
            end
            return return_value
        end
        close_scope()
        "nil"
    end
end

class Node_while < Node
    def initialize(expression, statement_list)
        @expression = expression
        @statement_list = statement_list
    end

    def evaluate
        new_scope()       
        while (eval(@expression.evaluate)) do
            @statement_list.evaluate
        end
        close_scope()
        "nil"
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
        @value = value
        @type = type
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
                return var["value"] # <------ Return entire var?
            else
                raise "Variable with name #{@name} is const"
            end
        else
            raise "Variable with name #{@name} not found in scope with variables: #{@@variable_stack[@@current_scope]}"
        end
        "nil"
    end
end

class Node_function < Node
    attr_accessor :name, :variable_list, :function_body
    def initialize(name, variable_list = [], function_body)
        @name = name
        @variable_list = variable_list 
        @function_body = function_body
    end

    def evaluate()
        @@function_stack[@@current_scope][@name] = self
        "nil"
    end
end

class Node_function_call < Node
    attr_accessor :type
    def initialize(name, variable_list)
        @name = name
        @variable_list = variable_list
        @type = nil
    end
    
    def get_type()
        evaluate()
        return @type
    end

    def evaluate()
        fun = look_up_fun(@name)
        if fun != nil
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
            return_value = fun.function_body.evaluate
            
            if fun.function_body.is_a?(Node_return)
                @type = fun.function_body.get_type
            elsif return_value.is_a?(Node_return)
                @type = return_value.get_type
                return_value = return_value.evaluate
            else 
                return_value = "nil"
            end
            close_scope()
            #Node_datatype.new(return_value, @type_value)
            return return_value
        end
        raise "The function with the name #{@name} does not exist"
    end
end

class Node_expression < Node
    attr_accessor :operator, :lhs, :rhs, :type
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
        @type = nil
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

    def evaluate()
        #Fråga simon
        if @lhs.get_type=="float" && @rhs.get_type == "int"
            @rhs.type = "float"
            return eval(@lhs.evaluate() + @operator + @rhs.evaluate() + ".0").to_s
        elsif @rhs.get_type=="float" && @lhs.get_type == "int"
            @lhs.type = "float"
            return eval(@lhs.evaluate() + ".0" + @operator + @rhs.evaluate()).to_s
        elsif @lhs.get_type() == @rhs.get_type()
            #return @lhs.evaluate(scope).send(@operator, @rhs.evaluate(scope)
            #output = eval(@lhs.evaluate() + @operator + @rhs.evaluate())
            return eval(@lhs.evaluate() + @operator + @rhs.evaluate()).to_s
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self} BOTTOM"
        end
    end
end


