# Språkspecifikation V2 - denab905 henha806
- Liknande Python i syntax, men med tillägg av explicita blockmarkörer ({}) och slut på statements (;).
- Strikt typat med typhärledning.
- Alla variabler är konstanter om inte flaggan `mod` används innan variabelnamn, ex `int mod a = 10`.

## Syntax och semantik
Grundläggande Syntax
- Variabeldeklaration: int age = 30;
- Funktioner: def void sayHello() { print("Hello, World!"); }
- Kontrollstrukturer: if (condition) { kod } i mån av tid ska även else & elseif implementeras.

Semantik för Operationer
- Prioritetsordningen följer vanliga matematiska konventioner: parenteser -> (exponenter) -> multiplikation/division -> addition/subtraktion.
- Logiska operationer: && eller "and", || eller "or", ! eller "not".

## Datatyper och Variabler
- Grundläggande Datatyper: int, float, bool, array, char. String ska implementeras i mån av tid.
- Arrayer ska vara dynamiska, d.v.s. kräver ingen bestämd längd.
- Typhärledning: Använd auto för att automatiskt härleda typen baserat på tilldelat värde. Exempel: `auto name = "namn";`.

## Funktioner och Procedurer
Funktioner definieras med returtyp, namn och parameterlista. Parametrar kan överföras antingen genom värde eller referens. I mån av tid ska man inte behöva ange returtyp i funktionsdefinitionen. <!-- Ska vara språkbestämt -->
Exempel:

``` python
def int factorial(int n) {
    if (n <= 1) { return 1; }
    else { return n * factorial(n - 1); }
}
```

## Kontrollstrukturer
- if-satser för villkorligt utförande.
- While-loop för iteration.

Exempel på Loop:

``` python
int i = 0
while(i < 10) {
    print(i);
    i = i+1
}
```

## Rekursion
Språket ska stödja rekursion, vilket möjliggör kompakta lösningar på komplexa problem.
Exempel på Rekursion:

``` python
def int fibonacci(int n) {
    if (n <= 1) { return n; }
    else { return fibonacci(n - 1) + fibonacci(n - 2); }
}
```

## Sammansatta Datastrukturer
Språket använder arrayer som den grundläggande sammansatta datatypen. Det ska finnas tillhörande funktioner för att manipulera dessa arrayer.
Exempel på användning av Arrayer:

``` python
int[] numbers = {1, 2, 3, 4, 5};
```

## Avancerade Funktioner
Språket ska kunna typhärleda variabler m.h.a. `auto`. Det ska även finnas parameteröverföringsmetoder.
Exempel på parameteröverföringsmetoder:
``` python
int a = 10;
float b = a.to_f();
```
Funktionen `to_f` ska inte ändra a i exemplet ovanför, utan kopierar värdet, och gör om det till en float.

Exempel på typhärledning:
``` python
int a = 10; 
auto b = 15; # Även denna kommer att bli en int.
```

## Scope-hantering
Vi kommer att ha ett globalt scope, och ett scope som begränsas av klammer-paranteser. Alla begränsade scope har tillgång till data i scope ovanför och om dem har flaggan `mod` kan även datan manipuleras. Detta är inte sant när man går åt andra hållet.
Exempel på scope:
``` python
int mod a = 20; # Globalt scope.

{
    int b = 30; # Lokalt scope.
    {
        int c = 40; # Lokalt scope i ett lokalt scope.
        a = 10; # Värdet på a uppdateras till 10.
    }
}
```

## Generellt exempel
``` python
include(filnamn)

def int fun_a(){
	print("Hello");

	int a = 10;
	
	return a;
}
```
