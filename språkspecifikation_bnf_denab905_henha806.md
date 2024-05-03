<program> ::= <statement-list>

<statement-list> ::= <statement> <statement-list> | <statement>

<statement> ::= <return-statement> ;
               | <print-statement> ;
               | <conversion> ;
               | <array-function> ;
               | <assignment> ;
               | <re-assignment> ;
               | <control>
               | <function-call> ;
               | <function-def>
               | <logical-expression> ;
               | <variable-call> ;
               | <standalone-scope>

<return-statement> ::= return <logical-expression>

<print-statement> ::= print ( <variable-list> )

<conversion> ::= to_c ( <logical-expression> )
               | to_i ( <logical-expression> )
               | to_f ( <logical-expression> )
               | to_b ( <logical-expression> )
               | to_a ( <logical-expression> )

<array-function> ::= <variable-call> . add ( <variable-list> )
                   | <variable-call> . remove ( <expression> )
                   | <variable-call> . remove ( )

<assignment> ::= mod <assignment>
               | auto <variable> = <logical-expression>
               | <array> <variable> = <array-list>
               | <array> <variable>
               | <type> <variable> = <logical-expression>
               | <type> <variable>

<re-assignment> ::= <variable> = <logical-expression>

<control> ::= <if-expression> | <while-expression>

<if-expression> ::= if ( <logical-expression> ) { <statement-list> }

<while-expression> ::= while ( <logical-expression> ) { <statement-list> }

<array-list> ::= [ <variable-list> ] | [ ]

<function-call> ::= <variable> ( <variable-list> ) | <variable> ( )

<variable-list> ::= <logical-expression> , <variable-list> | <logical-expression>

<function-def> ::= def <function-def-type> <variable> ( ) { <statement-list> }
                 | def <function-def-type> <variable> ( <assignment-list> ) { <statement-list> }
                 | def <variable> ( ) { <statement-list> }
                 | def <variable> ( <assignment-list> ) { <statement-list> }

<function-def-type> ::= <type> [] | <type> | void

<assignment-list> ::= <assignment> , <assignment-list> | <assignment>

<logical-expression> ::= <logical-term> <or> <logical-expression> | <logical-term>

<or> ::= || | or

<logical-term> ::= <logical-factor> <and> <logical-term> | <logical-factor>

<and> ::= && | and

<logical-factor> ::= <not> <logical-factor> | <comparison-expression>

<not> ::= ! | not

<comparison-expression> ::= <expression> <comparison-operator> <expression> | <expression>

<comparison-operator> ::= < | > | <= | >= | != | ==

<expression> ::= <term> + <expression>
               | <expression> - <term>
               | <term>

<term> ::= <factor> * <term>
         | <factor> / <term>
         | <factor>

<factor> ::= <factor> ** <unary> 
           | <unary> % <factor>
           | <unary>

<unary> ::= - <unary> | <atom>

<atom> ::= ( <expression> )
         | <function-call>
         | <variable-call>
         | <array-list>
         | <conversion>
         | <bool>
         | <float>
         | <int>
         | <text>


<variable-call> ::= <variable> [ <expression> ]
                   | <variable>

<text> ::= " <char> " | ' <char> ' | "" | ''

<variable> ::= <variable> <digit> | <letter> <variable> | <letter>

<array> ::= <type> []

<type> ::= int | float | bool | char | auto | void

<float> ::= <int> . <int> | . <int>

<int> ::= <digit> <int> | <digit>

<bool> ::= true | false

<digit> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

<letter> ::= a ... z | A ... Z | _

<char> ::= any UTF-8 character

