#!/usr/bin/env ruby

class Scope
    attr_accessor :variables, :functions, :parent_scope, :statement_stack
    def initialize(parent_scope = nil)
        @variables = {}
        @functions = {}
        @statement_stack = []
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
            return false
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
    def assign_var(name, value, type, const= true)
        if @parent_scope != nil && @parent_scope.look_up_var(name)     
            return @parent_scope.assign_var(name, value)
        else
            @variables[name] = {"value" => value, "type" => type, "const" => const}
        end
    end

    def re_assign_var(name, value)
        if self.look_up_var(name)
            stored_var = self.variables[name]
            if value.get_type(self) == stored_var["type"] && stored_var["const"] == false  
                self.variables[name]["value"] = value.evaluate(self)
            else
                raise "TypeError or ConstError" # 
            end
        else
            raise "Error: Variable does not exist with that name"
        end
    end
    
    def evaluate()
        @statement_stack.reverse_each do |m|
            m.evaluate(self)
        end

        return @statement_stack
    end
end
