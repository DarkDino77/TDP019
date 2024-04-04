#!/usr/bin/env ruby
require './rdparse.rb'
require './node.rb'

class LanguageParser  
    attr_accessor :language_parser
    def initialize
        @language_parser = Parser.new("language parser") do
            token(/\s+/)
            token(/\bprint\b/) {:print}
            token(/\btrue\b/) {:true}
            token(/\bfalse\b/) {:false}
            token(/\band\b|&&/) {:and}
            token(/\bor\b|\|\|/) {:or}
            token(/\bnot\b/) {:not}
            token(/\bmod\b/) {:mod}
            token(/\bint\b/) {:int_token}
            token(/\bfloat\b/) {:float_token}
            token(/\bchar\b/) {:char_token}
            token(/\bbool\b/) {:bool_token}
            token(/\bauto\b/) {:auto_token}
            token(/\breturn\b/) {:return}
            token(/\bif\b/) {:if}
            token(/\bwhile\b/) {:while}
            token(/\bdef\b/) {:def}

            # token(/\{/) {:statement_list_start_symbol}
            # token(/\}/) {:statement_list_end_symbol}

            token(/(?<![\w-])\d(?![\w-])/) {|m| m } #behövs?
            token(/(?<![\w-])[a-zA-Z_](?![\w-])/) {|m| m } #behövs?
            token(/\A(==|<=|>=|!=|\*\*)/) {|m|  m}
            token(/\A!/) {:not}

            token(/./) {|m| m}

            start :program do
                match(:statement_list) do |m|        
                    pp "============================[NODE TREE]============================", m, 
                    "==================================================================="
                    m.evaluate
                end
            end

            rule :statement_list do 
                # Fixa så att scopes kan skapas mitt i kod
                match(:statement, :statement_list){|stm, stm_l| 
                    Node_statement_list.new(stm, stm_l)}
                match(:statement)
            end

            rule :statement do 
                match(:print, "(", "'", :variable,"'", ")", ";") {|_,_,_,var,_,_,_|pp var}
                match(:print, "(", :variable_call, ")", ";") {|_,_,var,_,_|pp var}
                match(:print, "(", :expression, ")", ";") {|_,_,exp,_,_|pp exp}
                match(:return_statement, ";")
                match(:assignment, ";")
                match(:re_assignment, ";")
                match(:control)
                match(:function_call, ";")
                match(:function_def)
                match(:logical_expression, ";")
                match(:variable_call, ";")
            end
            
            rule :return_statement do
                match(:return, :logical_expression) {|_, expr| Node_return.new(expr)}
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
                match(:int_token, :variable){|_,name|
                    type = "int" # Sätt 'Type' dyamiskt
                    value = Node_datatype.new("0","int")
                    Node_assignment.new(type, name, value)
                }
                match(:float_token, :variable, "=", :expression) {|_, name,_,value|
                    type = "float" # Sätt 'Type' dyamiskt 
                    Node_assignment.new(type, name, value)
                }
                match(:float_token, :variable){|_,name|
                    type = "float" # Sätt 'Type' dyamiskt
                    value = Node_datatype.new("0.0","float")
                    Node_assignment.new(type, name, value)
                }
                match(:bool_token, :variable, "=", :logical_expression) {|_, name,_,value|
                    type = "bool" # Sätt 'Type' dyamiskt 
                    Node_assignment.new(type, name, value)
                }
                match(:bool_token, :variable){|_,name|
                    type = "bool" # Sätt 'Type' dyamiskt
                    value = Node_datatype.new("true","bool")
                    Node_assignment.new(type, name, value)
                }
                match(:char_token, :variable, "=", :atom) {|_, name,_,value|
                    type = "char" # Sätt 'Type' dyamiskt 
                    Node_assignment.new(type, name, value)
                }
                match(:char_token, :variable){|_,name|
                    type = "char" # Sätt 'Type' dyamiskt
                    value = Node_datatype.new("'a'","char")
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
                match(:while_expression){|m| m}
            end

            rule :if_expression do
                match(:if , "(", :logical_expression, ")", "{",:statement_list,"}") {|_,_,expression,_,_,scope,_|
                    Node_if.new(expression, scope)
                }
            end

            rule :while_expression do
                match(:while , "(", :logical_expression, ")", "{",:statement_list,"}") {|_,_,expression,_,_,scope,_|
                    Node_while.new(expression, scope)
                }
            end 

            rule :function_call do
                match(:variable, "(", :variable_list, ")") {| name, _, var_list, _|
                    Node_function_call.new(name, var_list.flatten)} 
                match(:variable, "(", ")"){| name, _, _|
                    Node_function_call.new(name, [])}
            end

            rule :variable_list do
                match(:logical_expression, ",", :variable_list) {|m, _, n| [m] << [n] }
                match(:logical_expression) {|m| [m] }
            end

            rule :function_def do
                match(:def, :type, :variable, "(", ")", "{",:statement_list, "}") {|_, type, name, _, _, _, stmt_list, _|
                    Node_function.new(name, [], stmt_list, type.name.split('_')[0])}
                match(:def, :type, :variable, "(", :assignment_list, ")", "{",:statement_list, "}") {|_, type, name, _, ass_list, _, _, stmt_list, _|
                    Node_function.new(name, ass_list.flatten, stmt_list, type.name.split('_')[0])} 
            end

            rule :assignment_list do
                match(:assignment, ",", :assignment_list) {|m, _, n| [m] << [n] }
                match(:assignment) {|m| [m] }
            end


            rule :logical_expression do 
                match(:logical_term, :or, :logical_expression)  {|a,b,c| Node_expression.new(a,"||",c)}
                match(:logical_term)
            end
            
            rule :logical_term do 
                match(:logical_factor, :and, :logical_term)  {|a,b,c| Node_expression.new(a,"&&",c)}
                match(:logical_factor)
            end

            rule :logical_factor do
                #återkom och fixa yep
                match(:not, :logical_factor) {|_,m| Node_datatype.new(eval("!" + m.evaluate()).to_s, "bool")} 
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
                match(:function_call)
                match("-", "(", :expression, ")") {|_,_,m,_| 
                    m.lhs.value = "-" + m.lhs.value
                    m.rhs.value = "-" + m.rhs.value
                    m
                }
                match("(", :expression, ")") {|_,m,_| m }
                match("\"", :char ,"\"") {|_,m,_| Node_datatype.new("'"+m+"'", "char")}
                match("\'", :char ,"\'") {|_,m,_| Node_datatype.new("'"+m+"'", "char")}
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
                match(:variable, "[", :int ,"]")
                match(:variable) {|m| Node_variable.new(m)}
            end

            rule :variable do
                match(:variable, :digit){|m,n| m  + n  }
                match(:char, :variable){|m,n| m + n }
                match(:char) {|m| m }
            end

            rule :array do
                match(:type, "[", "]")
            end

            rule :type do
                match(:int_token)
                match(:float_token)
                match(:bool_token)
                match(:char_token)
                match(:auto_token)
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
                match(:true) {|m| m}
                match(:false) {|m| m}
            end

            rule :digit do
                match(/(?<![\w-])\d(?![\w-])/) {|m| m}
            end

            rule :char do
                match(/(?<![\w-])[a-zA-Z_](?![\w-])/) {|m| m}
            end
        end
    end
end

# l = LanguageParser.new()
# l.read_file("test2.gph")
# l.roll()

