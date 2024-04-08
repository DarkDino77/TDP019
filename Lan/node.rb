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
            if variables.has_key?(name)

                temp = @@variable_stack[stack_counter][name]
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
            if variables.has_key?(name)
                temp = @@function_stack[stack_counter][name]
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
        #pp "retrun node --------------------------#{@expr.evaluate}"
        @expr.evaluate
    end
end


class Node_statement_list < Node
    def initialize(statement, statement_list = nil)
        @statement = statement
        @statement_list = statement_list
    end

    def evaluate()
       # pp @statement

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

class Node_array_add < Node
    def initialize(name, var)
        @name = name
        @var = var
    end

    def evaluate()
        target_array = look_up_var(@name)

        if target_array["type"].include?("array")
            if target_array["const"] == false
                # pp "HELLO"
                @var.each do |m|
                    if m.get_type == nil || target_array["type"].include?(m.get_type)
                        current_value = eval(target_array["value"])
                        # pp "BYE"
                        current_value << eval(m.evaluate)
                        
                        target_array["value"] = current_value.to_s
                    else
                        raise TypeError, "Array expected #{target_array["type"].split("_")[1]} but got a #{m.get_type()}"
                    end
                end                
            else
                raise "Variable with name #{@name} is const"
            end
        else
            raise TypeError, "Variable with the name #{@name} is not a Array"
        end
        return target_array["value"]
    end
end

class Node_array_remove < Node
    def initialize(name, index = "nil")
        @name = name
        @index = index
    end
    
    def evaluate()
        target_array = look_up_var(@name)
        return_value = "nil"
        

        if target_array["type"].include?("array")
            if target_array["const"] == false

                if @index != "nil"
                    index = eval(@index.evaluate)
                    if index <= eval(target_array["value"]).size-1 && index >= 0 
                        return_value = remove_index(target_array, index)
                    else
                        raise IndexError, "outofrange"
                    end
                else
                    return_value = remove_index(target_array, eval(target_array["value"]).size-1)
                end
            else
                raise "Variable with name #{@name} is const"
            end
        else
            raise TypeError, "Variable with the name #{@name} is not a Array"
        end
        
        return return_value.to_s
    end

    def remove_index(target_array, index)
        current_value = eval(target_array["value"])
        return_value = current_value[index]
        current_value.delete_at(index)
        target_array["value"] = current_value.to_s
        return return_value
    end
end

class Node_array_accessor < Node
    def initialize(name, index)
        @name = name
        @index = index
    end

    def evaluate()
        target_array = look_up_var(@name)
        return_value = "nil"
        index = eval(@index.evaluate)
        if target_array["type"].include?("array")
            if index <= eval(target_array["value"]).size-1 && index >= 0 
                return_value = eval(target_array["value"])[index]
            else
                raise IndexError, "outofrange"
            end
        else
            raise TypeError, "Variable with the name #{@name} is not a Array"
        end
        return return_value.to_s
    end
end

class Node_array < Node
    attr_accessor :values
    def initialize(type, values)
        @type = type
        @values = values
    end

    def get_type
        return @type
    end

    def evaluate()
        # Kontrollera att alla värden är av rätt typ
        output = []
        @values.each do |m|
            if m.is_a?(Node_array) && m.get_type == nil
                m.update_type("array_"+m.values[0].get_type)
            end
            if @type === nil
                update_type("array_"+m.get_type)
            end
            if m.get_type != @type  
                if m.get_type() != @type.split("_")[1]
                    raise TypeError, "Array expected #{@type.split("_")[1]} but got a #{m.get_type()}"
                end
            end
            output << eval(m.evaluate)
        end
        return output.to_s
    end

    def update_type(type)
        @type = type
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
        #pp look_up_var(@name)["value"]
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
    attr_accessor :name, :variable_list, :function_body, :type
    def initialize(name, variable_list = [], function_body, type)
        @name = name
        @variable_list = variable_list 
        @function_body = function_body
        @type = type
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
        @type = look_up_fun(@name).type
        return @type
    end

    def evaluate()
        #pp @@function_stack
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
            #pp @@variable_stack
            #pp fun.variable_list

            return_value = fun.function_body.evaluate
            if fun.function_body.is_a?(Node_return)
               
            elsif return_value.is_a?(Node_return)
                #pp return_value
                #pp "hello---------------------------------------------, The return value is:", return_value
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


