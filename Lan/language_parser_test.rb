require 'test/unit'
require './graphite.rb'

class LanguageTest < Test::Unit::TestCase
	def test_arithmetic
		assert_equal(3, execute("1+2;"))
		assert_equal(9, execute("5+4;"))
		assert_equal(4, execute("7-3;"))
		assert_equal(12, execute("3*4;"))
		assert_equal(4, execute("8/2;"))
		assert_equal(1, execute("10%3;"))
		assert_equal(14, execute("2*(2+5);"))
		assert_equal(-9, execute("1-(2*5);"))
		assert_equal(3, execute("1+4/2;"))
		assert_equal(12, execute("9+3;"))
		assert_equal(5, execute("12-7;"))
		assert_equal(12, execute("2*6;"))
		assert_equal(6, execute("18/3;"))
		assert_equal(1, execute("17%4;"))
		assert_equal(16, execute("2**4;"))
		assert_equal(21, execute("(1+2)*(3+4);"))
		assert_equal(6.5, execute("1+(4*2)-(5/2.0);"))
		assert_equal(7.0, execute("1+(4*2.0)-(5/2);"))
		assert_equal(7.0, execute("1.0+(4*2)-(5/2);"))
		assert_equal(4.0, execute("1.5+2.5;"))
		assert_equal(2.0, execute("3.0-1.0;"))
		assert_equal(9.0, execute("4.5*2.0;"))
		assert_equal(3.0, execute("9.0/3.0;"))
		assert_equal(0.30000000000000004, execute("0.1+0.2;"))
		assert_equal(0.19999999999999996, execute("1.0-0.8;"))
		assert_equal(0, execute("2/4;"))
		assert_equal(-4, execute("-1-3;"))
		assert_equal(2, execute("-1--3;"))
		assert_equal(4, execute("1--3;"))
		assert_equal(-1, execute("-1--1-1;"))
		assert_equal(2, execute("-1--(4-1);"))
		assert_equal(-5, execute("-5;"))
		assert_equal(5, execute("5;"))
		assert_equal(27, execute("3**3;"))
		assert_equal(-8, execute("-2**3;")) 
		assert_equal(4, execute("(2**3)/2;")) 
		assert_equal(9, execute("2+(3*2)+1;"))
		assert_equal(0, execute("2-2;"))
		assert_equal(-2, execute("2*(-1);")) 
		assert_equal(4.5, execute("9/2.0;")) 
		assert_equal(-4, execute("(-7)/2;")) 
		assert_equal(-3.5, execute("(-7.0)/2;")) 
		assert_equal(49, execute("7**2;")) 
		assert_equal(-49, execute("-(7**2);"))
		assert_equal(5, execute("15%10;")) 
		assert_equal(8, execute("2**3;")) 
		assert_equal(-27, execute("-3**3;")) 
		assert_equal(2.25, execute("4.5/2;")) 
		assert_equal(77, execute("2+(3*(2+3)**2);"))
		assert_equal(0.5, execute("(1+1)/(2*2.0);"))
		assert_equal(-6, execute("-3+(2-5);"))
		assert_equal(25, execute("(5)**2;"))
		assert_equal(125, execute("5**3;"))
		assert_equal(-125, execute("-5**3;"))
		assert_equal(5, execute("10/2;"))
		assert_equal(-5, execute("-10/2;")) 
		assert_equal(-5, execute("10/-2;")) 
		assert_equal(5, execute("-10/-2;")) 
		assert_equal(2.5, execute("5/2.0;")) 
		assert_equal(13, execute("2+3*3+2;")) 
		assert_equal(25, execute("(2+3)*(3+2);")) 
		assert_equal(-2, execute("2*(-1)+0;"))
		assert_equal(8, execute("9-4/2*3+5;")) 
		assert_equal(3, execute("1*3+0;"))
		assert_equal(1, execute("0**0;"))
		assert_equal(1, execute("2**0;"))
		assert_equal(8, execute("2**(1+2);")) 
		assert_equal(-8, execute("-(2**(1+2));")) 
		assert_equal(4, execute("16**(0.5);")) 
		assert_equal(3, execute("27**(1/3.0);")) 
		assert_equal(5, execute("2*3+4/2-3;")) 
	end

	def test_standalone_scope
		assert_equal(20, execute("int a = 20; {int a = 10;} a;"))
		assert_equal(10, execute("mod int a = 20; {a = 10;} a;"))
	end

	def test_auto_variables
		assert_equal(10, execute("auto a = 10; a;"))
		assert_equal([1,2,3], execute("auto a = [1,2,3]; a;"))
		assert_equal(0, execute("auto a = 1/2; a;"))
		assert_equal(false, execute("auto a = not true; a;"))
		assert_equal(1.5, execute("auto a = 3/2.0; a;"))
		assert_equal([1,2], execute("mod auto a = [1,2,3]; a.remove(2); a;"))
		assert_equal([1,2,307], execute("mod auto a = [1,2]; a.add(307); a;"))
		assert_equal(2, execute("mod auto a = [1,2]; a[1];"))
	end
	
	def test_data_types_and_auto_keyword
		# Testing char
		assert_equal('A', execute("auto a = 'A'; a;"))
		assert_equal(['X', 'Y', 'Z'], execute("auto a = ['X', 'Y', 'Z']; a;"))
	
		# Testing float
		assert_equal(3.14, execute("auto a = 3.14; a;"))
		assert_equal([1.1, 2.2, 3.3], execute("auto a = [1.1, 2.2, 3.3]; a;"))
	
		# Testing bool
		assert_equal(true, execute("auto a = true; a;"))
		assert_equal([false, true, false], execute("auto a = [false, true, false]; a;"))

		# Float arithmetic operation
		assert_equal(6.28, execute("auto a = 3.14; auto b = a * 2; b;"))
	
		# Logical operation with bool
		assert_equal(false, execute("auto a = true; auto b = !a; b;"))
	
		# Array operations
		# Adding elements to char array
		assert_equal(['A', 'B', 'C', 'D'], execute("mod auto a = ['A', 'B', 'C']; a.add('D'); a;"))
	
		# Adding elements to float array
		assert_equal([1.1, 2.2, 3.3, 4.4], execute("mod auto a = [1.1, 2.2, 3.3]; a.add(4.4); a;"))
	
		# Adding elements to bool array
		assert_equal([true, false, true, true], execute("mod auto a = [true, false, true]; a.add(true); a;"))
	  end

	def test_comparisons
		assert_equal(false, execute("true==false;"))
		assert_equal(true, execute("true && true;"))
		assert_equal(false, execute("true && false;"))
		assert_equal(false, execute("false && true;"))
		assert_equal(false, execute("false && false;"))
		assert_equal(true, execute("true and true;"))
		assert_equal(false, execute("true and false;"))
		assert_equal(false, execute("false and true;"))
		assert_equal(false, execute("false and false;"))
		assert_equal(true, execute("true || false;"))
		assert_equal(true, execute("false || true;"))
		assert_equal(true, execute("true || true;"))
		assert_equal(false, execute("false || false;"))
		assert_equal(true, execute("true or false;"))
		assert_equal(true, execute("false or true;"))
		assert_equal(true, execute("true or true;"))
		assert_equal(false, execute("false or false;"))
		assert_equal(true, execute("5>3;"))
		assert_equal(true, execute("2<4;"))
		assert_equal(true, execute("5>=5;"))
		assert_equal(true, execute("4<=6;"))
		assert_equal(true, execute("5!=3;"))
		assert_equal(false, execute("5!=5;"))
		assert_equal(true, execute("7==7;"))
		assert_equal(true, execute("10!=5;"))
		assert_equal(true, execute("3>2;"))
		assert_equal(true, execute("4<5;"))
		assert_equal(true, execute("6>=6;"))
		assert_equal(true, execute("7<=8;"))
		assert_equal(true, execute("7<=8;"))
	end
	
	def test_variable_assignment
		assert_equal(5, execute("int x = 5;"))	
		assert_equal(50, execute("mod int y = 50;"))
		assert_equal(55, execute("mod int y = 50; mod int x = y+5; y = 10; x;"))
		assert_equal(10, execute("mod int y = 50;y = 10;"))
		assert_equal(25, execute("mod int y = 20;10+23;y;y+5;"))
	end

	def test_float_assignment
		assert_equal(5.0, execute("float x = 5.0;"))
		assert_equal(5.5, execute("float x = 2.0 + 3.5;"))
		assert_equal(0.0, execute("float x;"))
		assert_raise(TypeError) { execute("float x = 5;") }
	end

	def test_integer_assignment
		assert_equal(5, execute("int x = 5; x;"))
		assert_equal(0, execute("int x;"))
		assert_equal(10, execute("int x = 7 + 3;"))
		assert_raise(TypeError) { execute("int x = 5.0;") }
	end

	def test_boolean_assignment
		assert_equal(true, execute("bool x = true;"))
		assert_equal(true, execute("bool x = true && true;"))
		assert_equal(true, execute("bool x = true and true;"))
		assert_equal(true, execute("bool x = true or true;"))
		assert_equal(true, execute("bool x = true || true;"))
		assert_equal(false, execute("bool x = false;"))
		assert_equal(true, execute("bool x;"))
		assert_raise(TypeError) { execute("bool x = 1;") }
	end

	def test_char_assignment
		assert_equal('a', execute("char x = 'a'; x;"))
		assert_equal('a', execute("char x;"))
		assert_raise(Parser::ParseError) { execute("char x = 'ab';") }
		assert_raise(TypeError) { execute("char x = 97;") }
		assert_raise(TypeError) { execute("'a'+'b';")} # Hitta en lösning på denna
		assert_equal(true, execute("'a'<'b';"))

	end

	def test_not_operator
		assert_equal(false, execute("!true;"))
		assert_equal(true, execute("!false;"))
		assert_equal(true, execute("!(false);"))
		assert_equal(false, execute("!0;"))
	end

	def test_control_structure
		assert_equal(5, execute("if(true){1+3;1+4;}"))
		assert_equal(5, execute("int y = 5; if(y <= 3 + 3){1+4;}"))
		assert_equal(3, execute("mod int counter = 0; while(counter < 3){counter = counter + 1;} counter;"))
		assert_equal(3, execute("mod int counter = 0; while(counter < 3){counter = counter + 1;} counter;"))
	end

	def test_functions
		assert_equal(nil, execute("def int fun_a(mod int a, mod int y, mod int x){a+3;}"))
		assert_equal(nil, execute("def int fun_a(mod int a){a+3;} fun_a(2);"))
		assert_equal(2, execute("mod int x = 10; def int mod_x(mod int a){x=a;} mod_x(2); x;"))
		assert_equal(2, execute("def int fun_a(mod int a){ return a;} fun_a(2);"))
		assert_equal(10, execute("int d=10; def int fun_a(mod int a, int b, mod int c){a*b-c; a = 20;} fun_a(3,4,8); d;"))
		assert_equal(5, execute("def int fun_a(mod int a){mod int b = a+3; return b; b = 10;} fun_a(2);"))
		assert_equal(nil, execute("def int fun_a(mod int a){mod int b = a+3;} fun_a(2);"))
		assert_equal(9, execute("def int fun_a(mod int a, mod int b, int c){1+2; return(a+b+c);} fun_a(2,3,4);"))
		assert_equal(9, execute("def int fun_a(mod int a, mod int b, int c){return(a+b+c);1+a;} fun_a(2,3,4);"))
		assert_equal(nil, execute("def void fun_a(mod int a, mod int b, int c){1+a;} fun_a(2,3,4);"))
		assert_equal(20, execute("mod int a = 10; def void mod_a(){a = 20;} mod_a(); a;"))
	end

	def test_auto_return_functions
		assert_equal(6, execute("def fun_a(mod int a){return a+3;} fun_a(2); fun_a(2) + 1;"))
		assert_equal(2, execute("mod int x = 10; def mod_x(mod int a){x=a;} mod_x(2); x;"))
		assert_equal(2, execute("def  fun_a(mod int a){ return a;} fun_a(2);"))
		assert_equal(10, execute("int d=10; def  fun_a(mod int a, int b, mod int c){a*b-c; a = 20;} fun_a(3,4,8); d;"))
		assert_equal(5, execute("def fun_a(mod int a){mod int b = a+3; return b; b = 10;} fun_a(2);"))
		assert_equal(nil, execute("def fun_a(mod int a){mod int b = a+3;} fun_a(2);"))
		assert_equal(9, execute("def fun_a(mod int a, mod int b, int c){1+2; return(a+b+c);} fun_a(2,3,4);"))
		assert_equal(9, execute("def fun_a(mod int a, mod int b, int c){return(a+b+c);1+a;} fun_a(2,3,4);"))
	end
	def test_auto_complex_expressions
		assert_equal(4, execute("def calculate(){ return 2*2; } calculate();"))
		assert_equal(7, execute("int a = 3; int b = 4; def sum(){ return a+b; } sum();"))
	end
	  
	def test_auto_function_within_function
		assert_equal(11,execute("def  add_5(int num){return num+5;} 1+add_5(5);"))
		assert_equal(10, execute("
			def inner(int a){ 
				return a * 2; 
			}
		  	def outer(){
				int output = inner(5);
				return output;
		  	}
			outer();
		"))

		assert_equal(10, execute("
			def  inner(int a){ 
				return a * 2; 
			}
			int output = inner(5); 
			inner(5);
		"))
			
		assert_equal(15, execute("
			def outer(){
				int base = 5;
				def inner(int a){ return a + base; }
				return inner(10);
			}
			outer();
		"))
	end

	def test_auto_recursion
		assert_equal(5, execute("
		mod int counter = 1;
		def count_up(){
			if(counter < 5){
				counter = counter + 1;
				count_up();
			}
			return counter;
		}
		count_up();
		"))

		assert_equal(120, execute("
		  def factorial(mod int n){
			if(n <= 1){ return 1; }
			return n * factorial(n-1); 
		  }
		  factorial(5);
		"))

		assert_equal(20, execute("
			def add_5(mod int n){
				if(n >= 20){ return n; }
				return add_5(n + 5); 
			}
			add_5(0);
		"))

		assert_equal(22, execute("
		def add_5(mod int n){
			if(n >= 20){ return n; }
			return 5;
		}
		add_5(22);
		"))

		assert_equal(20, execute("
		mod int a = 20;
		if(a >= 20){a;}
		"))
	end
	  
	def test_auto_loop_with_function
		assert_equal(true, execute("
			mod int i = 0;
			def check_limit(mod int a){ if(a < 5){ 1+2; return true; 3+4;} if(a >= 5){ 1+2; return false; 3+4; }}
			check_limit(2);
		"))
		assert_equal(true, execute("
			mod int i = 0;
			def check_limit(mod int a){ if(a >= 5){ 1+2; return false; 3+4; } if(a < 5){ 1+2; return true; 3+4;}}
			check_limit(2);
	  	"))

		assert_equal(true, execute("
			mod int i = 0;
			def check_limit(mod int a){if(a < 5){return true;}}
			check_limit(2);
		"))

		assert_equal(5, execute("
			mod int i = 0;
			def checkLimit(int a){ if(a < 5) { return true; }  if(a >= 5){ return false; } }
			while(checkLimit(i)){ i = i + 1; }
			if(i == 5) { i; } 
		"))
	end

	def test_complex_expressions
		assert_equal(4, execute("def int calculate(){ return 2*2; } calculate();"))
		assert_equal(7, execute("int a = 3; int b = 4; def int sum(){ return a+b; } sum();"))
	end
	  
	def test_function_within_function
		assert_equal(11,execute("def int add_5(int num){return num+5;} 1+add_5(5);"))
		assert_equal(10, execute("
			def int inner(int a){ 
				return a * 2; 
			}
		  	def int outer(){
				int output = inner(5);
				return output;
		  	}
			outer();
		"))

		assert_equal(10, execute("
			def int inner(int a){ 
				return a * 2; 
			}
			int output = inner(5); 
			inner(5);
		"))
			
		assert_equal(15, execute("
			def int outer(){
				int base = 5;
				def int inner(int a){ return a + base; }
				return inner(10);
			}
			outer();
		"))
	end

	def test_recursion
		assert_equal(5, execute("
		mod int counter = 1;
		def int count_up(){
			if(counter < 5){
				counter = counter + 1;
				count_up();
			}
			return counter;
		}
		count_up();
		"))

		assert_equal(120, execute("
		  def int factorial(mod int n){
			if(n <= 1){ return 1; }
			return n * factorial(n-1); 
		  }
		  factorial(5);
		"))

		assert_equal(20, execute("
			def int add_5(mod int n){
				if(n >= 20){ 
					return n; 
				}
				return add_5(n + 5); 
			}
			add_5(0);
		"))

		assert_equal(22, execute("
		def int add_5(mod int n){
			if(n >= 20){ return n; }
			return 5;
		}
		add_5(22);
		"))

		assert_equal(20, execute("
		mod int a = 20;
		if(a >= 20){a;}
		"))
	end
	  
	def test_loop_with_function
		assert_equal(true, execute("
			mod int i = 0;
			def bool check_limit(mod int a){ if(a < 5){ 1+2; return true; 3+4;} if(a >= 5){ 1+2; return false; 3+4; }}
			check_limit(2);
		"))
		assert_equal(true, execute("
			mod int i = 0;
			def bool check_limit(mod int a){ if(a >= 5){return false;} if(a < 5){return true;}}
			check_limit(2);
	  	"))

		assert_equal(true, execute("
			mod int i = 0;
			def bool check_limit(mod int a){if(a < 5){return true;}}
			check_limit(2);
		"))

		assert_equal(5, execute("
			mod int i = 0;
			def bool checkLimit(int a){ if(a < 5) { return true; }  if(a >= 5){ return false; } }
			while(checkLimit(i)){ i = i + 1; }
			if(i == 5) { i; } 
		"))
	end

	def test_array
		assert_equal([], execute("int[] arr_a = [];"))
		assert_equal([], execute("int[] arr_a;"))
		assert_equal([1], execute("int[] arr_a = [1];"))
		assert_equal([1, 2], execute("int[] arr_a = [1,2];"))
		assert_equal([1, 2, 70], execute("int[] arr_a = [1,2, 70];"))
		assert_equal([true], execute("bool[] arr_a = [true];"))
		assert_equal([true, false], execute("bool[] arr_a = [true, false];"))
		assert_equal([true, false, true], execute("bool[] arr_a = [true, false, true];"))
		assert_equal([1.0], execute("float[] arr_a = [1.0];"))
		assert_equal([1.0, 2.3], execute("float[] arr_a = [1.0, 2.3];"))
		assert_equal([1.0, 2.3, 3.4], execute("float[] arr_a = [1.0, 2.3, 3.4];"))
		assert_equal(['a'], execute("char[] arr_a = ['a'];"))
		assert_equal(['a', 'b', 'c'], execute("char[] arr_a = ['a', 'b', 'c'];"))
		assert_equal([1, 5], execute("int[] arr_a = [1,2+3];"))

		
		assert_equal([1, 10], execute("mod int a = 10; int[] arr_a = [1,a];"))
		assert_equal([1, 5], execute("def int ret_5(){return 5;} int[] arr_a = [1,ret_5()];"))
		assert_equal([1, [5, 6]], execute("def int[] ret_5(){int[] arr_b = [5, 6]; return arr_b;} int[] arr_a = [1,ret_5()];"))
		assert_equal([1, [5, 6]], execute("int[] arr_a = [1,[5,6]];"))
		assert_raise(TypeError) { execute("int[] arr_a = [1,[5,true]];") }
		assert_raise(TypeError) { execute("int[] arr_a = [1,2, true];") }
		assert_raise(TypeError) { execute("bool[] arr_a = [true,false, 1+3];") }
		assert_raise(TypeError) { execute("float[] arr_a = [1.0,1, 2.3];") }
	end
	
	def test_array_arithmetics
		assert_equal([2,4,6], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a + arr_b;"))
		#assert_equal([2,4,6], execute("bool[] arr_a = [true,true,true]; bool[] arr_b = [true,true,true]; arr_a + arr_b;"))
		assert_equal([0,0,0], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a - arr_b;"))
		assert_equal([1,4,9], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a * arr_b;"))
		assert_equal([1,1,1], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a / arr_b;"))
		assert_equal([0,0,0], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a % arr_b;"))
		assert_equal([1,4,27], execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a ** arr_b;"))
		assert_equal(false, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a < arr_b;"))
		assert_equal(false, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a > arr_b;"))
		assert_equal(true, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a >= arr_b;"))
		assert_equal(true, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a <= arr_b;"))
		assert_equal(false, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a != arr_b;"))
		assert_equal(true, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a == arr_b;"))
		assert_equal(true, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,90]; arr_a && arr_b;"))
		assert_equal(true, execute("int[] arr_a = [1,2,3]; int[] arr_b = [1,2,3]; arr_a || arr_b;"))
		assert_equal(10, execute("mod int a = 10; if(0){a = 5;} a;"))
		#assert_equal([1,2,3,1,2,3], execute("int[] arr_a = [1,2,3]; !arr_a;"))
	end

	def test_array_functions
		assert_equal([5], execute("mod int[] a = []; a.add(5);"))
		assert_equal([5, 6], execute("mod int[] a = []; a.add(5, 6);"))
		assert_equal([[5, 6]], execute("mod int[] a = []; a.add([5, 6]);"))
		assert_equal([[1,2,3]], execute("mod int[] a = []; int[] b = [1,2,3]; a.add(b);"))
		assert_raise(TypeError) { execute("mod int[] a = []; bool[] b = [true, false]; a.add(b);")}
		assert_equal([17], execute("mod int[] a = []; a.add(5+12);"))
		assert_equal([2], execute("mod int[] a = []; a.add(5/2);"))
		assert_raise(TypeError) { execute("mod int[] a = []; a.add(5/2.0);")}
		assert_equal(5, execute("mod int[] a = [5,2]; a.remove(0);"))
		assert_equal([2,5], execute("mod int[] a = [5,[2,5]]; a.remove(1);"))
		assert_equal([2,5], execute("mod int[] a = [5,[2,5]]; a.remove();"))
		assert_equal([], execute("mod int[] a = [5]; a.remove(0); a;"))
		assert_equal(nil, execute("mod int[] a = []; a.remove();"))
		assert_equal([], execute("mod int[] a = []; a.remove(); a;"))
		assert_equal(2, execute("mod int[] a = [1,2,3]; a[1];"))
		assert_equal(1, execute("mod int[] a = [1,2,3]; a[0];"))
		assert_equal(3, execute("mod int[] a = [1,2,3]; a[1+1];"))
		assert_equal(2, execute("int index = 1; mod int[] a = [1,2,3]; a[index];"))
		assert_equal([1, 1, 1], execute("int index = 1; mod int[] a = [index,index,index]; a;"))
		assert_raise(IndexError) { execute("mod int[] a = [1,2,3]; a[3];")}
		assert_raise(Parser::ParseError) { execute("mod int[] a = [1,2,3]; a[];")}
	end

	def test_float_array_functions
		# Addition of floats
		assert_equal([5.5], execute("mod float[] a = []; a.add(5.5);"))
		assert_equal([5.5, 6.2], execute("mod float[] a = []; a.add(5.5, 6.2);"))
		assert_equal([11.7], execute("mod float[] a = []; a.add(5.5+6.2);"))
	  
		# Division results in float, testing type compatibility
		assert_equal([2.5], execute("mod float[] a = []; a.add(5/2.0);"))
		
		# Nested float arrays
		assert_equal([[5.5, 6.2]], execute("mod float[] a = []; a.add([5.5, 6.2]);"))
	  
		# Removal and access
		assert_equal(5.5, execute("mod float[] a = [5.5, 2.2]; a.remove(0);"))
		assert_equal([2.2], execute("mod float[] a = [5.5, 2.2]; a.remove(0); a;"))
		assert_equal(2.2, execute("mod float[] a = [1.1,2.2,3.3]; a[1];"))
	  
		# Error cases
		assert_raise(TypeError) { execute("mod float[] a = []; a.add('t');")}
		assert_raise(IndexError) { execute("mod float[] a = [1.1,2.2,3.3]; a[3];")}
	  end

	  def test_char_array_functions
		# Adding characters
		#assert_equal(['a'], execute("mod char[] a = []; a.add('a');"))
		assert_equal(['a', 'b'], execute("mod char[] a = []; a.add('a', 'b');"))
		
		# Nested char arrays
		assert_equal([['a', 'b']], execute("mod char[] a = []; a.add(['a', 'b']);"))
	  
		# Removal and access
		assert_equal('a', execute("mod char[] a = ['a', 'b']; a.remove(0);"))
		assert_equal(['b'], execute("mod char[] a = ['a', 'b']; a.remove(0); a;"))
		assert_equal('b', execute("mod char[] a = ['a','b','c']; a[1];"))
	  
		# Error cases
		assert_raise(TypeError) { execute("mod char[] a = []; a.add(1);")}
		assert_raise(IndexError) { execute("mod char[] a = ['a','b','c']; a[3];")}
	  end

	  def test_bool_array_functions
		# Adding booleans
		assert_equal([true], execute("mod bool[] a = []; a.add(true);"))
		assert_equal([true, false], execute("mod bool[] a = []; a.add(true, false);"))
		
		# Nested bool arrays
		assert_equal([[true, false]], execute("mod bool[] a = []; a.add([true, false]);"))
	  
		# Logical operations resulting in boolean addition
		assert_equal([false], execute("mod bool[] a = []; a.add(5 > 6);"))
	  
		# Removal and access
		assert_equal(true, execute("mod bool[] a = [true, false]; a.remove(0);"))
		assert_equal([false], execute("mod bool[] a = [true, false]; a.remove(0); a;"))
		assert_equal(false, execute("mod bool[] a = [true,false,true]; a[1];"))
	  
		# Error cases
		assert_raise(TypeError) { execute("mod bool[] a = []; a.add('t');")}
		assert_raise(IndexError) { execute("mod bool[] a = [true,false,true]; a[3];")}
	  end	  
end
