# Språkspecifikation V1 #
- Liknande Python i syntax, men med tillägg av explicita blockmarkörer ({}) och slut på statements (;).
- Strikt typat med typhärledning.

## Syntax och semantik
Grundläggande Syntax
- Variabeldeklaration: int age = 30;
- Funktioner: def void sayHello() { print("Hello, World!"); }
- Kontrollstrukturer: if (condition) { /* kod */ } else { /* kod */ }

Semantik för Operationer
- Prioritetsordningen följer vanliga matematiska konventioner: parenteser -> (exponenter) -> multiplikation/division -> addition/subtraktion. <!-- Kolla om exponenter behövs-->
- Logiska operationer: && eller "and", || eller "or", ! eller "not".

## Datatyper och Variabler
- Grundläggande Datatyper: int, float, bool, array, char, string.
- Typhärledning: Använd auto för att automatiskt härleda typen baserat på tilldelat värde. Exempel: `auto name = "namn";`.

## Funktioner och Procedurer

Funktioner definieras utan returtyp men med namn och parameterlista. Parametrar kan överföras antingen genom värde eller referens. <!-- Ska vara språkbestämt -->
Exempel:

``` python
def factorial(int n) {
    if (n <= 1) { return 1; }
    else { return n * factorial(n - 1); }
}
```

## Kontrollstrukturer
- if-satser för villkorligt utförande.
- Loopar som for för iteration.

Exempel på Loop:

``` python
for (int i = 0; i < 10; i++) {
    print(i);
}
```

## Rekursion
Språket ska stödja rekursion, vilket möjliggör kompakta lösningar på komplexa problem.
Exempel på Rekursion:

``` python
def fibonacci(int n) {
    if (n <= 1) { return n; }
    else { return fibonacci(n - 1) + fibonacci(n - 2); }
}
```

## Sammansatta Datastrukturer
Språket använder arrayer som den grundläggande sammansatta datatypen. Det ska finnas tillhörande funktioner för att manipulera dessa arrayer.
Exempel på användning av Arrayer:

``` python
auto[] numbers = {1, 2, "Äpple", 4, 5};
```

## Avancerade Funktioner
Språket ska kunna typhärleda variabler m.h.a. `auto`. Det ska även finnas parameteröverföringsmetoder.
Exempel på parameteröverföringsmetoder:
``` python
int a = 10;
string b = a.to_s();
```
Funktionen `to_s` ska inte ändra a i exemplet ovanför.

Exempel på typhärledning:
``` python
int a = 10;
auto b = 15;
```

## Scope-hantering
Inte fastställt ännu.

## Generellt exempel
``` python
include(filnamn)

def fun_a(){
	print("Hello");

	int a = 10;
	
	return a;
}
```


