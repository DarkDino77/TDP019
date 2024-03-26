#!/usr/bin/env ruby
require "scope.rb"

class node
    def evaluate(scope)
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
end

class node_variable << node
    def initialize(value)
        @value = value
    end

    def evaluate()
        return @value
    end
end

class node_expression << node
    def initialize(lhs, operator, rhs)
        @lhs = lhs
        @operator = @operator
        @rhs = rhs
    end

    def evaluate()
        #Fråga simon
        #return eval("#{@lhs.evaluate}#{@operator}#{@rhs.evaluate}")
        return @lhs.evaluate.send(@operator, rhs.evaluate)
    end
end

class node_function
    

end

