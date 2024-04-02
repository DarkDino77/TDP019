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
        raise "Variable with the name #{name} was not found"
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
        raise "Variable with the name #{name} was not found"
    end
end


class Node_statement_list < Node
    def initialize(statement, statement_list)
        @statement = statement
        @statement_list = statement_list
    end
    def evaluate()
        @statement.evaluate
        @statement_list.evaluate 
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
        while (eval(@expression.evaluate)) do
            @statement_list.evaluate
        end
        close_scope()
        nil
    end
end

# class Node_if < Node
#     def initialize(expression, scope)
#         @expression = expression
#         @scope = scope
#         pp "@scope: #{@scope}"
#     end

#     def evaluate(scope)
#         l = Scope.new(scope)
        
#         previous_scope = scope

# #        scope.statement_stack << l

#         pp "--------------------------Eval: #{@scope}"
#         l.statement_stack = @scope
        
#         pp @expression
#         if eval(@expression.evaluate(scope)) 
#             pp "L is: #{l}"
#             return l.evaluate()
#         end

#         l.parent_scope.current_scope = previous_scope
#     end
# end


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
    def initialize(type, name, value)
        @name = name
        @value = value
        @type = type
        @const = true
    end
    
    def evaluate()
        if @@variable_stack.any? { |hash| hash.value?(@name) }
            raise "Variable with name #{@name} already exists"
        else
            @@variable_stack[@@current_scope][@name] = {"value" => @value.evaluate, "type" => @type, "const" => @const}
            return @value.evaluate
        end
    end
    
    def remove_const()
        @const = false
    end
end

class Node_function < Node
    def initialize(name, variable_list = [], function_body)
        @name = name
        @variable_list = variable_list 
        @function_body = function_body
    end

    def evaluate()
        @@function_stack[@@current_scope][@name] = self
        pp @@function_stack
        nil
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
            if var["const"] == false
                var["value"] = @value.evaluate
                return var
            else
                raise "Variable with name #{@name} is const"
            end
        else
            raise "Variable with name #{@name} not found"
        end
        nil
    end
end


class Node_expression < Node
    attr_accessor :operator, :lhs, :rhs
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
    end

    def get_type()
        pp "------------------------LHS: #{@lhs}"
        if @lhs.get_type() == @rhs.get_type()
            return @lhs.get_type()
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end

    def evaluate()
        #Fråga simon
      
        if @lhs.get_type() == @rhs.get_type()
            #return @lhs.evaluate(scope).send(@operator, @rhs.evaluate(scope)
            #output = eval(@lhs.evaluate() + @operator + @rhs.evaluate())
            pp @lhs, @operator, @rhs
            return eval(@lhs.evaluate() + @operator + @rhs.evaluate()).to_s
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end
end


