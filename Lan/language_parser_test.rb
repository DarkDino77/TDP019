require 'test/unit'
require './language.rb'

class LanguageTest < Test::Unit::TestCase
	@@l = LanguageParser.new()

	def test_arithmetic
	  assert_equal("3", @@l.execute("1+2;"))
	  assert_equal("9", @@l.execute("5+4;"))
	#   assert_equal("4", @@l.execute("7-3;"))
	#   assert_equal("12", @@l.execute("3*4;"))
	#   assert_equal("4", @@l.execute("8/2;"))
	#   assert_equal("1", @@l.execute("10%3;"))
	#   assert_equal("14", @@l.execute("2*(2+5);"))
	# #   assert_equal("-9", @@l.execute("1-(2*5);"))
	#   assert_equal("3", @@l.execute("1+4/2;"))
	#   assert_equal("12", @@l.execute("9+3;"))
	#   assert_equal("5", @@l.execute("12-7;"))
	#   assert_equal("12", @@l.execute("2*6;"))
	#   assert_equal("6", @@l.execute("18/3;"))
	#   assert_equal("1", @@l.execute("17%4;"))
	#   assert_equal("16", @@l.execute("2**4;"))
	#   assert_equal("21", @@l.execute("(1+2)*(3+4);"))
	#   # assert_equal("2", @@l.execute("1+(4*2)-(5/2);"))
	#   assert_equal("4.0", @@l.execute("1.5+2.5;"))
	#   assert_equal("2.0", @@l.execute("3.0-1.0;"))
	#   assert_equal("9.0", @@l.execute("4.5*2.0;"))
	#   assert_equal("3.0", @@l.execute("9.0/3.0;"))
	#   assert_equal("0.30000000000000004", @@l.execute("0.1+0.2;"))
	#   assert_equal("0.19999999999999996", @@l.execute("1.0-0.8;"))
	#   # assert_equal("0.5", @@l.execute("2/4;"))
	#   assert_equal("-4", @@l.execute("-1-3;"))
	#   assert_equal("2", @@l.execute("-1--3;"))
	#   assert_equal("4", @@l.execute("1--3;"))
	#   assert_equal("-1", @@l.execute("-1--1-1;"))
	#   assert_equal("2", @@l.execute("-1--(4-1);"))
	#   assert_equal("-5", @@l.execute("-5;"))
	#   assert_equal("5", @@l.execute("5;"))
	end

	def test_comparisons
	  assert_equal("false", @@l.execute("true==false;"))
	  assert_equal("false", @@l.execute("true && false;"))
	  assert_equal("false", @@l.execute("true and false;"))
	  assert_equal("true", @@l.execute("true || false;"))
	  assert_equal("true", @@l.execute("true or false;"))


	#   assert_equal("true", @@l.execute("5>3;"))
	#   assert_equal("true", @@l.execute("2<4;"))
	#   assert_equal("true", @@l.execute("5>=5;"))
	#   assert_equal("true", @@l.execute("4<=6;"))
	#   assert_equal("true", @@l.execute("5!=3;"))
	#   assert_equal("false", @@l.execute("5!=5;"))
	#   assert_equal("true", @@l.execute("7==7;"))
	#   assert_equal("true", @@l.execute("10!=5;"))
	#   assert_equal("true", @@l.execute("3>2;"))
	#   assert_equal("true", @@l.execute("4<5;"))
	#   assert_equal("true", @@l.execute("6>=6;"))
	#   assert_equal("true", @@l.execute("7<=8;"))
	end

	# def test_var
	# 	assert_equal("5", @@l.execute("int x = 5;"))	
	# 	assert_equal("50", @@l.execute("mod int y = 50;"))
	# 	assert_equal("10", @@l.execute("mod int y = 50;y = 10;"))
	# 	assert_equal("25", @@l.execute("mod int y = 20;10+23;y;y+5;"))
	# end

	# def test_not_operator
	# 	assert_equal("false", @@l.execute("!true;"))
	# 	assert_equal("true", @@l.execute("!false;"))
	# 	assert_equal("true", @@l.execute("!(false);"))
	# 	assert_equal("false", @@l.execute("!0;"))
	# end

	# def test_control_structure
	# 	assert_equal("5", @@l.execute("if(true){1+3;1+4;}"))
	# 	assert_equal("5", @@l.execute("int y = 5; if(y <= 3 + 3){1+4;}"))
	# 	assert_equal("3", @@l.execute("mod int counter = 0; while(counter < 3){counter = counter + 1;} counter;"))
	# end

	# def test_functions
	# 	assert_equal("5", @@l.execute("def fun_a(mod int a, mod int y, mod int x){a+3;}"))
	# end
end
