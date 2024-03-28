#!/usr/bin/env ruby
#require './scope.rb'

# --------------------- SCOPE --------------------------
@@scope_stack = [{}]
@@current_scope = 0




# ---------------------- NODE ---------------------------

class Node
    def evaluate(scope)
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
end

class Node_datatype < Node
    attr_accessor :value, :type
    def initialize(value, type)
        @value = value
        @type = type
    end

    def get_type(scope)
        return @type
    end

    def evaluate(scope)
        return @value
    end
end

class Node_if < Node
    def initialize(expression, scope)
        @expression = expression
        @scope = scope
        pp "@scope: #{@scope}"
    end

    def evaluate(scope)
        l = Scope.new(scope)
        
        previous_scope = scope

#        scope.statement_stack << l

        pp "--------------------------Eval: #{@scope}"
        l.statement_stack = @scope
        
        pp @expression
        if eval(@expression.evaluate(scope)) 
            pp "L is: #{l}"
            return l.evaluate()
        end

        l.parent_scope.current_scope = previous_scope
    end
end


class Node_variable < Node
    attr_accessor :name
    def initialize(name)
        @name = name
    end

    def get_type(scope)
        return scope.look_up_var(@name)["type"]
    end
    
    def evaluate(scope)
        return scope.look_up_var(@name)["value"]
    end
end


class Node_expression < Node
    attr_accessor :operator, :lhs, :rhs
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = operator
        @rhs = rhs
    end

    def get_type(scope)
        if @lhs.get_type(scope) == @rhs.get_type(scope)
            return @lhs.get_type(scope)
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end

    def evaluate(scope)
        #Fråga simon
      
        if @lhs.get_type(scope) == @rhs.get_type(scope)
            #return @lhs.evaluate(scope).send(@operator, @rhs.evaluate(scope)
            output = eval(@lhs.evaluate(scope) + @operator + @rhs.evaluate(scope))
            return output.to_s
        else
            raise TypeError, "#{@lhs} is not the same type as #{@rhs} in #{self}"
        end
    end
end


