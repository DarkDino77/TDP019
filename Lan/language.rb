#!/usr/bin/env ruby
require './rdparse.rb'
require './node.rb'

class LanguageParser  
    attr_accessor :language_parser
    def initialize


        @language_parser = Parser.new("language parser") do
            token(/\s+/)
            token(/(?<![\w-])and(?![\w-])|&&/) {:and}
            token(/(?<![\w-])or(?![\w-])|\|\|/) {:or}
            token(/(?<![\w-])not(?![\w-])/) {:not}
            token(/(?<![\w-])true(?![\w-])/) {:true}
            token(/(?<![\w-])false(?![\w-])/) {:false}
            token(/(?<![\w-])mod(?![\w-])/) {:mod}
            token(/(?<![\w-])int(?![\w-])/) {:int_token}
            token(/(?<![\w-])float(?![\w-])/) {:float}
            token(/(?<![\w-])char(?![\w-])/) {:char}
            token(/(?<![\w-])bool(?![\w-])/) {:bool}
            token(/(?<![\w-])auto(?![\w-])/) {:auto}
            token(/(?<![\w-])if(?![\w-])/) {:if}
            token(/(?<![\w-])while(?![\w-])/) {:while}

            # token(/\{/) {:statement_list_start_symbol}
            # token(/\}/) {:statement_list_end_symbol}

            token(/\d/) {|m| m } #behövs?
            token(/[a-zA-Z]/) {|m| m } #behövs?
            token(/\A(==|<=|>=|!=|\*\*)/) {|m|  m}
            token(/\A!/) {:not}

            token(/./) {|m| m}

            start :program do
                match(:statement_list) do |m|        
                    pp m
                    m.evaluate
                end
            end

            rule :statement_list do 
                # Fixa så att scopes kan skapas mitt i kod
                match(:statement, :statement_list){|stm, stm_l| Node_statement_list.new(stm, stm_l)}
                match(:statement)
            end

            rule :statement do 
                match(:assignment, ";") 
                match(:re_assignment, ";")
                match(:control)
                match(:function_call, ";")
                match(:function_def)
                match(:logical_expression, ";")
                match(:variable_call, ";")
            end
            
            rule :assignment do 
                match(:mod, :assignment){|_, node|
                    node.remove_const()
                    node
                }
                match(:int_token, :variable, "=", :expression) {|_, name,_,value|
                    type = "int" # Sätt 'Type' dyamiskt 
                    Node_assignment.new(type, name, value)
                }
                match(:int_token, :variable){|_, name,_,value|
                    type = "int" # Sätt 'Type' dyamiskt 
                    Node_assignment.new(type, name, value)
                }
            end

            rule :re_assignment do
                match(:variable, "=", :logical_expression) { |name,_,value|
                    Node_re_assignment.new(name, value)
                }
            end

            rule :control do
                match(:if_expression) {|m| m}
                match(:while_expression)
            end

            rule :if_expression do
                match(:if , "(", :logical_expression, ")", "{",:statement_list,"}") {|_,_,expression,_,_,scope,_|
                    l = Node_if.new(expression, scope)
                    # pp l
                    l
                }
            end
            
            rule :logical_expression do 
                match(:logical_term, :or, :logical_expression)  {|a,b,c| Node_expression.new(a,b,c)}
                match(:logical_term)
            end
            
            rule :logical_term do 
                match(:logical_factor, :and, :logical_term)  {|a,b,c| Node_expression.new(a,b,c)}
                match(:logical_factor)
            end

            rule :logical_factor do
                #åter kom och fixa yep
                match(:not, :logical_factor) {|_,m| Node_datatype.new("!"+m.evaluate(), "bool")} 
                match(:comparison_expression)
            end

            rule :comparison_expression do
                match(:expression, :comparison_operator, :expression)  {|a,b,c| Node_expression.new(a,b,c)}
                match(:expression)
            end

            rule :comparison_operator do
                match("<") {|m| m}
                match(">") {|m| m}
                match("<="){|m| m}
                match(">="){|m| m}
                match("!="){|m| m}
                match("=="){|m| m}
            end

            rule :expression do
                match(:term, "+", :expression ) {|a,b,c| Node_expression.new(a,b,c)}
                match(:expression, "-", :term) {|a,b,c| Node_expression.new(a,b,c)}
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
                match("-", "(", :expression, ")") {|_,_,m,_| 
                    m.lhs.value = "-" + m.lhs.value
                    m.rhs.value = "-" + m.rhs.value
                    m
                }
                match("(", :expression, ")") {|_,m,_| m }
                match("\"", :char ,"\"") {|m| Node_datatype.new(m, "char")}
                match(:bool) {|m| Node_datatype.new(m.name, "bool")}
                match(:variable_call)
                match(:unary)
            end
            
            rule :unary do
                match("-", :float){|_, m| Node_datatype.new("-" + m, "float")}
                match(:float){|m| Node_datatype.new(m, "float")}
                match("-", :int){|_, m| Node_datatype.new("-" + m, "int")}
                match(:int){|m| Node_datatype.new(m, "int")}
            end
           

            rule :variable_call do
                match(:variable) {|m| Node_variable.new(m)}
                match(:variable, "[", :int ,"]")
            end

            rule :variable do
                # match(:variable, :digit)
                # match(:char, :variable)
                match(:char) {|m| m }
            end

            rule :array do
                match(:type, "[", "]")
            end

            rule :type do
                match(:int_token)
                match(:float)
                match(:bool)
                match(:char)
                match(:auto)
            end

            rule :float do
                match(:int, ".", :int) {|a,b,c| a+b+c }
                match(".", :int) {|a,b| a+b }
            end

            rule :int do
                match(:int, :digit){|m, a| m + a }
                match(:digit){|m| m}
            end

            rule :bool do
                match(:true) 
                match(:false)
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

    def read_file(filename)
        file = IO.readlines(filename, chomp: true)
        file = file.join(" ")
    
        parse_code(file)
    end

    def parse_code(data)
        parsed = @language_parser.parse(data)

        output = ""

        pp parsed
        parsed 
    end

    def execute(data)
        if done(data)
            pass
        else
            output=parse_code(data)
        
            return output
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
#pp l.read_file("test_program.gph")
#l.roll()

