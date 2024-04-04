require 'test/unit'
require './graphite.rb'

class LanguageTest < Test::Unit::TestCase
	# def test_arithmetic
	# 	assert_equal(3, execute("1+2;"))
	# 	# assert_equal("a b", execute("'a'+'b';")) Hitta en lösning på denna
	# 	assert_equal(9, execute("5+4;"))
	# 	assert_equal(4, execute("7-3;"))
	# 	assert_equal(12, execute("3*4;"))
	# 	assert_equal(4, execute("8/2;"))
	# 	assert_equal(1, execute("10%3;"))
	# 	assert_equal(14, execute("2*(2+5);"))
	# 	assert_equal(-9, execute("1-(2*5);"))
	# 	assert_equal(3, execute("1+4/2;"))
	# 	assert_equal(12, execute("9+3;"))
	# 	assert_equal(5, execute("12-7;"))
	# 	assert_equal(12, execute("2*6;"))
	# 	assert_equal(6, execute("18/3;"))
	# 	assert_equal(1, execute("17%4;"))
	# 	assert_equal(16, execute("2**4;"))
	# 	assert_equal(21, execute("(1+2)*(3+4);"))
	# 	assert_equal(6.5, execute("1+(4*2)-(5/2.0);"))
	# 	assert_equal(7.0, execute("1+(4*2.0)-(5/2);"))
	# 	assert_equal(7.0, execute("1.0+(4*2)-(5/2);"))
	# 	assert_equal(4.0, execute("1.5+2.5;"))
	# 	assert_equal(2.0, execute("3.0-1.0;"))
	# 	assert_equal(9.0, execute("4.5*2.0;"))
	# 	assert_equal(3.0, execute("9.0/3.0;"))
	# 	assert_equal(0.30000000000000004, execute("0.1+0.2;"))
	# 	assert_equal(0.19999999999999996, execute("1.0-0.8;"))
	# 	assert_equal(0, execute("2/4;"))
	# 	assert_equal(-4, execute("-1-3;"))
	# 	assert_equal(2, execute("-1--3;"))
	# 	assert_equal(4, execute("1--3;"))
	# 	assert_equal(-1, execute("-1--1-1;"))
	# 	assert_equal(2, execute("-1--(4-1);"))
	# 	assert_equal(-5, execute("-5;"))
	# 	assert_equal(5, execute("5;"))
	# end

	# def test_comparisons
	# 	assert_equal(false, execute("true==false;"))
	# 	assert_equal(true, execute("true && true;"))
	# 	assert_equal(false, execute("true && false;"))
	# 	assert_equal(false, execute("false && true;"))
	# 	assert_equal(false, execute("false && false;"))
	# 	assert_equal(true, execute("true and true;"))
	# 	assert_equal(false, execute("true and false;"))
	# 	assert_equal(false, execute("false and true;"))
	# 	assert_equal(false, execute("false and false;"))
	# 	assert_equal(true, execute("true || false;"))
	# 	assert_equal(true, execute("false || true;"))
	# 	assert_equal(true, execute("true || true;"))
	# 	assert_equal(false, execute("false || false;"))
	# 	assert_equal(true, execute("true or false;"))
	# 	assert_equal(true, execute("false or true;"))
	# 	assert_equal(true, execute("true or true;"))
	# 	assert_equal(false, execute("false or false;"))
	# 	assert_equal(true, execute("5>3;"))
	# 	assert_equal(true, execute("2<4;"))
	# 	assert_equal(true, execute("5>=5;"))
	# 	assert_equal(true, execute("4<=6;"))
	# 	assert_equal(true, execute("5!=3;"))
	# 	assert_equal(false, execute("5!=5;"))
	# 	assert_equal(true, execute("7==7;"))
	# 	assert_equal(true, execute("10!=5;"))
	# 	assert_equal(true, execute("3>2;"))
	# 	assert_equal(true, execute("4<5;"))
	# 	assert_equal(true, execute("6>=6;"))
	# 	assert_equal(true, execute("7<=8;"))
	# 	assert_equal(true, execute("7<=8;"))
	# end
	
	# def test_variable_assignment
	# 	assert_equal(5, execute("int x = 5;"))	
	# 	assert_equal(50, execute("mod int y = 50;"))
	# 	assert_equal(55, execute("mod int y = 50; mod int x = y+5; y = 10; x;"))
	# 	assert_equal(10, execute("mod int y = 50;y = 10;"))
	# 	assert_equal(25, execute("mod int y = 20;10+23;y;y+5;"))
	# end

	# def test_float_assignment
	# 	assert_equal(5.0, execute("float x = 5.0;"))
	# 	assert_equal(5.5, execute("float x = 2.0 + 3.5;"))
	# 	assert_equal(0.0, execute("float x;"))
	# 	assert_raise(TypeError) { execute("float x = 5;") }
	# end

	# def test_integer_assignment
	# 	assert_equal(5, execute("int x = 5;"))
	# 	assert_equal(0, execute("int x;"))
	# 	assert_equal(10, execute("int x = 7 + 3;"))
	# 	assert_raise(TypeError) { execute("int x = 5.0;") }
	# end

	# def test_boolean_assignment
	# 	assert_equal(true, execute("bool x = true;"))
	# 	assert_equal(false, execute("bool x = false;"))
	# 	assert_equal(true, execute("bool x;"))
	# 	assert_raise(TypeError) { execute("bool x = 1;") }
	# end

	# def test_char_assignment
	# 	assert_equal('a', execute("char x = 'a';"))
	# 	assert_equal('a', execute("char x;"))
	# 	assert_raise(Parser::ParseError) { execute("char x = 'ab';") }
	# 	assert_raise(TypeError) { execute("char x = 97;") }
	# end

	# def test_not_operator
	# 	assert_equal(false, execute("!true;"))
	# 	assert_equal(true, execute("!false;"))
	# 	assert_equal(true, execute("!(false);"))
	# 	assert_equal(false, execute("!0;"))
	# end

	# def test_control_structure
	# 	assert_equal(5, execute("if(true){1+3;1+4;}"))
	# 	assert_equal(5, execute("int y = 5; if(y <= 3 + 3){1+4;}"))
	# 	assert_equal(3, execute("mod int counter = 0; while(counter < 3){counter = counter + 1;} counter;"))
	# end

	# def test_functions
	# 	assert_equal(nil, execute("def fun_a(mod int a, mod int y, mod int x){a+3;}"))
	# 	assert_equal(nil, execute("def fun_a(mod int a){a+3;} fun_a(2);"))
	# 	assert_equal(2, execute("mod int x = 10; def mod_x(mod int a){x=a;} mod_x(2); x;"))
	# 	assert_equal(2, execute("def fun_a(mod int a){ return a;} fun_a(2);"))
	# 	assert_equal(10, execute("int d=10; def fun_a(mod int a, int b, mod int c){a*b-c; a = 20;} fun_a(3,4,8); d;"))
	# 	assert_equal(5, execute("def fun_a(mod int a){mod int b = a+3; return b; b = 10;} fun_a(2);"))
	# 	assert_equal(nil, execute("def fun_a(mod int a){mod int b = a+3;} fun_a(2);"))
	# 	assert_equal(9, execute("def fun_a(mod int a, mod int b, int c){1+2; return(a+b+c);} fun_a(2,3,4);"))
	# 	assert_equal(9, execute("def fun_a(mod int a, mod int b, int c){return(a+b+c);1+a;} fun_a(2,3,4);"))
	# end

	# def test_complex_expressions
	# 	assert_equal(4, execute("def calculate(){ return 2*2; } calculate();"))
	# 	assert_equal(7, execute("int a = 3; int b = 4; def sum(){ return a+b; } sum();"))
	# end
	  
	# def test_function_within_function
	# 	assert_equal(11,execute("def add_5(int num){return num+5;} 1+add_5(5);"))
	# 	assert_equal(10, execute("
	# 		def inner(int a){ 
	# 			return a * 2; 
	# 		}
	# 	  	def outer(){
	# 			int output = inner(5);
	# 			return output;
	# 	  	}
	# 		outer();
	# 	"))

	# 	assert_equal(10, execute("
	# 		def inner(int a){ 
	# 			return a * 2; 
	# 		}
	# 		int output = inner(5); 
	# 		inner(5);
	# 	"))
			
	# 	assert_equal(15, execute("
	# 		def outer(){
	# 			int base = 5;
	# 			def inner(int a){ return a + base; }
	# 			return inner(10);
	# 		}
	# 		outer();
	# 	"))
	# end

	def test_recursion
		# assert_equal(5, execute("
		# mod int counter = 1;
		# def count_up(){
		# 	if(counter < 5){
		# 		counter = counter + 1;
		# 		count_up();
		# 	}
		# 	return counter;
		# }
		# count_up();
		# "))

		# assert_equal(120, execute("
		#   def int factorial(mod int n){
		# 	if(n <= 1){ return 1; }
		# 	return n * factorial(n-1); 
		#   }
		#   factorial(5);
		# "))

		assert_equal(8, execute("
			def int add_5(mod int n){
				print(n);
				if(n >= 20){ return n; }
				return n + add_5(n + 5); 
			}
			add_5(0);
		"))

		# assert_equal(nil, execute("
		# mod int a = 20;
		# if(a >= 20){a;}
		# "))
	end
	  
	# def test_loop_with_function
	# 	assert_equal(true, execute("
	# 		mod int i = 0;
	# 		def check_limit(mod int a){ if(a < 5){ 1+2; return true; 3+4;} if(a >= 5){ 1+2; return false; 3+4; }}
	# 		check_limit(2);
	# 	"))
	# 	assert_equal(true, execute("
	# 		mod int i = 0;
	# 		def check_limit(mod int a){ if(a >= 5){ 1+2; return false; 3+4; } if(a < 5){ 1+2; return true; 3+4;}}
	# 		check_limit(2);
	#   	"))

	# 	assert_equal(true, execute("
	# 		mod int i = 0;
	# 		def check_limit(mod int a){if(a < 5){return true;}}
	# 		check_limit(2);
	# 	"))

	# 	assert_equal(5, execute("
	# 		mod int i = 0;
	# 		def checkLimit(int a){ if(a < 5) { return true; }  if(a >= 5){ return false; } }
	# 		while(checkLimit(i)){ i = i + 1; }
	# 		if(i == 5) { i; } 
	# 	"))
	# end
end
