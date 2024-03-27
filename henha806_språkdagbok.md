# Språkdagbok
- 13/2 Vi satt tillsammans och forskade kring vilket språk vi skulle skapa och kom fram till en imperativ klon som är en hybrid mellan c++ och python. Vi skrev klart språkspecifikation v1.

- 21/2 Inför språkspecifikation v2 fyllde vi ut och tog bort vissa saker. Vi bytte exempelvis ut for-loopar till while-loopar. Det är lite svårt att skriva en språkspec utan att riktigt veta hur språket ska implementeras så det känns lite som en gissningslek i såhär tidigt skede.

- 27/2 Efter duggan i tdp007 på morgonen har vi suttit och skrivit BNFen då vi missuppfattade grammatik-delen av språkspecifikationen inför V2. Vi lade även till lite tankar kring scope-hantering med hänsyn till frames i språkspecen. Detta har tagit en stor del av förmiddagen och på eftermiddagen har vi suttit och skrivit ett utkast till implemenationsplanen.

- 22/3 Idag gick vi igenom samtliga kaptiel av SMoL tutor, några delar var nyttiga för projektet.

- 25/3 Vi har under förmiddagen idag börjat att implementera programmeringsspråket. En stor del av tiden gick till att försöka förstå vart vi skulle börja. Vi anväde oss av projektidéerna på kurshemsidan för att få en humm om vad vi skulle uppnå. De vi hann göra idag var att skapa filer för klasserna Node och Scope som ska vara byggstenarna för språket.

- 26/3 Idag har vi jobbat vidare på att implementera språkets grammatik. Det har varit väldigt svårt att veta från vilket håll man ska börja då det känns som man behöver ha en tanke om hur alla komponenter ska se ut och hänga ihop för att göra det. Vi har dock valt att avgränsa oss till att försöka få enkla matematiska operationer att fungera, då kan vi bygga vidare på det. Detta innebar att vi behövde implementera grammatiken och noderna som ska representera alla tal/variabler och operationer. Vi märkte att några saker saknades i BNFen och vi har justerat dessa. Under eftermiddagen lyckades vi få den enkla matematiken att fungerar(Kanske) men scope-stacken fungerar inte, det finns alltså inga omgivningar och programmet evalueras på ett lite fult sätt.

- 27/3 Idag har vi justerat implementeringen av aritmetiska uttryck. Vi hade ett problem där "**" inte fungerade och löste det genom att ändra ordningen i tokens, detta löste även problemet att "!=" inte fungerade då "!" konsumerades av not-token.Ännu ett problem var associativiteten för negativa uttryck och "-1--1" gav inte väntat resultat. Vi justerade regeln för minus-operationen och löste problemet. Vi även har skrivit enhetstester för den kod vi har hunnit implementera och vi har fått variabeltilldelning och variabel-anrop att fungera under eftermiddagen. 

