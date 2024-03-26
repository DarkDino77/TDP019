#!/usr/bin/env ruby

class Scope
    attr_accessor :variables, :functions, :parent_scope
    def initialize(parent_scope = nil)
        @variables = {}
        @functions = {}

        @parent_scope = parent_scope
    end

    # looks up wheter the variable exists in the current scope or any parrent scope
    def look_up_var(name)
        if @variables.has_key?(name)
            return @variables[name]
        elsif @parent_scope != nil && @parent_scope.look_up_var(name)         
            return @parent_scope.look_up_var(name)
        else
            # Change to logger
            print("Error: Variable not defined with name #{name}")
        end
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

    # Assigns a new value to a variable, searches recursively through parent scopes if not found.
    def assign_var(name, value)
        if @variables.has_key?(name)
            @variables[name] = value
        elsif @parent_scope != nil && @parent_scope.look_up_var(name)     
            return @parent_scope.assign_var(name, value)
        else
            # Change to logger
            print("Error: Variable not defined with name #{name}")
        end
    end
    def self.evaluate()
        
    end
end
