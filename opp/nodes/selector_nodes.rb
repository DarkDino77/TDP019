require_relative "./nodes.rb"
require_relative "./variable_nodes.rb"

class BLSelector
    attr_reader :in_loop 
    def initialize(selector_stmt, body)
        @selector_stmt = selector_stmt
        @body = body
        @in_loop = false

        # If we are initializing a loop than go through and set all selectors inside to say we are a loop
        # this is used by if and else so they know if break or continue are valid inside them
        if(self.class < BLLoop)
            @body.each do |stmt|
                if(stmt.class < BLSelector)
                    stmt.in_loop = true
                end
            end
        end
    end

    # Helper function to evaluate the selector statements and check if their result is a bool
    def eval_selector(scope)
        result_addr = @selector_stmt.eval(scope)
        if(!(scope.type(result_addr) == BLBool))
            raise "#{self.class.type} was given #{scope.type(result_addr)} as a selector, needs to be a bool"
        end
        return result_addr
    end

    # Assignment function for in_loop that goes through itself in order to tell selectors inside of it that they are in a loop
    def in_loop=(in_loop)
        # We dont go through and set it we are a loop because then we have alredy told all selectors inside that we are a loop
        if(self.class < BLLoop)
            return nil
        end
        @in_loop = in_loop
        if(in_loop)
            @body.each do |stmt|
                if(stmt.class < BLSelector)
                    stmt.in_loop = true
                end
            end
        end
        return nil 
    end

    
end

# Empty class that is used to identify loops
class BLLoop < BLSelector

end 

class BLWhile < BLLoop
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Get the addresses of all the special variables
        break_addr = scope.address(:break)
        continue_addr = scope.address(:continue)
        return_addr = scope.address(:return)
        
        # while selector_stmt evals to true and the break_flag is false
        while($memory.get(eval_selector(scope)) && (!$memory.get(break_addr))) 
            # Loop for evaluating all the statements in the body
            @body.each do |stmt|
                stmt.eval(scope)
                if($memory.get(return_addr) != nil)
                    # If return has been set then set break to true and break out of the body eval
                    $memory.set(break_addr, true)
                    break
                elsif($memory.get(break_addr))
                    # Break out of the body eval if break is set
                    break
                elsif($memory.get(continue_addr))
                    # Set continue to false and break out of the body eval
                    $memory.set(continue_addr, false)
                    break
                end
            end
        end
        # Reset the continue and break variables in case we are in a loop
        $memory.set(break_addr, false)
        $memory.set(continue_addr, false)
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "while"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┠─Selector"
        print level + "┃ ┖─"
        @selector_stmt.print_tree(level + "┃   ")

        puts level + "┖─Body"
        level += "  "
        @body.each_with_index do |stmt, index| 
            if(index + 1 < @body.length)
                print level + "┠─"
                stmt.print_tree(level + "┃ ") 
            else
                print level + "┖─"
                stmt.print_tree(level + "  ") 
            end
        end
    end
end

class BLFor < BLLoop
    def initialize(var_init, selector_stmt, increment_stmt, body)
        @var_init = var_init
        @selector_stmt = selector_stmt
        @increment_stmt = increment_stmt
        @body = body

        @body.each do |stmt|
            if(stmt.class < BLSelector)
                stmt.in_loop = true
            end
        end
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Evaluate the first statement in the for declaration so we create the loop variable
        @var_init.eval(scope)
        # Get the addresses of all the special variables
        break_addr = scope.address(:break)
        continue_addr = scope.address(:continue)
        return_addr = scope.address(:return)

        while($memory.get(eval_selector(scope)) && (!$memory.get(break_addr))) #while selector_stmt evals to true and the break_flag is false
            @body.each do |stmt|
                stmt.eval(scope)
                if($memory.get(return_addr) != nil)
                    # If return has been set then set break to true and break out of the body eval
                    $memory.set(break_addr, true)
                    break
                elsif($memory.get(break_addr))
                    # Break out of the body eval if break is set
                    break
                elsif($memory.get(continue_addr))
                    # Set continue to false and break out of the body eval
                    $memory.set(continue_addr, false)
                    break
                end
            end
            # Check if break if set so we can exit the while loop before calling the increment statement
            break if($memory.get(break_addr))
            @increment_stmt.eval(scope)
        end
        # Reset the continue and break variables in case we are in a loop
        $memory.set(break_addr, false)
        $memory.set(continue_addr, false)
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "for"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┠─Var Init"
        print level + "┃ ┖─"
        @var_init.print_tree(level + "┃   ")
        puts level + "┠─Selector"
        print level + "┃ ┖─"
        @selector_stmt.print_tree(level + "┃   ")
        puts level + "┠─Increment"
        print level + "┃ ┖─"
        @increment_stmt.print_tree(level + "┃   ")
        
        puts "#{level}┖─Body"
        @body.each_with_index do |stmt, index| 
            if(index + 1 < @body.length)
                print level + "  ┠─"
                stmt.print_tree(level + "  ┃ ") 
            else
                print level + "  ┖─"
                stmt.print_tree(level + "    ") 
            end
        end
    end
end

class BLIf < BLSelector
    @next_selector_stmt = nil
    # Sets the next node for an if elseif else chain
    def set_next_selector_node(selector_node)
        @next_selector_stmt = selector_node
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        selector_value = eval_selector(scope)
        #If selector_stmt evals to true
        if($memory.get(eval_selector(scope))) 
            # Get the addresses of all the special variables
            break_addr = scope.address(:break)
            continue_addr = scope.address(:continue)
            return_addr = scope.address(:return)

            @body.each do |stmt| 
                stmt.eval(scope)
                break if($memory.get(return_addr) != nil)
                if($memory.get(break_addr))
                    # Break if we are in a loop, otherwise raise error
                    break if(@in_loop)
                    raise SyntaxError.new("Invalid break in if, break can only exist inside loops")
                elsif($memory.get(continue_addr))
                    # Break if we are in a loop, otherwise raise error
                    break if(@in_loop)
                    raise SyntaxError.new("Invalid continue in if, continue can only exist inside loops")
                end
            end
        # If selector statement evaluated to false then call the next node in the if, else if, else chain if there is one
        elsif(@next_selector_stmt != nil)
            @next_selector_stmt.eval(scope)
        end
        return nil
    end

    # Same as in the base class but we also set the in_loop variable for the next node in the if, else if, else chain
    def in_loop=(in_loop)
        @in_loop = in_loop
        if(in_loop)
            @body.each do |stmt|
                if(stmt.class < BLSelector)
                    stmt.in_loop = true
                end
            end
        end
        if(@next_selector_stmt != nil)
            @next_selector_stmt.in_loop = true
        end
        return nil 
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "if"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┠─In loop: #{@in_loop}"
        puts level + "┠─Selector"
        print level + "┃ ┖─"
        @selector_stmt.print_tree(level + "┃   ")

        temp_level = level
        if(@next_selector_stmt != nil)
            puts level + "┠─Body"
            temp_level += "┃ "
        else
            puts level + "┖─Body"
            temp_level += "  "
        end

        @body.each_with_index do |stmt, index| 
            if(index + 1 < @body.length)
                print temp_level + "┠─"
                stmt.print_tree(temp_level + "┃ ") 
            else
                print temp_level + "┖─"
                stmt.print_tree(temp_level + "  ") 
            end
        end

        if(@next_selector_stmt != nil)
            print level + "┖─"
            @next_selector_stmt.print_tree(level + "  ")
        end
    end
end

class BLElse < BLSelector
    def initialize(body)
        @body = body
        @in_loop = false
    end

    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Get the addresses of all the special variables
        break_addr = scope.address(:break)
        continue_addr = scope.address(:continue)
        return_addr = scope.address(:return)

        @body.each do |stmt| 
            stmt.eval(scope)
            break if($memory.get(return_addr) != nil)
            if($memory.get(break_addr))
                # Break if we are in a loop, otherwise raise error
                break if(@in_loop)
                raise SyntaxError.new("Invalid break in if, break can only exist inside loops")
            elsif($memory.get(continue_addr))
                # Break if we are in a loop, otherwise raise error
                break if(@in_loop)
                raise SyntaxError.new("Invalid continue in if, continue can only exist inside loops")
            end
        end
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "else"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "#{self.class}"
        puts level + "┠─In loop: #{@in_loop}"
        puts level + "┖─Body"
        level += "  "
        @body.each_with_index do |stmt, index| 
            if(index + 1 < @body.length)
                print level + "┠─"
                stmt.print_tree(level + "┃ ") 
            else
                print level + "┖─"
                stmt.print_tree(level + "  ") 
            end
        end
    end
end

class BLBreak
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Set the break variable to true
        break_addr = scope.address(:break)
        $memory.set(break_addr, true)
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "break"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Break"
    end
end

class BLContinue
    # The function that is called when running the program to evaluate each node
    def eval(scope)
        # Set the continue variable to true
        continue_addr = scope.address(:continue)
        $memory.set(continue_addr, true)
        return nil
    end

    # Function for getting a nicer name when printing the tree or when raising errors
    def self.type
        return "continue"
    end

    # Function for printing a tree representation of the program
    def print_tree(level = "")
        puts "Continue"
    end
end