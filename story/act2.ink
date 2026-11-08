// AKT II — ZMIERZCH
// Strefy: SQ, I-3, F1, F2, L1. Zagadka P2. Warianty Głodny i Ópi.

=== act2_open ===
# chapter:act2
# location:SQ
# music:dusk_drone
# event:enemy_variant_opi
Zmierzch nie przychodzi z nieba. Wchodzi między domy, jakby ktoś zamknął drzwi po kolei.
W oknach gasną światła. Na placu stoją ludzie, ale żaden nie patrzy na Martę.
Dzwon milczy. To gorsze niż bicie.
Marta sprawdza telefon. Jedna kreska zasięgu, potem nic.
Za kościołem coś idzie wzdłuż muru — wolno, rytmicznie, jakby niosło ciężar większy od ciała.

* [Wejdź do kościoła]
    -> act2_church
* [Idź do szkoły]
    -> act2_school
* [Wejdź na ścieżkę do Jadwigi]
    -> act2_forest
* [Zejdź nad jezioro]
    -> act2_lake
* [Idź na stary cmentarz]
    -> act2_cemetery
* [Podejdź do drzwi dzwonnicy]
    -> act2_father

=== act2_church ===
# location:SQ
# portrait:priest
# music:church_echo
W kościele pali się jedna świeca. Ks. Bernard siedzi w ławce, tyłem do ołtarza.
— Wiedziałem, że przyjdziesz — mówi, nie odwracając głowy.
Na kolanach trzyma rejestr dzwonu. Okładka jest z czarnej skóry, brzegi wytarte.
— To nie jest księga parafialna — mówi Marta.
— Nie. To księga dłużników.

* [Zapytaj o rejestr]
    -> act2_church_register
* [Zapytaj o pakt]
    -> act2_church_priest
* [Wróć na plac]
    -> act2_open

=== act2_church_register ===
# portrait:priest
Ksiądz otwiera rejestr na ostatniej stronie.
— 1898 — mówi. — Szymon Kreft. 1998. 2005. 2012. 2019. 2026.
Przy każdym roku jest imię i zawód. Przy 2026 imię jest zamazane, ale Marta widzi pierwsze litery: „Ewa B.”.
— To lista ofiar.
— To lista imion, które wieś wypowiedziała — poprawia ksiądz. — Dzwon tylko je bierze.
— Kto je wypowiada?
Ksiądz nie odpowiada. Zamyka rejestr, ale nie zabiera dłoni.

~ knows_pact = true
~ knows_offering = true
~ trust_priest = trust_priest + 1
-> act2_church

=== act2_church_priest ===
# portrait:priest
— Pakt nie jest z diabłem — mówi ksiądz. — Diabeł przynajmniej negocjuje.
— Z czym więc?
— Z tym, co zostało po Szymonie. Z głodem, który nie umarł.
Ksiądz mówi, że wieś podpisała układ w 1898 roku. Co siedem lat dzwon dostaje imię, a wieś dostaje spokój.
— A jeśli się odmówi?
— Wtedy dzwon bierze tyle, ile zdoła.
Marta patrzy na jego dłonie. Tym razem się nie trzęsą.

~ knows_pact = true
~ knows_offering = true
-> act2_church

=== act2_school ===
# location:I-3
# music:school_quiet
Szkoła jest zamknięta, ale drzwi do izby pamięci są uchylone.
W środku pachnie papierem i myszami. Na ścianie wisi tablica z nazwiskami uczniów z 2012 roku.
Marta znajduje swoje nazwisko. Obok jest nazwisko Ewy Bòrcz — dopisane innym atramentem, później.
W gablocie leży kronika szkolna i zdjęcie klasy. Na zdjęciu wszyscy stoją w rzędzie, a nauczycielka trzyma dzwonek.

* [Obejrzyj zdjęcie klasy]
    -> act2_school_photo
* [Przeczytaj kronikę]
    -> act2_school_ledger
* [Wróć na plac]
    -> act2_open

=== act2_school_photo ===
# location:I-3
Na odwrocie zdjęcia ktoś napisał ołówkiem: „Ewa — następna”.
Marta odwraca fotografię. Na pierwszym planie stoi dziewczyna w granatowym swetrze. Ma twarz Wiktora.
Obok niej — Marta, siedem lat, w czepku z białej koronki. Nie pamięta tego zdjęcia.
Nauczycielka ma dzwonek. Dzwonek jest większy niż powinien.

~ knows_offering = true
~ knows_mother = true
-> act2_school

=== act2_school_ledger ===
# location:I-3
Kronika szkolna jest prowadzona od 1945 roku. Wpis z 2005 jest krótki:
„W wyniku wypadku zmarł nauczyciel. Wieś przyjęła nowego.”
Pod spodem, inną ręką: „Dzwon wziął imię, nie ciało”.
W 2012 roku wpis jest jeszcze krótszy: „Zmiana”.
W 2019: „Zofia Kreft. Wypadek nad jeziorem. Lekcje odwołane”.
Marta zamyka kronikę. Papier jest zimny.

~ knows_pact = true
-> act2_school

=== act2_forest ===
# location:F1
# music:forest_night
# portrait:cotka
Ścieżka do Jadwigi jest wąska i mokra. Drzewa stoją zbyt blisko siebie, jakby ktoś je posadził w pośpiechu.
Na środku drogi stoi kobieta w czerni. Nie ma twarzy, tylko białą chustę i ręce zbyt długie.
Bòrowô Cotka nie atakuje. Czeka.
— Kreft — mówi. — Znowu Kreft. Wchodzisz czy pytasz?
Marta czuje zapach lasu i mokrej wełny.

* [Przejdź test Cotki]
    -> act2_forest_test
* [Zapytaj o zwrotkę]
    -> act2_forest_verse
* [Wróć na plac]
    -> act2_open

=== act2_forest_test ===
# location:F1
# portrait:cotka
— Trzy pytania — mówi Cotka. — Odpowiesz, przejdziesz. Skłamiesz, zostaniesz.
— Pytaj.
— Kogo szukasz?
— Ojca.
— Co oddasz?
Marta milczy. Cotka przechyla głowę.
— Co oddasz, żeby go zobaczyć?
— Prawdę — mówi Marta. — Oddam prawdę o sobie.
Cotka odsuwa się z drogi. Po raz pierwszy wygląda na starą.
— Wtedy wejdź. I pamiętaj: las nie lubi, jak się go nazywa.

~ cotka_help = true
~ knows_birthright = true
-> act2_forest

=== act2_forest_verse ===
# location:F1
# portrait:cotka
— Trzecia zwrotka — mówi Cotka. — Tylko dla tych, którzy przyszli pieszo.
Głos ma jak wiatr w gałęziach:
— Kto pierwszy zadzwoni, ten ostatni wyjdzie.
— To wszystko?
— To wszystko, co wolno mi powiedzieć.
Zza drzew wychodzi Jadwiga. Jest starsza niż wczoraj, ale uśmiecha się.
— Chodź — mówi. — Pokażę ci, co wieś zrobiła z twoją matką.

-> act2_forest

=== act2_lake ===
# location:L1
# music:lake_wind
# portrait:wiktor
Jezioro jest czarne i gładkie. Po drugiej stronie pali się jedno światło — pewnie latarnia na cmentarzu.
Wiktor stoi na pomoście z dubeltówką przewieszoną przez ramię.
— Myślałem, że nie przyjdziesz — mówi.
— Przyszłam.
— Chciałem, żebyś wyjechała. Ciebie też by to ominęło.
Podaje jej strzelbę. Jest ciężka i zimna.

* [Porozmawiaj z Wiktorem]
    -> act2_lake_wiktor
* [Zapytaj o Zofię]
    -> act2_lake_zofia
* [Wróć na plac]
    -> act2_open

=== act2_lake_wiktor ===
# location:L1
# portrait:wiktor
— Ewa nie wie, że jest na liście — mówi Wiktor. — Albo wie i udaje, że nie.
— Możemy ją wywieźć.
— Drogę zasypało. A nawet gdyby nie...
Patrzy na jezioro.
— W 2019 twoja matka próbowała wyjechać. Doszła do skrętu i zawróciła.
— Dlaczego?
— Bo usłyszała dzwon.
Wiktor podaje jej pudełko naboi. — Weź. I nie strzelaj, jeśli nie musisz. To nie pomaga.

~ trust_wiktor = trust_wiktor + 1
~ knows_offering = true
-> act2_lake

=== act2_lake_zofia ===
# location:L1
# portrait:wiktor
— Twoja matka przyszła tu w nocy — mówi Wiktor. — Stała dokładnie tutaj.
— Wiem.
— Nie wiesz. Wszyscy mówią, że utonęła. Ale ja ją widziałem rano.
Marta czeka.
— Siedziała na pomoście. Była sucha. Powiedziała: „Powiedz Marcie, że dzwon zna jej imię”.
Wiktor kopie deskę. — Nie powiedziałem. Bałem się.

~ knows_mother = true
-> act2_lake

=== act2_cemetery ===
# location:F2
# music:cemetery_night
Stary cmentarz jest za wsią, za pasem brzóz. Groby są niskie, zapadnięte, bez kwiatów.
Grób Szymona Krefta jest największy. Kamień jest nowy. Ktoś go niedawno wymienił.
Na nagrobku widnieje tylko imię i data: 1898.
Ziemia wokół jest świeżo poruszona, ale nie od strony grobu. Od strony dzwonnicy.

* [Obejrzyj grób Szymona]
    -> act2_cemetery_grave
* [Zapytaj o zwrotkę]
    -> act2_cemetery_verse
* [Wróć na plac]
    -> act2_open

=== act2_cemetery_grave ===
# location:F2
Marta odsuwa darń. Pod nią jest płyta z otworem, wielkości dłoni.
W otworze nie ma nic. Jest za to rysa prowadząca w stronę wsi.
— Głowa — mówi Marta. — Nie ma głowy.
Na kamieniu, od spodu, ktoś wydrapał trzy kreski. Dwie są przekreślone.
Marta rozumie: Szymon leży bez głowy od stu lat. Dzwon ma ją w fundamencie.

~ knows_head = true
-> act2_cemetery

=== act2_cemetery_verse ===
# location:F2
Marta słyszy głos za plecami. Nie odwraca się.
— Kto pierwszy zadzwoni, ten ostatni wyjdzie.
To trzecia zwrotka. Mówi ją Jadwiga, która stoi między brzozami z latarką.
— Nie chodź tu sama — mówi. — Stary nie lubi gości.
— Jaki stary?
— Ten, który był pierwszy.
Jadwiga gaśnie latarkę. — Chodź. Musimy zdążyć przed siódmym biciem.

-> act2_cemetery

=== act2_father ===
# location:SQ
# portrait:antoni
# music:tower_door
Drzwi dzwonnicy są zamknięte od środka. Marta przykłada dłoń do deski.
— Tato?
Cisza. Potem szuranie, jakby ktoś przesuwał krzesło.
— Marta — mówi Antoni. Głos jest jego, ale zmęczony, jakby mówił przez wodę.
— Otwórz.
— Nie mogę. Jeszcze nie.
— Tato, co się stało?
— Przyszedłem zapłacić. Myślałem, że zdążę.
Za drzwiami coś uderza w dzwon. Raz. Dwa. Siedem.

* [Zapytaj, co się stało]
    -> act2_father_truth
* [Powiedz, że przyszłaś go zabrać]
    -> act2_father_mercy
* [Odejdź]
    -> act2_open

=== act2_father_truth ===
# portrait:antoni
— W 2019 twoja matka stanęła przed dzwonem — mówi Antoni. — Miała wyjechać. Zamiast tego wypowiedziała swoje imię.
— Dlaczego?
— Bo ja ją o to poprosiłem. Bałem się, że dzwon weźmie ciebie.
Marta opiera czoło o drzwi.
— A teraz?
— Teraz przyszła kolej na Ewę. Albo na mnie. Albo na ciebie.
— Jak to przerwać?
— Dzwon musi dostać to, czego nie ma. Głowę. I imię, które nie jest imieniem wsi.
Antoni uderza w drzwi od środka. — Idź do rejestru. Wszystko tam jest.

~ knows_pact = true
~ knows_offering = true
-> act2_turning

=== act2_father_mercy ===
# portrait:antoni
— Przyszłam cię zabrać — mówi Marta.
Cisza jest długa. Potem Antoni śmieje się krótko, bez radości.
— Nie można zabrać kogoś, kto już obiecał, że zostanie.
— Można spróbować.
— Wtedy spróbuj mnie nie nienawidzić, kiedy ci się nie uda.
Marta czuje, że to pożegnanie, choć ojciec jeszcze mówi.

~ mercy = mercy + 1
~ knows_pact = true
-> act2_father

=== act2_turning ===
# chapter:act2
# location:SQ
# event:bell_seven
# event:enemy_variant_opi
# sfx:bell_seven
# music:dusk_drone
Dzwon bije siedem razy. Za każdym razem wieś robi się mniejsza.
Ks. Bernard prowadzi Ewę do kościoła. Dziewczyna nie stawia oporu. Wiktor krzyczy, ale dwóch mężczyzn trzyma go przy studni.
— Dla jej bezpieczeństwa — mówi ksiądz. — Do rana.
Drzwi kościoła zamykają się. Dzwon milknie.
Marta patrzy na dzwonnicę. W oknie na górze pali się światło. Ktoś tam jest.
Na placu zostaje tylko śnieg i ślady prowadzące do drzwi.

~ knows_rite = true
~ knows_offering = true
-> act3_open
