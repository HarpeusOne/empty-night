// AKT I — DZIEŃ
// Strefy: V1, V2, V3, SQ, I-1, I-2. Zagadka P1. Dwa warianty Głodnego.

=== act1_arrival ===
# chapter:act1
# location:V1
# music:village_day
Autobus odjeżdża, zanim Marta zdąża wyjąć torbę z bagażnika.
Silnik kaszle, chowa się za mgłą, zostawia ją na poboczu z dyktafonem i listem ojca w kieszeni.
Znak wsi jest przechylony. Litery ktoś poprawił farbą, ale deszcz zjadł połowę.
Gdzieś za drzewami bije dzwon. Raz. Dwa. Siedem.
Jest druga po południu. Dzwon nie powinien bić o tej porze.

* [Idź do sklepu Hanny]
    -> act1_hanna_intro
* [Stań na placu i posłuchaj]
    -> act1_square

=== act1_hanna_intro ===
# location:SQ
# portrait:hanna
Hanna Rekòwskô nie podaje ręki. Wyciera szklankę, choć jest sucha.
— Marta Kreft — mówi, jakby sprawdzała, czy imię się zgadza. — Wróciłaś.
Na ladzie leży zeszyt z listą nazwisk. Hanna odwraca go okładką do góry.
Za nią, w szklanej gablocie, wisi różaniec i zdjęcie klasy z 2012 roku.

* [Zapytaj, skąd zna jej imię]
    -> act1_hanna_hub
* [Rozejrzyj się po sklepie]
    -> act1_hanna_hub

=== act1_hanna_hub ===
# location:SQ
# portrait:hanna
Hanna układa na ladzie trzy słoiki: ogórki, powidła, coś ciemnego bez etykiety.
— Zaduszki jutro — mówi. — Dziś wieś sprząta. Ty też powinnaś.
Za oknem ktoś przechodzi w stronę kościoła i nie odwraca głowy.

* [Zapytaj o ojca]
    -> act1_hanna_father
* [Zapytaj o dzwon]
    -> act1_hanna_bell
* [Zapytaj o matkę]
    -> act1_hanna_mother
* [Wyjdź na plac]
    -> act1_square

=== act1_hanna_father ===
# portrait:hanna
— Antoni? — Hanna odkłada szklankę. — Był tu w piątek. Kupił świece. Sześć.
Mówi, że poszedł do dzwonnicy i że wróci przed nocą.
Nie wrócił.
— Może wróci — dodaje. — Ludzie wracają na Zaduszki.
Jej dłoń przez chwilę leży na zeszycie z listą.

~ trust_hanna = trust_hanna + 1
-> act1_hanna_hub

=== act1_hanna_bell ===
# portrait:hanna
— Dzwon bije, bo ktoś go prosi — mówi Hanna.
— Kto?
— Wieś.
Śmieje się krótko, bez radości.
— Jak chcesz nagrywać, to idź do księdza. On ma klucz. I cierpliwość.

-> act1_hanna_hub

=== act1_hanna_mother ===
# portrait:hanna
Hanna przez chwilę patrzy na drzwi, jakby chciała, żeby ktoś wszedł.
— Zofia była dobrą kobietą — mówi wreszcie. — Utonęła w jeziorze. Wiesz to.
— Wiem, co mi powiedziano.
— To wiedz też, że wieś jej nie zapomniała.
Nie wyjaśnia, co to znaczy.

~ knows_mother = true
-> act1_hanna_hub

=== act1_square ===
# location:SQ
# music:village_day
Plac jest prawie pusty. Biały kościół podnosi nad dachami wieżę z zegarem,
który spóźnia się o trzy minuty. Przed urzędem gminy stoi drewniany Rétnik,
wyższy od człowieka, i patrzy w stronę lasu.
Dzwonnica jest zamknięta. Na drzwiach wisi nowa kłódka, a pod nią stara kartka: „Nie dotykać. Konserwacja.”
Marta wie, że nikt jej nie zgłosił.
Przy studni siedzi Jadwiga Mòtk i obiera jabłko jednym długim ruchem noża.
Wiktor Bòrcz grzebie przy starym Polonezie, którego nie da się uruchomić. Ks. Bernard stoi na schodach kościoła i patrzy na nią, ale nie macha.

* [Podejdź do księdza]
    -> act1_priest
* [Podejdź do Wiktora]
    -> act1_wiktor
* [Podejdź do Jadwigi]
    -> act1_jadwiga
* [Wejdź do domu ojca]
    -> act1_house
* [Zejdź nad młyn]
    -> act1_mill
{ found_key && found_pin && !found_hymn:
    * [Otwórz szafę na chórze]
        -> act1_porch
}
{ found_hymn:
    * [Wróć pod dzwonnicę]
        -> act1_dusk
}

=== act1_priest ===
# location:SQ
# portrait:priest
Ks. Bernard Rëbôk ma ręce złożone tak, jakby się modlił, ale oczy ma otwarte.
— Pani Kreft — mówi. — Córka Antoniego.
— Marta.
— Wiem.
Za jego plecami kościół jest ciemny. Pachnie woskiem i mokrym kamieniem.

* [Zapytaj o dzwon]
    -> act1_priest_bell
* [Zapytaj o ojca]
    -> act1_priest_father
* [Wróć na plac]
    -> act1_square

=== act1_priest_bell ===
# portrait:priest
— Dzwon jest zabytkiem — mówi ksiądz. — Ma sto lat. Więcej niż sto.
— Bije bez dzwonnika.
— Bije, bo mechanizm jest stary. To się zdarza.
Marta patrzy na jego dłonie. Drżą.
— Jeśli chce pani go nagrać, proszę przyjść jutro. Po mszy.
Kłamie. Oboje to wiedzą.

-> act1_priest

=== act1_priest_father ===
# portrait:priest
— Antoni jest człowiekiem sumienia — mówi ksiądz. — Może potrzebuje czasu.
— Minęło siedem dni.
— Siedem dni to nie wieczność.
Po chwili dodaje ciszej:
— Proszę nie wchodzić do dzwonnicy. To nie miejsce dla pani.

~ trust_priest = trust_priest + 1
-> act1_priest

=== act1_wiktor ===
# location:SQ
# portrait:wiktor
Wiktor „Wëk” Bòrcz ma ręce ufajdane smarem i twarz, która nie umie kłamać.
— Marta — mówi. — Myślałem, że już nie przyjedziesz.
— Przyjechałam po ojca.
— Wiem.
Patrzy w stronę kościoła. Jego siostra, Ewa, stoi na schodach plebanii i pali papierosa, choć ma siedemnaście lat.

* [Zapytaj o Ewę]
    -> act1_wiktor_ewa
* [Zapytaj o ojca]
    -> act1_wiktor_father
* [Wróć na plac]
    -> act1_square

=== act1_wiktor_ewa ===
# portrait:wiktor
— Ewa ma siedemnaście lat — mówi Wiktor. — I od tygodnia nie wychodzi z domu.
— Boi się?
— Nie. Czeka.
Marta nie rozumie. Wiktor patrzy na nią dłużej, niż trzeba.
— Ty też kiedyś czekałaś. W 2019.
Nie mówi nic więcej.

-> act1_wiktor

=== act1_wiktor_father ===
# portrait:wiktor
— Antoni przyszedł do mnie w piątek — mówi Wiktor. — Chciał, żebym naprawił mu latarkę.
— I?
— Powiedział: „Jeśli nie wrócę, powiedz Marcie, żeby nie liczyła uderzeń”.
Potem poszedł do dzwonnicy.
Wiktor kopie oponę. — Nie wiem, co to znaczy. Ale nie lubię, jak ktoś tak mówi.

~ trust_wiktor = trust_wiktor + 1
-> act1_wiktor

=== act1_jadwiga ===
# location:SQ
# portrait:jadwiga
Jadwiga Mòtk ma osiemdziesiąt jeden lat i oczy, które widziały więcej, niż chce pamiętać.
— Siadaj — mówi. — Ta studnia pamięta twoją matkę.
Marta siada. Kamień jest zimny.
— Znasz zwrotkę? — pyta Jadwiga. — Tę o dzwonie bez serca?

* [Zapytaj o zwrotkę]
    -> act1_jadwiga_verse
* [Zapytaj o matkę]
    -> act1_jadwiga_mother
* [Wróć na plac]
    -> act1_square

=== act1_jadwiga_verse ===
# portrait:jadwiga
Jadwiga mówi cicho, rytmicznie, jakby recytowała coś, co zna na pamięć od dziecka:
— Dzwon bez serca, głowa bez ciała. Imię bez domu, dom bez imienia.
— Co to znaczy?
— To znaczy, że nie wszystko, co ma dzwon, jest dzwonem.
Podaje Marcie jabłko. — Zapamiętaj. Przyda się, kiedy będzie ciemno.

-> act1_jadwiga

=== act1_jadwiga_mother ===
# portrait:jadwiga
— Zofia przyszła do mnie w 2019 — mówi Jadwiga. — W nocy. Miała mokre włosy i nie płakała.
— Co powiedziała?
— „Jeśli Marta wróci, niech nie wierzy, że to woda”.
Marta chce zapytać więcej, ale Jadwiga wstaje i zabiera nóż.
— Reszta jest w lesie. Przyjdź, jak będziesz gotowa.

~ knows_mother = true
-> act1_jadwiga

=== act1_house ===
# location:I-1
# music:house_creak
Dom Kreftów pachnie kurzem i zimnym piecem.
Ktoś przestawił meble. Nie splądrował ich — przestawił, jakby chciał, żeby wyglądały na nietknięte.
Na ścianie wisi fotografia: Antoni, Zofia i Marta, 2019. Twarz Zofii jest zamazana palcem.
W kuchni stoi szklanka z herbatą. Herbata jest zimna, ale nie pleśniała.

* [Wejdź do gabinetu]
    -> act1_study
* [Przeczytaj list na stole]
    -> act1_letter
* [Wróć na plac]
    -> act1_square

=== act1_study ===
# location:I-1
Gabinet Antoniego jest mniejszy, niż Marta pamięta. Na biurku leży futerał po skrzypcach, otwarty.
W środku, zamiast skrzypiec, jest klucz do szafy organisty i kartka:
„Nie otwieraj, dopóki nie będziesz wiedziała, czyje imię mówisz”.
Marta chowa klucz do kieszeni. Na parapecie stoi niedopałek. Świeży.

~ found_key = true
-> act1_house

=== act1_letter ===
# location:I-1
List jest krótki, pisany ołówkiem, złożony w czworo.
„Marto. Jeśli to czytasz, znaczy, że nie zdążyłem.
Nie otwieraj dzwonnicy. Jeśli usłyszysz dzwon o zmierzchu, nie licz uderzeń.
I nie ufaj temu, co wieś nazywa porządkiem.
Tata”.
Na odwrocie jest rysunek: dzwon, a pod nim trzy kreski. Jedna jest przekreślona.

-> act1_house

=== act1_mill ===
# location:I-2
# music:mill_water
Stary młyn stoi nad kanałem, który dawno przestał mleć.
Woda jest czarna i gęsta. Pachnie rdzą i czymś słodkim.
Na ścianie wisi tabliczka: „Nie sypać do kanału”.
Ktoś wydrapał pod nią paznokciem: „on słucha”.

* {not found_pin} [Zejdź do kanału]
    -> act1_mill_canal
* [Przyjrzyj się kamieniowi młyńskiemu]
    -> act1_mill_verse
* [Wróć na plac]
    -> act1_square

=== act1_mill_canal ===
# location:I-2
Marta schodzi po mokrych stopniach. Szlam sięga kostek, a woda stoi, jakby czekała.
Pod kratą coś błyszczy. To drewniany sworzeń, czarny od wody, z wypalonym znakiem dzwonu.
Jest ciepły, choć woda jest zimna.
Marta wyciąga go i chowa do kieszeni kurtki.

~ found_pin = true
-> act1_mill

=== act1_mill_verse ===
# location:I-2
Na kamieniu młyńskim ktoś wydrapał słowa. Litery są nierówne, jakby pisała je trzęsąca się ręka.
„Imię bez domu, dom bez imienia.”
Pod spodem, mniejszymi literami: „Serce dzwonu w kamieniu, nie w brązie.”
To druga zwrotka. Marta przepisuje ją na odwrocie listu ojca.
Trzeciej nie ma. Ktoś zeskrobał ją do gołego kamienia.

~ knows_head = true
-> act1_mill

=== act1_porch ===
# location:SQ
# music:church_echo
Szafa na chórze jest stara, ale zamek nowy. Klucz wchodzi bez oporu.
W środku leży śpiewnik, owinięty w ceratę, i drewniany sworzeń, który pasuje do zawiasu drzwi.
Na okładce śpiewnika ktoś napisał: „Na siedem głosów”.
Marta otwiera pierwszą stronę. Jest tam zwrotka o dzwonie bez serca i data: 1898.

~ found_hymn = true
-> act1_dusk

=== act1_dusk ===
# chapter:act1
# location:SQ
# event:bell_dusk
# event:first_death
# event:road_blocked
# sfx:bell_seven
# music:dusk_drone
Dzwon bije siedem razy. Marta liczy mimo zakazu ojca.
Po siódmym uderzeniu światło na placu robi się inne — nie ciemniejsze, tylko starsze.
Stary Józwa wychodzi zza węgła kościoła. Idzie do dzwonnicy, choć drzwi są zamknięte.
Nie widzi Marty. Nie widzi nic.
Kiedy dzwon milknie, Józwa leży na kamieniach. Jego cień jest dłuższy niż ciało.
Droga wjazdowa jest zasypana świeżym śniegiem. Nie ma śladów. Nie ma autobusu.

~ bell_count = 7
-> act2_open
