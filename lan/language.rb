#!/usr/bin/env ruby
require './rdparse.rb'
require './node.rb'

$debug = false
class LanguageParser  

    attr_accessor :language_parser
    attr_accessor :debug
    def initialize
        @language_parser = Parser.new("language parser") do
            token(/\s+/)
            token(/\[/) {:bracket_open}
            token(/\]/) {:bracket_close}
            token(/\badd\b/) {:add}
            token(/\bremove\b/) {:remove}
            token(/\bprint\b/) {:print}
            token(/\btrue\b/) {:true}
            token(/\bfalse\b/) {:false}
            token(/(\band\b|&&)/) {:and}
            token(/(\bor\b|\|\|)/) {:or}
            token(/\bnot\b/) {:not}
            token(/\bmod\b/) {:mod}
            token(/\bint\b/) {:int_token}
            token(/\bfloat\b/) {:float_token}
            token(/\bchar\b/) {:char_token}
            token(/\bbool\b/) {:bool_token}
            token(/\bauto\b/) {:auto_token}
            token(/\bvoid\b/) {:void_token}
            token(/\bto_c\b/) {:to_char}
            token(/\bto_i\b/) {:to_int}
            token(/\bto_f\b/) {:to_float}
            token(/\bto_b\b/) {:to_bool}
            token(/\bto_a\b/) {:to_array}
            token(/\breturn\b/) {:return}
            token(/\bif\b/) {:if}
            token(/\bwhile\b/) {:while}
            token(/\bdef\b/) {:def}
            
            token(/(?<![\w-])\d(?![\w-])/) {|m| m } 
            
            token(/(?<![\w-])[a-zA-Z_](?![\w-])/) {|m| m }
            token(/\A(==|<=|>=|!=|\*\*|=|\+|\-|%)/) {|m|  m}

            token(/\A!/) {:not}

            token(/./) {|m| m}

            start :program do
                match(:statement_list) do |m|        
                    if $debug 
                        puts "================================[NODE TREE]================================"
                        pp m 
                        puts "\n"
                        time1 = Time.now
                    end

                    return_value = m.evaluate

                    if $debug 
                        time2 = Time.now
                        elapsed_time = time2 - time1
                        puts "Evaluation time: \e[01m#{elapsed_time}\e[00m seconds"
                    end
                    return_value
                end
            end

            rule :statement_list do 
                match(:statement, :statement_list){|stm, stm_l| Node_statement_list.new(stm, stm_l)}
                match(:statement) {|stm| Node_statement_list.new(stm)}
            end

            rule :statement do 
                match(:return_statement, ";")
                match(:print, "(", :variable_list, ")", ";") {|_,_,exp,_,_| Node_print.new(exp.flatten)}
                match(:conversion, ";")
                match(:array_function, ";")
                match(:assignment, ";")
                match(:re_assignment, ";")
                match(:control)
                match(:function_call, ";")
                match(:function_def)
                match(:logical_expression, ";")
                match(:variable_call, ";")
                match(:standalone_scope)
            end

            rule :return_statement do
                match(:return, :logical_expression) {|_, expr| Node_return.new(expr)}
            end

            rule :conversion do
                match(:to_char, "(", :logical_expression, ")") {|_,_,value,_| Node_to_char.new(value)}
                match(:to_int, "(", :logical_expression, ")") {|_,_,value,_| Node_to_int.new(value)}
                match(:to_float, "(", :logical_expression, ")") {|_,_,value,_| Node_to_float.new(value)}
                match(:to_bool, "(", :logical_expression, ")") {|_,_,value,_| Node_to_bool.new(value)}
                match(:to_array, "(", :logical_expression, ")") {|_,_,value,_| Node_to_array.new(value)}
            end

            rule :array_function do
                match(:variable_call,"." ,:add,"(",:variable_list,")"){|name,_,_,_,var,_|
                    Node_array_add.new(name,var.flatten)}    
                match(:variable_call,"." ,:remove,"(",:expression,")"){|name,_,_,_,index,_|
                    Node_array_remove.new(name, index)}
                match(:variable_call,"." ,:remove,"(",")"){|name,_,_,_,_|
                    Node_array_remove.new(name)}
            end

            rule :assignment do
                match(:mod, :assignment){|_, node|
                    node.remove_const()
                    node
                }

                match(:auto_token, :variable, "=", :logical_expression){|_,name,_,value|
                    Node_auto_assignment.new(name, value)
                }

                match(:array, :variable, "=",:array_list){|type, name, _, arr_list|
                    arr_list.update_type(type)
                    Node_assignment.new(type, name, arr_list)
                }

                match(:array, :variable) {|type, name|
                    Node_assignment.new(type, name, Node_array.new(type, []))
                }

                match(:type, :variable, "=", :logical_expression) {|type, name,_,value|
                    Node_assignment.new(type, name, value)
                }

                match(:int_token, :variable){|_,name|
                    value = Node_int.new("0")
                    Node_assignment.new("int", name, value)
                }

                match(:float_token, :variable){|_,name|
                    value = Node_float.new("0.0")
                    Node_assignment.new("float" , name, value)
                }

                match(:bool_token, :variable){|_,name|
                    value = Node_bool.new("true")
                    Node_assignment.new("bool", name, value)
                }

                match(:char_token, :variable){|_,name|
                    value = Node_char.new("a")
                    Node_assignment.new("char", name, value)
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

            rule :array_list do
                match(:bracket_open, :variable_list, :bracket_close) {|_,m,_| Node_array.new("nil", m.flatten)}
                match(:bracket_open, :bracket_close) {|_,_| Node_array.new("nil", [])}
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
                match(:def,  :function_def_type, :variable, "(", ")", "{",:statement_list, "}") {|_, type, name, _, _, _, stmt_list, _|
                    Node_function.new(name, [], stmt_list, type)}
                match(:def, :function_def_type, :variable, "(", :assignment_list, ")", "{",:statement_list, "}") {|_, type, name, _, ass_list, _, _, stmt_list, _|
                    Node_function.new(name, ass_list.flatten, stmt_list, type)} 
                match(:def, :variable, "(", ")", "{",:statement_list, "}") {|_, name, _, _, _, stmt_list, _|
                    Node_function.new(name, [], stmt_list)}
                match(:def, :variable, "(", :assignment_list, ")", "{",:statement_list, "}") {|_, name, _, ass_list, _, _, stmt_list, _|
                    Node_function.new(name, ass_list.flatten, stmt_list)}
            end

            rule :function_def_type do 
                match(:void_token){|m| m.name.split('_')[0] }
                match(:array)
                match(:type)
            end

            rule :assignment_list do
                match(:assignment, ",", :assignment_list) {|m, _, n| [m] << [n] }
                match(:assignment) {|m| [m] }
            end

            rule :logical_expression do 
                match(:logical_term, :or, :logical_expression)  {|a,b,c| Node_logical_expression.new(a,"|",c)}
                match(:logical_term)
            end
            
            rule :logical_term do 
                match(:logical_factor, :and, :logical_term)  {|a,b,c| Node_logical_expression.new(a,"&",c)}
                match(:logical_factor)
            end

            rule :logical_factor do
                match(:not, :logical_factor) {|_,m| Node_not.new(m)} 
                match(:comparison_expression)
            end

            rule :comparison_expression do
                match(:expression, :comparison_operator, :expression)  {|a,b,c| Node_comparison_expression.new(a,b,c)}
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
                match(:expression, "+", :term) {|a, op, b| Node_expression.new(a, op, b) }
                match(:expression, "-", :term) {|a, op, b| Node_expression.new(a, op, b) }
                match(:term)
            end
            
            rule :term do
                match(:term, "*", :factor) {|a, op, b| Node_expression.new(a, op, b) }
                match(:term, "/", :factor) {|a, op, b| Node_expression.new(a, op, b) }
                match(:factor)
            end
            
            rule :factor do
                match(:factor, "**", :unary) {|a, op, b| Node_expression.new(a, op, b) }
                match(:unary, "%", :factor) {|a, op, b| Node_expression.new(a, op, b) }
                match(:unary)
            end
            
            rule :unary do
                match("-", :unary) {|op, a| Node_negative.new(a) }
                match(:atom)
            end
            
            rule :atom do
                match(:array_list)
                match(:conversion)
                match(:function_call)
                match("(", :expression, ")") {|_,m,_| m }
                match(:bool) {|m| Node_bool.new(m.name)}
                match(:variable_call)
                match(:float){|m| Node_float.new(m)}
                match(:int){|m| Node_int.new(m)}
                match(:text) {|m| Node_char.new( m)}
            end
            
            rule :text do 
                match("\"", :char,"\"") {|_,m,_|  m }
                match("\'", :char ,"\'") {|_,m,_|  m }
                match("\"","\"") {|_,_| ""}
                match("\'","\'") {|_,_| ""}
            end 

            rule :variable_call do
                match(:variable,:array_accessor){|name,index|
                    Node_array_accessor.new(name, index.flatten)}
                match(:variable) {|m| Node_variable.new(m)}
            end

            rule :array_accessor do 
                match(:bracket_open, :expression, :bracket_close, :array_accessor) {|_, m, _, n| [m] << [n]}
                match(:bracket_open, :expression, :bracket_close) {|_,m,_| [m]}
            end

            rule :standalone_scope do
                match("{",:statement_list,"}"){|_,stmt,_|
                    Node_standalone_scope.new(stmt)
                }    
            end

            rule :variable do
                match(:variable, :digit){|m,n| m  + n  }
                match(:letter, :variable){|m,n| m + n }
                match(:letter) {|m| m }
            end

            rule :array do
                match(:type, :bracket_open, :bracket_close){|type| "array_"+type}
            end

            rule :type do
                match(:int_token){|m| m.name.split('_')[0]}
                match(:float_token){|m| m.name.split('_')[0]}
                match(:bool_token){|m| m.name.split('_')[0]}
                match(:char_token){|m| m.name.split('_')[0]}
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

            rule :letter do
                match(/(?<![\w-])[a-zA-Z_](?![\w-])/) {|m| m}
            end

            rule :char do
                match(/(?<![\w-]).(?![\w-])/) {|m| m}
            end
        end
    end
end