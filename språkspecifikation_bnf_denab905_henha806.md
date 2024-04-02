<program> ::= <scope> 

<scope> ::= <operation> | <operation> <scope> | { <scope> }

<operation> ::= <assignment> 
              | <control> 
              | <function-call> 
              | <function-def> 
              | return <logical-expression>;
              | <logical-expression>
              | <variable-call>  
              

<!------------Tilldelning------------>
<assignment> ::= mod <assignment>;
               | auto <variable> = <logical-expresion>;
               | <array> <variable> = [<variable-list>];
               | <array> <variable> = [];
               | <array> <variable>;
               | int <variable> = <expresion>; 
               | int <variable>;
               | float <variable> = <expresion>;
               | float <variable>;
               | char <variable> = <varible-call>; 
               | char <variable>;
               | bool <variable> = <logical-expresion>;
               | bool <variable>;
               

<!------------Kontrollstrukturer------------>
<control> ::= <if-expression> | <while-expression>
<if-expression> ::= if ( <logical-expression> ) { <scope> }
<while-expression> ::= while ( <logical-expression> ) { <scope> }

<!------------Funktioner------------>
<assignment-list> ::= <assignment> | <assignment> , <assignment-list>

<function-def> ::= def <function-call> { <scope> }

<function-call> ::= <variable> () | <variable> ( <variable-list>)


<!------------Logiska operationer------------>
<logical-expression> ::= <logical-term> || <logical-expression> 
                       | <logical-term> or <logical-expression> 
                       | <logical-term>

<logical-term> ::= <logical-factor> && <logical-term> 
                 | <logical-factor> and <logical-term> 
                 | <logical-factor>

<logical-factor> ::= ! <logical-factor> 
                   | not <logical-factor> 
                   | <comparison-expression> 

<comparison-expression> ::= <expression> <comparison-operator> <expression>
                          | <expression>
                
<comparison-operator> ::= < | > | <= | => | != | ==

<!------------Metematiska operationer------------>
<expression> ::= <term> + <expression>
               | <term> - <epxression>
               | <term>

<term> ::= <factor> * <term>
         | <factor> / <term>
         | <factor>

<factor> ::= <atom> ** <factor> 
           | <atom> % <factor>
           | <atom>

<atom> ::= ( <expression> )
         | <variable-call>
         | <float>
         | <int> 

<variable-call> ::= <variable> | <variable> [ <int> ]

<variable> ::= <char> | <char><variable> | <variable><digit>

<array> ::= <type>[]

<type> ::= int | float | bool | char | auto

<float> ::=  <int>.<int>
<int> ::= <digit> | <digit><int>
<bool> ::= true | false
<digit> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
<char> ::= 'a' ... 'z' | 'A' ... 'Z'

