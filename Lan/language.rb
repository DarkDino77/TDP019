#!/usr/bin/env ruby
require './rdparse.rb'
require './node.rb'
require './scope.rb'
$counter = 0
class LanguageParser  
    attr_accessor :language_parser
    def initialize
        @@scope_stack = [Scope.new()] # INTE PÅ DETTA VIS?
        @@current_scope = @@scope_stack[0]

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
            token(/\d/) {|m| m } #behövs?
            token(/[a-zA-Z]/) {|m| m } #behövs?
            token(/\A(==|<=|>=|!=|\*\*)/) {|m|  m}
            token(/\A!/) {:not}

            token(/./) {|m| m}

            start :program do
                match(:scope) do |m|        
                    @@current_scope = @@scope_stack[-1]             
                    @@scope_stack[0]
                end
            end

            rule :scope do 
                match("{", :scope, "}") { 
                    @@scope_stack << Scope.new(@@current_scope)
                    @@current_scope = @@scope_stack[-1]
                }
                match(:operation, :scope){|m, _| @@current_scope.statement_stack << m}
                match(:operation) {|m| @@current_scope.statement_stack << m}
            end

            rule :operation do 
                match(:assignment, ";")
                match(:control)
                match(:function_call, ";")
                match(:function_def)
                match(:logical_expression, ";")
                match(:variable_call, ";")
            end
            
            rule :assignment do 
                match(:mod, :assignment){|_, name|
                    @@current_scope.variable[name]["const"] = false

                }
                match(:int_token, :variable, "=", :expression) {|_, name,_,value|
                    @@current_scope.assign_var(name, value.evaluate(@@current_scope), "int")
                    value
                }
                match(:int_token, :variable){|_, name,_,value|
                    @@current_scope.assign_var(name, 0, "int")
                    value
                }
            end

            rule :re_assignment do
                match(:variable, "=", :logical_expression) { |name,_,value|
                    if @@current_scope.variables.has_key?(name)
                        if # Kolla att de är samma datatyp! och att inte är const!
                    else
                        raise "Ret"
                    end
                }

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
                match(:char) {|m| 
                pp m
                m}
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
        (parsed.evaluate()).reverse_each do |a| 
            if a != nil
                output += eval(a.evaluate(parsed)).to_s
                #pp eval(a.evaluate(parsed))
            end
        end

        output
    end

    
    def execute(data)
        #print "[lang] "
        if done(data)
            #puts "Bye."
            pass
        else

            output=parse_code(data)

            @@scope_stack = [Scope.new()]
            @@current_scope = @@scope_stack[0]
            
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

