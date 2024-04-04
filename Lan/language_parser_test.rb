require 'test/unit'
require './language.rb'

class LanguageTest < Test::Unit::TestCase
	@@l = LanguageParser.new()

	def test_arithmetic
		assert_equal("3", @@l.execute("1+2;"))
		# assert_equal("a b", @@l.execute("'a'+'b';")) Hitta en lösning på denna
		assert_equal("9", @@l.execute("5+4;"))
		assert_equal("4", @@l.execute("7-3;"))
		assert_equal("12", @@l.execute("3*4;"))
		assert_equal("4", @@l.execute("8/2;"))
		assert_equal("1", @@l.execute("10%3;"))
		assert_equal("14", @@l.execute("2*(2+5);"))
		assert_equal("-9", @@l.execute("1-(2*5);"))
		assert_equal("3", @@l.execute("1+4/2;"))
		assert_equal("12", @@l.execute("9+3;"))
		assert_equal("5", @@l.execute("12-7;"))
		assert_equal("12", @@l.execute("2*6;"))
		assert_equal("6", @@l.execute("18/3;"))
		assert_equal("1", @@l.execute("17%4;"))
		assert_equal("16", @@l.execute("2**4;"))
		assert_equal("21", @@l.execute("(1+2)*(3+4);"))
		assert_equal("6.5", @@l.execute("1+(4*2)-(5/2.0);"))
		assert_equal("7.0", @@l.execute("1+(4*2.0)-(5/2);"))
		assert_equal("7.0", @@l.execute("1.0+(4*2)-(5/2);"))
		assert_equal("4.0", @@l.execute("1.5+2.5;"))
		assert_equal("2.0", @@l.execute("3.0-1.0;"))
		assert_equal("9.0", @@l.execute("4.5*2.0;"))
		assert_equal("3.0", @@l.execute("9.0/3.0;"))
		assert_equal("0.30000000000000004", @@l.execute("0.1+0.2;"))
		assert_equal("0.19999999999999996", @@l.execute("1.0-0.8;"))
		assert_equal("0", @@l.execute("2/4;"))
		assert_equal("-4", @@l.execute("-1-3;"))
		assert_equal("2", @@l.execute("-1--3;"))
		assert_equal("4", @@l.execute("1--3;"))
		assert_equal("-1", @@l.execute("-1--1-1;"))
		assert_equal("2", @@l.execute("-1--(4-1);"))
		assert_equal("-5", @@l.execute("-5;"))
		assert_equal("5", @@l.execute("5;"))
	end

	def test_comparisons
		assert_equal("false", @@l.execute("true==false;"))
		assert_equal("false", @@l.execute("true && false;"))
		assert_equal("false", @@l.execute("true and false;"))
		assert_equal("true", @@l.execute("true || false;"))
		assert_equal("true", @@l.execute("true or false;"))
		assert_equal("true", @@l.execute("5>3;"))
		assert_equal("true", @@l.execute("2<4;"))
		assert_equal("true", @@l.execute("5>=5;"))
		assert_equal("true", @@l.execute("4<=6;"))
		assert_equal("true", @@l.execute("5!=3;"))
		assert_equal("false", @@l.execute("5!=5;"))
		assert_equal("true", @@l.execute("7==7;"))
		assert_equal("true", @@l.execute("10!=5;"))
		assert_equal("true", @@l.execute("3>2;"))
		assert_equal("true", @@l.execute("4<5;"))
		assert_equal("true", @@l.execute("6>=6;"))
		assert_equal("true", @@l.execute("7<=8;"))
		assert_equal("true", @@l.execute("7<=8;"))
	end
	
	def test_variable_assignment
		assert_equal("5", @@l.execute("int x = 5;"))	
		assert_equal("50", @@l.execute("mod int y = 50;"))
		assert_equal("55", @@l.execute("mod int y = 50; mod int x = y+5; y = 10; x;"))
		assert_equal("10", @@l.execute("mod int y = 50;y = 10;"))
		assert_equal("25", @@l.execute("mod int y = 20;10+23;y;y+5;"))
	end

	def test_float_assignment
		assert_equal("5.0", @@l.execute("float x = 5.0;"))
		assert_equal("5.5", @@l.execute("float x = 2.0 + 3.5;"))
		assert_equal("0.0", @@l.execute("float x;"))
		assert_raise(TypeError) { @@l.execute("float x = 5;") } # Assuming integers cannot be implicitly cast to floats
	end

	def test_integer_assignment
		assert_equal("5", @@l.execute("int x = 5;"))
		assert_equal("0", @@l.execute("int x;"))
		assert_equal("10", @@l.execute("int x = 7 + 3;"))
		assert_raise(TypeError) { @@l.execute("int x = 5.0;") } # Assuming floats cannot be implicitly cast to ints
	end

	def test_boolean_assignment
		assert_equal("true", @@l.execute("bool x = true;"))
		assert_equal("false", @@l.execute("bool x = false;"))
		assert_equal("true", @@l.execute("bool x;"))
		assert_raise(TypeError) { @@l.execute("bool x = 1;") } # Assuming integers cannot be implicitly cast to bools
		#assert_raise(TypeError) { @@l.execute("bool x = 'true';") } # Assuming strings cannot be implicitly cast to bools
	end

	def test_char_assignment
		assert_equal("a", @@l.execute("char x = 'a';"))
		assert_equal("a", @@l.execute("char x;"))
		assert_raise(Parser::ParseError) { @@l.execute("char x = 'ab';") } # Assuming only single characters are allowed for char type
		assert_raise(TypeError) { @@l.execute("char x = 97;") } # Assuming integers cannot be implicitly cast to chars, even if they represent ASCII values
	end

	def test_not_operator
		assert_equal("false", @@l.execute("!true;"))
		assert_equal("true", @@l.execute("!false;"))
		assert_equal("true", @@l.execute("!(false);"))
		assert_equal("false", @@l.execute("!0;"))
	end

	def test_control_structure
		assert_equal("5", @@l.execute("if(true){1+3;1+4;}"))
		assert_equal("5", @@l.execute("int y = 5; if(y <= 3 + 3){1+4;}"))
		assert_equal("3", @@l.execute("mod int counter = 0; while(counter < 3){counter = counter + 1;} counter;"))
	end

	def test_functions
		assert_equal(nil, @@l.execute("def fun_a(mod int a, mod int y, mod int x){a+3;}"))
		assert_equal(nil, @@l.execute("def fun_a(mod int a){a+3;} fun_a(2);"))
		assert_equal("2", @@l.execute("mod int x = 10; def mod_x(mod int a){x=a;} mod_x(2); x;"))
		assert_equal("2", @@l.execute("def fun_a(mod int a){ return a;} fun_a(2);"))
		assert_equal("10", @@l.execute("int d=10; def fun_a(mod int a, int b, mod int c){a*b-c; a = 20;} fun_a(3,4,8); d;"))
		assert_equal("5", @@l.execute("def fun_a(mod int a){mod int b = a+3; return b; b = 10;} fun_a(2);"))
		assert_equal(nil, @@l.execute("def fun_a(mod int a){mod int b = a+3;} fun_a(2);"))
		assert_equal("9", @@l.execute("def fun_a(mod int a, mod int b, int c){1+2; return(a+b+c);} fun_a(2,3,4);"))
		assert_equal("9", @@l.execute("def fun_a(mod int a, mod int b, int c){return(a+b+c);1+a;} fun_a(2,3,4);"))
	end

	def test_complex_expressions
		assert_equal("4", @@l.execute("def calculate(){ return 2*2; } calculate();"))
		assert_equal("7", @@l.execute("int a = 3; int b = 4; def sum(){ return a+b; } sum();"))
	  
	end
	  
	def test_function_within_function
		assert_equal("11",@@l.execute("def add_5(int num){return num+5;} 1+add_5(5);"))
		assert_equal("10", @@l.execute("
			def inner(int a){ 
				return a * 2; 
			}
		  	def outer(){
				int output = inner(5);
				return output;
		  	}
			outer();
		"))

		assert_equal("10", @@l.execute("
			def inner(int a){ 
				return a * 2; 
			}
			int output = inner(5); 
			inner(5);
		"))
			
		#	Test variable scope - variable defined in outer function accessible in inner function
		assert_equal("15", @@l.execute("
			def outer(){
				int base = 5;
				def inner(int a){ return a + base; }
				return inner(10);
			}
			outer();
		"))
		
		# Test recursion
		# assert_equal("120", @@l.execute("
		#   def factorial(mod int n){
		# 	if(n <= 1){ return 1; }
		# 	return n * factorial(n-1); 
		#   }
		#   factorial(5);
		# "))
	end
	  
	def test_loop_with_function
		# Test using a function within a loop
		assert_equal("true", @@l.execute("
			mod int i = 0;
			def check_limit(mod int a){ if(a < 5){ 1+2; return true; 3+4;} if(a >= 5){ 1+2; return false; 3+4; }}
			check_limit(2);
		"))
		assert_equal("true", @@l.execute("
			mod int i = 0;
			def check_limit(mod int a){ if(a >= 5){ 1+2; return false; 3+4; } if(a < 5){ 1+2; return true; 3+4;}}
			check_limit(2);
	  	"))

		assert_equal("true", @@l.execute("
			mod int i = 0;
			def check_limit(mod int a){if(a < 5){return true;}}
			check_limit(2);
		"))

		assert_equal("5", @@l.execute("
			mod int i = 0;
			def checkLimit(int a){ if(a < 5) { return true; }  if(a >= 5){ return false; } }
			while(checkLimit(i)){ i = i + 1; }
			if(i == 5) { i; } 
		"))
	end
end
