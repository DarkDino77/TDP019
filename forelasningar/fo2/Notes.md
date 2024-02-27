- Terminal: En symbol som representerar ett konstant värde, kan inte ersättas med något annat.

- Icke-temrinal: De symboler som kan ersättas med andra symboler med hjälp av så kallad transformationsregler.

- Produktionsregel: En specifikation av hur en symbol kan ersättas med en annan.
    head -> body

`
Expr -> Nr
Expr -> Expr OP Expr
op -> +
Nr -> 0|1|2|3|4|5|6|7|8|9
`

Detta matchar 5+5
`
Backus-Naur form
<expr>::=<nr>
<expr>::=<expr><op><expr>
<op>::="+"
<nr>::="0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
`