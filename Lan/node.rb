#!/usr/bin/env ruby
require "scope.rb"

class node
    def evaluate(scope)
        raise NotImplementedError, "Must implement #{self.class}.evaluate"
    end
end

class node_variable
    def initialize(value)
        @value = value
    end

    def evaluate()
        return @value
    end
end

