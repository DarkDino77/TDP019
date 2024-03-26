#!/usr/bin/env ruby
require './rdparse.rb'
require './node.rb'
require './scope.rb'

class LanguageParser  
    def initialize
        @@scope_stack = [Scope.new()]
        @@current_scope = @@scope_stack[0]


        @language_parser= Parser.new("language parser") do
            token(/\s+/)
            token(/(?<=\S\s)and(?=\s\S)|&&/) {:and}
            token(/(?<=\S\s)or(?=\s\S)|\|\|/) {:or}
            token(/(?<=\S\s)not(?=\s\S)|!/) {:not}
            token(/(?<=\S\s)true(?=\s\S)/) {:true}
            token(/(?<=\S\s)false(?=\s\S)/) {:false}
            token(/==|<=|>=|!=|\*\*/) {|m| m }
            token(/\d/) {|m| m }
            token(/[a-zA-Z]/) {|m| m }
            token(/./) {|m| m }

            start :program do
                match(:scope) do |m|                     
                    @@scope_stack << Scope.new(@@current_scope)
                    @@current_scope = @@scope_stack[-1]
                    m
                end
            end

            rule :scope do 
                match("{", :scope, "}")
                match(:operation, :scope)
                match(:operation)
            end

            rule :operation do 
                match(:assignment, ";")
                match(:control)
                match(:function_call, ";")
                match(:function_def)
                match(:logical_expression, ";")
                match(:variable_call, ";")
            end
            
            rule :logical_expression do 
                match(:logical_term, :or, :logical_expression)  
                match(:logical_term)
            end
            
            rule :logical_term do 
                match(:logical_factor, :and, :logical_term)  
                match(:logical_factor)
            end

            rule :logical_factor do
                match(:not, :logical_factor)  
                match(:comparison_expression)
            end

            rule :comparison_expression do
                match(:expression, :comparison_operator, :expression)  {|a,b,c| Node_expression.new(a,b,c)}
                match(:expression)
            end

            rule :comparison_operator do
                match("<")
                match(">")
                match("<=")
                match(">=")
                match("!=")
                match("==")
            end

            rule :expression do
                match(:term, "+", :expression) {|a,b,c| Node_expression.new(a,b,c)}
                match(:term, "-", :expression) {|a,b,c| Node_expression.new(a,b,c)}
                match(:term)
            end

            rule :term do
                match(:factor, "*", :term) {|a,b,c| Node_expression.new(a,b,c)}
                match(:factor, "/", :term) {|a,b,c| Node_expression.new(a,b,c)}
                match(:factor)
            end
        
            rule :factor do
                match(:atom, "**", :factor) {|a,b,c| Node_expression.new(a,b,c)}
                match(:atom, "%", :factor) {|a,b,c| Node_expression.new(a,b,c)}
                match(:atom)
            end
            
            rule :atom do
                match("(", :expression, ")")
                match("\"", :char ,"\""){|m| Node_datatype.new(m, "char")}
                match(:variable_call)
                match(:float){|m| Node_datatype.new(m, "float")}
                match(:int){|m| Node_datatype.new(m, "int")}
            end

            rule :variable_call do
                match(:variable)
                match(:variable, "[", :int ,"]")
            end

            rule :variable do
                match(:char)
                match(:char, :variable)
                match(:variable, :digit)
            end

            rule :array do
                match(:type, "[", "]")
            end

            rule :type do
                match("int")
                match("float")
                match("bool")
                match("char")
                match("auto")
            end

            rule :float do
                match(:int, ".", "int")
                match(".", :int)
            end

            rule :int do
                match(:int, :digit){|m, a| m + a }
                match(:digit){|m| m}
            end

            rule :bool do
                match(:true) {|m| Node_datatype.new(m, "bool")}
                match(:false) {|m| Node_datatype.new(m, "bool")}
            end

            rule :digit do
                match(/\d/) {|m| m}
            end

            rule :char do
                match(/[a-zA-Z]/) {|m| m}
            end
        end
    end
    
    def done(str)
        ["quit","exit","bye","done",""].include?(str.chomp)
    end
    
    def roll
        print "[lang] "
        str = gets.chomp
        if done(str)
            puts "Bye."
        else
            pp "innan"
            parsed = @language_parser.parse(str)
            pp parsed
            if parsed
                result = parsed.evaluate(@@current_scope) # Antag att detta är rot-noden i ditt syntaxträd
                puts "=> #{result}"
            else
                puts "Syntax error"
            end
            roll()
        end
    end
    
  
    def log(state = true)
        if state
            @diceParser.logger.level = Logger::DEBUG
        else
            @diceParser.logger.level = Logger::WARN
        end
    end
end

l = LanguageParser.new()
l.roll()

