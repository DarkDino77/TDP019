<program> ::= <statement-list>

<statement-list> ::= <statement> <statement-list> | <statement>

<statement> ::= <return-statement> ;
               | <array-function> ;
               | <assignment> ;
               | <re-assignment> ;
               | <control>
               | <function-call> ;
               | <function-def>
               | <logical-expression> ;
               | <variable-call> ;

<return-statement> ::= return <logical-expression>

<array-function> ::= <variable> . add ( <variable-list> )
                   | <variable> . remove ( <expression> )
                   | <variable> . remove ( )

<assignment> ::= mod <assignment>
               | auto <variable> = <logical-expression>
               | <array> <variable> = <array-list>
               | <array> <variable>
               | <int-token> <variable> = <expression>
               | <int-token> <variable>
               | <float-token> <variable> = <expression>
               | <float-token> <variable>
               | <bool-token> <variable> = <logical-expression>
               | <bool-token> <variable>
               | <char-token> <variable> = <atom>
               | <char-token> <variable>

<re-assignment> ::= <variable> = <logical-expression>

<control> ::= <if-expression> | <while-expression>

<if-expression> ::= if ( <logical-expression> ) { <statement-list> }

<while-expression> ::= while ( <logical-expression> ) { <statement-list> }

<array-list> ::= [ <variable-list> ] | [ ]

<function-call> ::= <variable> ( <variable-list> ) | <variable> ( )

<variable-list> ::= <logical-expression> , <variable-list> | <logical-expression>

<function-def> ::= def <type> <variable> ( ) { <statement-list> }
                 | def <type> <variable> ( <assignment-list> ) { <statement-list> }

<assignment-list> ::= <assignment> , <assignment-list> | <assignment>

<logical-expression> ::= <logical-term> <or-operators> <logical-expression> 
                       | <logical-term>

<or-operators> ::= || | or

<logical-term> ::= <logical-factor> <and-operators> <logical-term> 
                 | <logical-factor>

<and-operators> ::= && | and

<logical-factor> ::= <not-operators> <logical-factor> 
                   | <comparison-expression>

<not-operators> ::= ! | not

<comparison-expression> ::= <expression> <comparison-operator> <expression>
                          | <expression>

<comparison-operator> ::= < | > | <= | >= | != | ==

<expression> ::= <term> + <expression>
               | <expression> - <term>
               | <term>

<term> ::= <factor> * <term>
         | <factor> / <term>
         | <factor>

<factor> ::= <atom> ** <factor>
           | <atom> % <factor>
           | <atom>

<atom> ::= ( <expression> )
         | - ( <expression> )
         | <function-call>
         | <variable-call>
         | <array-list>
         | " <char> "
         | ' <char> '
         | <bool>
         | <unary>

<unary> ::= - <float>
          | <float>
          | - <int>
          | <int>

<variable-call> ::= <variable> [ <expression> ]
                   | <variable>

<variable> ::= <char> <variable>
             | <variable> <digit>
             | <char>

<array> ::= <type> []

<type> ::= int-token | float-token | bool-token | char-token | auto-token

<float> ::= <int> . <int>
          | . <int>

<int> ::= <digit> <int>
         | <digit>

<bool> ::= true | false

<digit> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

<char> ::= a ... z | A ... Z | _
