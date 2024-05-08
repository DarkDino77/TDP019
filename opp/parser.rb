require_relative './rdparse.rb'
require_relative './nodes/variable_nodes.rb'
require_relative './nodes/nodes.rb'
require_relative './nodes/operator_nodes.rb'
require_relative './nodes/selector_nodes.rb'
require_relative './runtime.rb'

class BaljanLang
    attr_accessor :print_tree
    def initialize
        @print_tree = false
        @parser = Parser.new("BaljanLang") do

            token(/\s/)
            token(/\/\*.*\*\//)
            token(/int\b/) {|m| :INTEGER}
            token(/float\b/)  {|m| :FLOAT}
            token(/bool\b/) {|m| :BOOL}
            token(/list\b/) {|m| :LIST}
            
            token(/==/) {|m|m}
            token(/!=/) {|m|m}
            token(/<=/) {|m|m}
            token(/>=/) {|m|m}
            token(/&&/) {|m|m}
            token(/\|\|/) {|m|m}

            token(/\d+\.\d+/){|m|m}
            token(/\d+/){|m|m}
            
            token(/[a-zA-Z]\w*/) {|m|m}

            token(/./){|m|m}
        
            start :program do
                match(:def_list){|list|
                    funcs = []
                    vars = []
                    list.each do |element|
                        if(element.is_a?(BLFunc))
                            funcs.append(element)
                        else
                            vars.append(element)
                        end
                    end
                    BLProgram.new(funcs, vars)
                }
            end
        
            rule :def_list do
                match(:def, :def_list) {|a, b|  a + b}
                match(:def) {|a| a}
            end

            rule :def do
                match(:func_def) {|a| [a]}
                match(:variable_init, :end_line) {|a, _| [a] }
               
            end

            rule :func_def do
                match(:data_type, :name, '(', :func_param_list, ')', :begin, :stmt_list, :end) {|type, name, _, params, _, _, body, _| 
                    BLFunc.new(BLFuncSignature.new(name, type, params), body)
                }
                match(:data_type, :name, '(', ')', :begin, :stmt_list, :end) {|type, name, _, _, _, body, _| 
                    BLFunc.new(BLFuncSignature.new(name, type, []), body)
                }
                match(:data_type, :name, :begin, :stmt_list, :end) {|type, name, _, body, _| 
                    BLFunc.new(BLFuncSignature.new(name, type, []), body)
                }
            end
            
            rule :variable_init do
                match(:data_type, '<', :data_type, '>', :name) {|type, _, extra, _, name|
                    BLVarInit.new(type, name, extra)
                }
                match(:data_type, :name) {|type, name|
                    BLVarInit.new(type, name)
                }
            end   
        
            rule :stmt_list do
                match(:stmt, :stmt_list) {|a, b| a + b}
                match(:stmt){|a| a}
            end

            rule :stmt do
                match(:if_stmt) {|a| [a]}
                match(:while_stmt) {|a|[a]}
                match(:for_stmt) {|a|[a]}
                match(:break, :end_line) {|a, _|[a]}
                match(:continue, :end_line) {|a, _|[a]}
                match(:return, :end_line) {|a, _|[a]}
                match(:print, :end_line) {|a, _|[a]}
                match(:expression, :end_line) {|a, _|[a]}
            end

            rule :break do
                match('break') {|_|BLBreak.new()}
            end

            rule :continue do
                match('continue') {|_|  BLContinue.new()}
                match('next') {|_|  BLContinue.new()}
            end

            rule :return do
                match('return', :expression)  {|_, value|  BLReturn.new(value)}
            end

            rule :print do
                match('print', :expression) {|_, value|  BLPrint.new(value)}
                match('print') {|_|  BLPrint.new()}
            end

            rule :for_stmt do
                match('for', '(', :expression, :end_line, :expression, :end_line, :expression, ')', :begin, :stmt_list, :end){ |_, _, var, _, selector, _, increment, _, _, body, _|
                     BLFor.new(var, selector, increment, body)
                }
            end

            rule :while_stmt do 
                match('while', '(', :expression, ')', :begin, :stmt_list, :end) { |_, _, selector, _, _, body, _| 
                     BLWhile.new(selector, body)
                }
                    
            end

            rule :if_stmt do
                match('if', '(', :expression, ')', :begin, :stmt_list, :end, :else_if_stmt){|_, _, selector, _, _, body, _, next_stmt|
                    if_stmt = BLIf.new(selector, body)
                    if_stmt.set_next_selector_node(next_stmt)
                     if_stmt
                }
                match('if', '(', :expression, ')', :begin, :stmt_list, :end, :else_stmt){|_, _, selector, _, _, body, _, next_stmt|
                    if_stmt = BLIf.new(selector, body)
                    if_stmt.set_next_selector_node(next_stmt)
                     if_stmt
                }
                match('if', '(', :expression, ')', :begin, :stmt_list, :end){|_, _, selector, _, _, body, _|
                     BLIf.new(selector, body)
                }
            end

            rule :else_if_stmt do
                match('else', 'if', '(', :expression, ')', :begin, :stmt_list, :end, :else_if_stmt){|_, _, _, selector, _, _, body, _, next_stmt|
                    if_stmt = BLIf.new(selector, body)
                    if_stmt.set_next_selector_node(next_stmt)
                     if_stmt
                }
                match('else', 'if', '(', :expression, ')', :begin, :stmt_list, :end, :else_stmt) {|_, _, _, selector, _, _, body, _, next_stmt|
                    if_stmt = BLIf.new(selector, body)
                    if_stmt.set_next_selector_node(next_stmt)
                     if_stmt
                }
                match('else', 'if', '(', :expression, ')', :begin, :stmt_list, :end) {|_, _, _, selector, _, _, body, _|
                     BLIf.new(selector, body)
                }
            end

            rule :else_stmt do
                match('else', :begin, :stmt_list, :end) {|_, _, body, _|
                     BLElse.new(body)
                }
            end

            rule :expression do
                match( :logic_expression, '=', :expression) do |exp1, _, exp2|
                    BLAssignment.new(exp1, exp2)
                end
                match(:logic_expression) {|a|a}
            end
            
            rule :logic_expression do
                match(:logic_expression, :bool_logic_operator, :bool_expression) {|rh, node, lh|  node.new(rh, lh)}
                match('!', :logic_expression) {|_, value|  BLLogicNot.new(value)}
                match(:bool_expression) {|a|  a}
            end

            rule :bool_logic_operator do
                match('||'){|_| BLLogicOr}
                match('&&'){|_| BLLogicAnd}
            end

            rule :bool_expression do
                match(:arithmetic_expression, :comparison_operator, :arithmetic_expression) {|rh, node, lh|  node.new(rh, lh)}
                match(:arithmetic_expression) {|a| a}
            end

            rule :comparison_operator do
                match('=='){|_| BLEqual}
                match('!='){|_| BLNotEqual}
                match('<'){|_| BLLessThan}
                match('<='){|_| BLLessThanOrEqual}
                match('>'){|_| BLGreaterThan}
                match('>='){|_| BLGreaterThanOrEqual}
            end

            rule :arithmetic_expression do
                match(:arithmetic_expression, :arithmatic_operator_A, :term) do |lh, operator, rh| 
                     BLBinaryMethod.new(lh, rh, operator)
                end
                match(:term) {|a|  a}
            end

            rule :arithmatic_operator_A do
                match('+') {|_|  'addition'}
                match('-') {|_|  'subtraction'}
            end

            rule :term do
        
                match(:term, :arithmetic_operator_B, :mod_expression) do |lh, operator, rh| 
                    BLBinaryMethod.new(lh, rh, operator)
                end
                match(:mod_expression) {|a|  a}
            end

            rule :arithmetic_operator_B do
                match('*') {|_| 'multiplication'}
                match('/') {|_| 'divition'}
            end

            rule :mod_expression do
                match(:mod_expression, :arithmetic_operator_C, :member_call) do |lh, operator, rh| 
                    BLBinaryMethod.new(lh, rh, operator)
                end
                match(:member_call) {|a|  a}
            end

            
            rule :arithmetic_operator_C do
                match('%') {|_|  'modulo'}
            end

            rule :member_call do
                match(:member_call, '.', :name, '(', :expression_list, ')') {|value, _, func, _, args, _|
                    BLMemberCall.new(value, func, args)
                }
                match(:member_call, '[', :expression, ']') {|var, _, index, _|
                    BLMemberCall.new(var, 'index', [index])
                }
                match(:data) {|a|a}
            end

            rule :data do
                match('(', :expression, ')') {|_, value, _|  value}
                match(:other_value) {|a|  a}
                match(:func_call) {|a|  a}
                match(:variable_init){|a|a}
                match(:variable) {|a|  a}
                match(:number_value){|a|a}
            end

            rule :extra_arg_list do
                match(:extra_arg_list, :data_type) {|a, b| a + [b]}
                match(:data_type){|a|[a]}
            end
            

            rule :data_type do
                match(:INTEGER) {|_| BLInteger}
                match(:FLOAT) {|_|  BLFloat}
                match(:BOOL) {|_|  BLBool}
                match(:LIST) {|_| BLList}
            end

            rule :value do
                match(:number_value){|a|a}
                match(:other_value){|a|a}
            end

            rule :number_value do
                match(:float_value) {|a|  a}
                match(:int_value) {|a|  a}
            end

            rule :other_value do
                match(:bool_value) {|a|  a}
                #match(:array_value) {|a|a}
            end

            rule :int_value do
                match(/\d+/) {|a|  BLConstValue.new(a.to_i, BLInteger)}
                match('-', /\d+/) {|_,a|  BLConstValue.new(-a.to_i, BLInteger)}
            end

            rule :float_value do
                match(/\d+\.\d+/) {|a|  BLConstValue.new(a.to_f, BLFloat)}
                match('-', /\d+\.\d+/) {|a|  BLConstValue.new(-a.to_f, BLFloat)}
            end

            rule :bool_value do
                match('true') {|a|  BLConstValue.new(true, BLBool)}
                match('false') {|a|  BLConstValue.new(false, BLBool)}
            end

            #rule :array_value do
            #    match('[', :expression_list, ']') {|_, data, _| data}
            #    
            #end

            rule :variable do
                match(:name) {|name|  BLVarNode.new(name)}
            end

            rule :func_call do 
                match(:name, '(', :expression_list, ')') {|name, _, args, _|  BLFuncCall.new(name, args)}
                match(:name, '(', ')') {|name, _, _|  BLFuncCall.new(name, []) }
            end 

            rule :func_param_list do
                match(:func_param, ',', :func_param_list) {|a, _, b|  a + b}
                match(:func_param) {|a|  a}
            end

            rule :func_param do
                match(:data_type, :name) {|type, name| [BLFuncParam.new(name, type)]}
            end

            rule :expression_list do
                match(:expression_list_segment, ',', :expression_list) {|a, _, b| a + b}
                match(:expression_list_segment) {|a| a}
            end

            rule :expression_list_segment do
                match(:expression) {|a| [a]}
            end
            rule :name do
                match(/[a-zA-Z]\w*/){|a| a}
            end

            rule :begin do
                match('begin')
                match('do')
                match('{')
            end

            rule :end do 
                match('end')
                match('}')
            end

            rule :end_line do
                match(';')
            end
        end
    end

    # For parsing a simple string
    def parse_string(string)
        if(@parser.logger.level == Logger::DEBUG)
            puts "=============== Beginning parsing of string ==============="
        end
        @program = @parser.parse(string)
        if(@parser.logger.level == Logger::DEBUG)
            puts "=============== Parsing of string done ==============="
        end
        if(@print_tree)
            @program.print_tree
        end
    end

    # For parsing a file
    def parse_file(filename)
        if(!filename.end_with?(".bl"))
            raise "File does not have the correct file-ending"
        elsif(!File.exists?(filename))
            raise "Could not find the given file"
        end

        if(@parser.logger.level == Logger::DEBUG)
            puts "=============== Beginning parsing of file ==============="
        end
        file = File.read(filename)
        @program = @parser.parse(file)
        if(@parser.logger.level == Logger::DEBUG)
            puts "=============== Parsing of file done ==============="
        end
        if(@print_tree)
            @program.print_tree
        end
    end

    # Runs the program
    def run()
        puts "====================================  Running program  ======================================="
        thing = BLRuntime.new(@program)
        thing.run()
    end

    def log(state = true)
        if state
          @parser.logger.level = Logger::DEBUG
        else
          @parser.logger.level = Logger::WARN
        end
    end
end

