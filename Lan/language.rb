#!/usr/bin/env ruby
require "rdparse.rb"
require "node.rb"
require "scope.rb"

class LanguageLexer   
    def initialize
      @diceParser = Parser.new("language lexer") do
        token(/\s+/)
        token((?<=\S\s)and(?=\s\S)|&&) {:and}
        token(/(?<=\S\s)or(?=\s\S)|\|\|/) {:or}
        token(/(?<=\S\s)not(?=\s\S)|!/) {:not}
        token(/(?<=\S\s)true(?=\s\S)/) {:true}
        token(/(?<=\S\s)false(?=\s\S)/) {:false}
        token(/==|<=|>=|!=|**/) {|m| m }
        token(/\d/) {:digit}
        token(/[a-zA-Z]/) {:char}
        token(/./) {|m| m }

        start :program do
            match(:scope)
        end
        rule :scope do 
            match(:operation) 
            match(:operation, :scope)          
            match({:scope})
        end
        rule :operation do 
            match(:assignment)
            match(:control)
            match(:function_call)
            match(:function_def)
            match(:logical_expression)
            match(:variable_call)
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
            mtch(:comparison_expression)
        end

        rule :comparison_expression do
            match(:expression, :comparison_operator, :expression)
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
        rule :expression 
            match(:term, "+", :expression)
            match(:term, "-", :expression)
            match(:term)
        end
        rule :term do
            match(:factor, "*", :term)
            match(:factor, "/", :term)
            match(:factor)
        end
      
        rule :factor do
            match(:atom, "**", :factor)
            match(:atom, "%", :factor)
            match(:atom)
        end
        
        rule :atom do
            match("(", :expression, ")")
            match("\"", :char ,"\"")
            match(:variable_call)
            match(:float)
            match(:int)
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
        char a = "a"
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
            match(:digit)
            match(:digit, :int)
        end

        rule :bool do
            match(:true)
            match(:false)
        end
    end
    
    def done(str)
      ["quit","exit","bye","done",""].include?(str.chomp)
    end
    
    def roll
      print "[diceroller] "
      str = gets
      if done(str) then
        puts "Bye."
      else
        puts "=> #{@diceParser.parse str}"
        roll
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
