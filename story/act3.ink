// AKT III — NOC
// Strefy: SQ, L1, F2, I-4. Zagadka P3. Warianty Ópi i Stary.

=== act3_open ===
# chapter:act3
# location:SQ
# music:night_drone
# event:enemy_variant_stary
Noc nie jest ciemna. Jest gęsta.
Dzwon bije co kilka minut, ale nikt go nie porusza. W oknach nie ma świateł.
Na ulicy stoi Ópi. Nie rusza się, dopóki Marta nie odwraca wzroku. Wtedy jest o krok bliżej.
Za nim, w stronę jeziora, idzie ktoś jeszcze — wyższy, wolniejszy, z głową przekrzywioną na bok.

* [Idź do ocalałych nad jeziorem]
    -> act3_survivors
* [Idź na stary cmentarz]
    -> act3_cemetery
* [Wejdź do dzwonnicy]
    -> act3_tower

=== act3_survivors ===
# location:L1
# music:lake_wind
# portrait:wiktor
W starej szopce nad jeziorem pali się lampa naftowa.
Hanna siedzi na skrzyni po jabłkach. Wiktor stoi przy oknie z dubeltówką. Jadwiga grzeje ręce nad blaszanym piecykiem.
— Ewa jest w kościele — mówi Wiktor. — Ks. Bernard zamknął ją z ks. wikarym i poszedł do dzwonnicy.
— Do dzwonnicy?
— Powiedział, że idzie „dokończyć porządek”.
Hanna patrzy na Martę. — Twoja matka też tu siedziała. Tej samej nocy.

* [Porozmawiaj z Hanną]
    -> act3_survivors_hanna
* [Porozmawiaj z Wiktorem]
    -> act3_survivors_wiktor
* [Porozmawiaj z Jadwigą]
    -> act3_survivors_jadwiga
* [Wróć na plac]
    -> act3_open

=== act3_survivors_hanna ===
# location:L1
# portrait:hanna
— Mam listę — mówi Hanna. — Wszystkie imiona od 1898. Schowałam ją w sklepie, w słoiku po ogórkach.
— Dlaczego mi nie powiedziałaś?
— Bo bałam się, że zostaniesz.
Hanna wyjmuje z kieszeni kartkę. Jest na niej imię Ewy, a pod nim — imię Marty, przekreślone.
— Kto je przekreślił?
— Ja. W 2019. Myślałam, że jeśli skreślę, dzwon nie zauważy.
Jej ręce drżą. — Nie zauważył. Do teraz.

~ trust_hanna = trust_hanna + 1
-> act3_survivors

=== act3_survivors_wiktor ===
# location:L1
# portrait:wiktor
— Mogę wejść do kościoła od zakrystii — mówi Wiktor. — Znam te drzwi.
— A jeśli Ewa już nie jest Ewą?
Wiktor nie odpowiada. Patrzy na jezioro.
— W 2019 widziałem twoją matkę na pomoście. Była spokojna. To mnie przerażało.
— Co masz na myśli?
— Że może nie trzeba jej było zmuszać.
Wiktor podaje Marcie latarkę. — Idź do dzwonnicy. Ja zajmę się Ewą. Jeśli nie wrócę, nie czekaj.

~ trust_wiktor = trust_wiktor + 1
-> act3_survivors

=== act3_survivors_jadwiga ===
# location:L1
# portrait:jadwiga
Jadwiga nie patrzy na Martę. Patrzy na ogień.
— Twoja matka nie utonęła — mówi. — Utonęła tylko dla wsi.
— Wiem.
— Nie wiesz. Ona zgodziła się, żebyś ty nie musiała. I ty też się zgodzisz, jeśli nie będziesz uważać.
Marta milczy.
— Dzwon zna twoje imię, bo urodziłaś się w czepku. To znaczy, że jesteś jego. Na zawsze.
Jadwiga wyjmuje z kieszeni ołówek i zeszyt. — Jeśli przeżyję, zapiszę wszystko. Ktoś musi pamiętać.

{ knows_birthright:
    ~ witness_flag = true
    Jadwiga patrzy na Martę, jakby widziała w niej kogoś, kogo już raz pochowała.
}
-> act3_survivors

=== act3_cemetery ===
# location:F2
# music:cemetery_night
Cmentarz jest biały od śniegu. Groby wyglądają jak zęby.
Grób Szymona jest otwarty. Płyta leży obok, a w środku — nie ma ciała. Tylko ciemna ziemia i ślad po czymś, co zostało wyjęte.
Za nagrobkiem stoi Stary. Nie atakuje. Czeka, aż Marta podejdzie.
— Kreft — mówi. Głos ma jak kamień pod wodą. — Przyszłaś oddać głowę?

* [Obejrzyj otwarty grób]
    -> act3_cemetery_grave
* [Wróć na plac]
    -> act3_open
* [Wejdź do dzwonnicy]
    -> act3_tower

=== act3_cemetery_grave ===
# location:F2
Marta klęka przy grobie. W ziemi jest wgłębienie wielkości ludzkiej głowy, ale nic w nim nie leży.
Na dnie widnieje odcisk dzwonu — okrągły, z trzema kreskami.
— Głowa jest w fundamencie — mówi Marta. — Zawsze była.
Stary kiwa głową. — Dzwon nie chce ciała. Chce imienia. Głowa to tylko miejsce, w którym je trzyma.
Marta czuje, że to nie wyjaśnienie. To zaproszenie.

~ knows_head = true
-> act3_cemetery

=== act3_tower ===
# location:I-4
# portrait:antoni
# music:tower_heart
Dzwonnica jest w środku większa niż na zewnątrz. Ściany są mokre, choć nie pada.
Na schodach leży latarka Antoniego. Świeci w stronę dzwonu.
Antoni stoi pod nim. Jest blady, chudy, a jego cień ma o jedną rękę za dużo.
— Marta — mówi. — Nie podchodź.
— Tato.
— Jeszcze nie.
Dzwon jest ogromny. Na jego koronie widnieje twarz — nie rzeźba, tylko coś, co wygląda jak odcisk twarzy w brązie.
W fundamencie, pod dzwonem, jest płyta z otworem.

~ father_found = true
{ knows_rite && cotka_help:
    -> act3_wieszczy_stary
- knows_rite:
    -> act3_wieszczy_opi
- else:
    -> act3_wieszczy_glodny
}

=== act3_wieszczy_glodny ===
# location:I-4
# event:enemy_variant_glodny
Coś zbiega po schodach. Nie ma twarzy, tylko otwarte usta i ręce zbyt długie.
Głodny uderza w dzwon, raz po raz, jakby chciał go rozbić własnym ciałem.
Antoni krzyczy, żeby Marta uciekała. Dzwon bije bez rytmu.
Marta chwyta za łańcuch. Ciężar ciągnie ją w dół, ale dzwon na chwilę milknie.
W ciszy słychać tylko oddech — jej i ojca.

-> act3_final_choice

=== act3_wieszczy_opi ===
# location:I-4
# event:enemy_variant_opi
Ópi stoi na schodach. Ma na sobie szatę organisty, którą Marta widziała na zdjęciu z 2012 roku.
Nie atakuje. Podnosi rękę i wskazuje na dzwon.
— Jeden — mówi. — Dwa. Siedem.
Jego głos jest głosem jej ojca, tylko młodszego.
Antoni zasłania Martę. — To nie ja. To dzwon.
Ópi uderza w poręcz. Drewno pęka. Marta cofa się w stronę fundamentu.

-> act3_final_choice

=== act3_wieszczy_stary ===
# location:I-4
# event:enemy_variant_stary
# portrait:szymon
Stary stoi pod dzwonem. Ma twarz Szymona Krefta — tę samą, co na zdjęciu w gabinecie.
— Wnuczko — mówi. — Przyszłaś mnie pogrzebać?
— Przyszłam przerwać dzwon.
— Dzwon nie jest więzieniem. Jest umową.
Szymon podnosi rękę. Na dłoni ma wypaloną twarz dzwonu.
— Wieś bała się głodu. Dałem im siebie. Potem dali mi imiona. Potem przestali pytać.
— A jeśli odmówię?
— Wtedy dzwon weźmie ciebie. Albo mnie. Albo nikogo — ale wieś umrze.
Antoni patrzy na Martę. — On nie kłamie. Ale nie mówi całej prawdy.

-> act3_final_choice

=== act3_final_choice ===
# location:I-4
# portrait:antoni
# music:tower_heart
Dzwon wisi nad nimi. W jego brązie odbija się cała wieś: domy, jezioro, las, ludzie, którzy nie patrzą.
Marta trzyma w dłoni głowę Szymona. Jest ciężka i ciepła, jakby jeszcze myślała.
Antoni stoi obok. Jego cień jest już prawie ludzki.
— Możesz przerwać — mówi. — Albo zająć moje miejsce. Obie drogi są prawdziwe.
Marta patrzy na dzwon. Dzwon patrzy na nią.
Po raz pierwszy od przyjazdu wieś jest cicha.

* [Przerwij dzwon i uwolnij zmarłych]
    -> ending_bell
* [Zajmij miejsce ojca i zamknij pakt]
    -> ending_silence
