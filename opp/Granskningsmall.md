# Granskningsmall
Granskning av Baljan-Language
## Det skapade datorspråket

- __Verkar språket uppfylla de krav som språket är tänkt att användas till?__
    > De hade siktat på ett objektorienterat språk men hade inte tid att implementera mer än för betyg 3. Scope-hanteringen fungerar inte hela vägen specifikt för funktioner, där två funktioner i ett aritmetiskt uttryck kommer resultera i att den ena funkitonen kommer anta den andra funktionens parametervärden som sin egna.

- __Egna synpunkter på språket. Dess syntax och semantik.__
    > Acceptabel syntax. Lite konstigt att man kan blanda kodblocks-tecken. Likt C++ och ruby, som tänkt. Saknar void funktioner vilket kan tyckas är lite dåligt 

- __Användarhandledningen. Är det möjligt att förstå hur språket fungerar och kan man enkelt lära sig det genom att läsa manualen? Finns bra exempel?__
    > Både ja och nej: för oss var det lätt att förstå hur programspråket fungerade, men detta är förmodligen tack vare tidigare kunskap inom C++. Indexeringen på listor exempelvis. Står inte att man kan hantera listor i listor.

## Språkbeskrivningen med grammatik
- __Grammatiken. Verkar den vara korrekt, välskriven och ha korrekta benämningar på de olika språkkonstruktionerna?__
    > Språkets bnf verkar inte stämma överäns med koden för systemet vi fick, utan representerar deras tänkta funktionalitet. Detta gör att den inte hjälper så mycket. Ordningen verkar inte vara väldigt logisk.

- __Överensstämmer beskrivningen av språket med grammatiken?__
    > Nej.

- __Finns det konstruktioner i språket som grammatiken ej verkar ta upp, eller beskriver grammatiken möjliga konstruktioner, som språket ej verkar kunna hantera.__
    > Ja, exempelvis strings, minneshantering och klasser.

- __Ger systembeskrivningen en bra bild på hur implementeringen ser ut?__
    > Den ger inblickar i delar av systemet, bra översiktlig beskrivning aav vissa klasser, men andra saknas. Lite oklart hur det abstrakta syntax-trädet byggs upp.

## Implementering av verktyg eller användning av verktyg för språket
- __Det implementerade systemet (interpretator, kompilator, översättare av notation mm). Verkar det vara en bra modell?__
    > Nej, då det inte verkar som ett skapas Ett abstrakt syntaxträd. Saknar noder för funktionsdefinitioner. Implementationen gör att det inte går att skapa funktioner innuti andra funktioner. Ytterligare ett problem som uppstår är att när två funktionsanrop befinner sig i samma uttryck, kommer funketionens parametrar uppdateras två gånger, och evalueras efter den andra gången.

- __Implementering av egna eller användning av existerande verktyg (lexer/parser etc). Verkar verktyget lämpat för uppgiften? Är verktyget använt på ett bra sätt? Finns det begränsningar i verktyget, som gör det svårt att implementera datorspråket?__ 
    > De anväder Rdparse, som har vissa begränsingar, men inga som dem har tagit upp. 

## Metoder och algoritmer.
- __Synpunkter på valda metoder och algoritmer, verkar de vara bra val? Kan det bli mycket ineffektivt? Finns det alternativ, som hade blivit bättre?__
    > De har inte använt några algoritmer enligt systemdokumentationen.

## Koden för implementeringen i Ruby.
- __Är koden bra modulariserad? Kan man särskilja de olika delarna som programmet består utav och de olika algoritmerna.__
    > Den är uppdelad och helt okej modulariserad.

- __Finns det en överensstämmelse mellan hur grammatiken är beskriven och motsvarande strukturer och kod i programmet.__
    > Beskrivningen av grammatiken stämmer inte överens med kodens struktur och gör det lite förvirrande.

- __Är koden läsbar och förståelig för dig som läsare? Val av namn på olika storheter (identifierare för variabler, klasser, metoder/funktioner/procedurer mm).__
    > Koden är läsbar, men inte utan svårigheter. Det förekommer en viss oregelbundenhet i kommenteringen och variabelnamnen i exempelvis parsern kunde varit bättre. Ex `:arithmatic_operator_A` och `:arithmatic_operator_B`.

- __Ta gärna ut en del som du tycker var bra och motivera varför.__
    > Återkommer när en är funnen <--------------------------

- __Ta gärna ut en del som du tycker var dåligt / som du inte alls enkelt kan förstå och motivera varför.__
    > Delen om hur funktioner och variabler lagras samt noderna som representerar dessa. Denna process sker utanför parsningen och tar en på en lång resa för att se hur allt hänger ihop. 

- __Har Ruby använts på ett bra sätt? Har ni alternativa förslag på hur man kan använda andra Ruby-konstruktioner.__
    > Ruby har använts på ett rimligt sätt.

## Code complete-boken eller andra kodstandarder

- __Verkar programmerarna ha följt en egen kodstandard?__
    > Nej, de verkar ha hållit sig till en viss standard.

- __Försök att finna någon aspekt i den kod ni granskar för att se hur den uppfyller synpunkterna/kraven som boken eller andra standarder ställer. Ni kan inte vara heltäckande. Ange var ni hittar motsvarande aspekter på kod i boken.__ 
    > Tänker inte öppna code complete.

## Testkörning av språket
- __Var det lätt att komma igång med systemet?__
    > Ja, Bortsett från instruktionerna under 2.1 installation i användarhandledningen, så gick det snabbt att köra första test-filen.

- __Är det lätt att skriva program i språket? Ger användarhandledningen stöd för detta?__
    > Ja, programspråket följer rimlig syntax och det är lätt att ställa in sig på den. Användarhandledningen bidrar med exempel på hur kod kan se ut, vilket är till hjälp.

- __Visade egna testkörningar på några problem? Felaktigheter uppstår vid felaktig kod i datorspråket.__
    > Ja. Som nämnt tidigare går ej två funktionsanrop, till samma funktion, med olika parametrar att köra och få ett väntat resultat. Detta upptäckte vi då vi försökte implementera en funktion för att beräkna fibonacci(n). Vi upptäckte även att funktioner inte kan definieras innuti funktioner.

- __Finns oklarheter i konstruktioner, vad som borde hända?__ 
    > Ja, till viss del.
