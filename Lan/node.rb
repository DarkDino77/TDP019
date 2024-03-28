#!/usr/bin/env ruby

# --------------------- SCOPE --------------------------

# ---------------------- NODE ---------------------------

class Node
    @@scope_stack = [{}]
    @@current_scope = 0
    def evaluate()
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
    def new_scope
        @@scope_stack << {}
        @@current_scope += 1
    end
    
    def end_scope
        @@scope_stack.pop()
        @@current_scope -= 1
    end

    # looks up wheter the variable exists in the current scope or any parrent scope
    def look_up_var(name)
        stack_counter = @@scope_stack.size-1
        
        @@scope_stack.reverse_each do |variables|
            if variables.has_key?(@name)
                temp = @@scope_stack[stack_counter][@name]
                return temp
            end
        end

        raise "Variable with the name #{name} was not found"
    end

    # looks up wheter the function exists in the current scope or any parrent scope
    def look_up_fun(name)
        if @functions.has_key?(name)
            return @functions[name]
        elsif @parent_scope != nil && @parent_scope.look_up_fun(name) 
            return @parent_scope.look_up_fun(name)
        else
            # Change to logger
            print("Error: function not defined with name #{name}")
        end
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


# class Node_variable < Node
#     attr_accessor :name
#     def initialize(name)
#         @name = name
#     end

#     def get_type(scope)
#         return scope.look_up_var(@name)["type"]
#     end
    
#     def evaluate(scope)
#         return scope.look_up_var(@name)["value"]
#     end

#     def remove_const()

#     end
# end

class Node_assignment < Node
    def initialize(type, name, value)
        @name = name
        @value = value
        @type = type
        @const = true
    end
    
    def evaluate()
        if @@scope_stack.any? { |hash| hash.value?(@name) }
            raise "Variable with name #{@name} already exists"
        else
            @@scope_stack[@@current_scope][@name] = {"value" => @value.evaluate, "type" => @type, "const" => @const}
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
        stack_counter = @@scope_stack.size-1
        @@scope_stack.reverse_each do |variables|
            if variables.has_key?(@name)
                if @@scope_stack[stack_counter][@name]["const"] == false
                    @@scope_stack[stack_counter][@name] = @value.evaluate
                    pp "NEW LIST: #{@@scope_stack}"
                    return @@scope_stack[stack_counter][@name] # Kontrollera om ska returneras
                else
                    raise "Variable with name #{@name} is const"
                end
            end
        end
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
            return eval(@lhs.evaluate() + @operator + @rhs.evaluate()).to_s
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end
end


