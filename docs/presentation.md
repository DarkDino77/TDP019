## redogöra för ert språk, varför ni valt detta, vilken målgrupp, designöverväganden och några exempel.
- Blandning mellan C++ och python. C++: Strikt typat, svårt att bli fel. Python: Enkel syntax
- Lätt att se om betygskriterierna uppfylls. 
- Målgruppen är dem med liten tidigare erfarenhet av programmering.
- Designöverväganden inkluderar Syntaxen: exempel på funktionsdefinition(ej returtyp!)

## översiktligt förklara hur ni implementerat ert språk, vilka delar, val av objekt- och datastruktur, algoritmer, verktyg ni använt
- Ruby på samma sätt som diceroller. Klasser som representerar varje nod i AST (varje kosntruktion). Skapar instanser av dessa klasser när parsern fastställt typ.
- Började med fristående datatyper för att få aritmetiska uttryck `1+2` att fungera. Byggde på allt eftersom, och lade till enhetstester med unittest, gick tillbaka om något blev fel. Exempelvis "statementlist" (visa med exempel). Nämna memoization

## visa något kod-avsnitt
``` ruby
class Node_assignment < Node
    attr_accessor :value
    def initialize(type, name, value)
        @name = name
        @type = type
        @value = value
        @const = true
    end
    
    def get_type()
        return @type
    end

    def evaluate()
        if @@variable_stack.any? { |hash| hash.value?(@name) }
            raise "Variable with name #{@name} already exists"
        else
            if @value.get_type() != @type
                raise TypeError, "Variable assignment for '#{@name}' expected a #{@type} value, but got a #{@value.get_type} value."
            end
            @@variable_stack[@@current_scope][@name] = {"value" => @value.evaluate, "type" => @type, "const" => @const}
            return @value.evaluate
        end
    end
    
    def remove_const()
        @const = false
    end
end

class Node_auto_assignment < Node_assignment
    def initialize(name, value)
        @name = name
        @value = value
        @type = "nil"
        @const = true
    end

    def evaluate
        @type = @value.get_type
        super
    end
end
```

## nämna vilka problem ni har stött på och hur dessa har lösts. Egen reflektion av gruppen hur resultatet blev.
- Scopehantering
- Returntyper -> orsaken till att vi upptäckte problemet i statementlist
- Optimeringsproblem -> fib och nästlade arrayer
- Det blev bra, vi är nöjda med det vi ådstakom inom den givna tidsramen. (skulle alltid kunna slipa mer)

## demonstrera några exempel på datorn
- fib
- nästlade arrayer
- print(hello)