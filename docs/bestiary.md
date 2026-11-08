# Trauma Village — Bestiariusz kaszubski

| Pole | Wartość |
|---|---|
| Wersja | 0.4 (Fala 1) |
| Data | 2026-11-07 |
| Właściciel | `writer` |
| Status | draft do review Pucka / Mariusza |
| Powiązane | `AGENTS.md`, `docs/GDD.md`, `docs/scope.md`, `docs/linia.md`, `story/outline.md`, `docs/bestiary-sources.md` (dziennik źródeł) |

> **Zasada nadrzędna.** W grze nie występuje żadna istota, której nazwa nie ma
> źródła w tym pliku. Nazwy, warianty i imiona NPC są zamknięte w tym dokumencie.
> Jeśli brakuje źródła — wpis dostaje znacznik **DO WERYFIKACJI** i nie wchodzi
> do dialogów produkcyjnych.

---

## 1. Jak czytać wpisy

Każdy wpis ma sześć pól:

1. **Nazwa i wymowa** — zapis kaszubski, przybliżenie polskie, IPA (orientacyjne).
2. **Źródło** — autor, tytuł, rok, strona albo link. Strona niepotwierdzona =
   **DO WERYFIKACJI**.
3. **Poświadczenie i zachowanie** — co mówią źródła, bez dopowiadania.
4. **Rola w grze** — funkcja mechaniczna/narracyjna i mapowanie na warianty
   A/B/C z `docs/GDD.md`.
5. **Zasady bezpieczeństwa kulturowego** — czego nie wolno zrobić z tą istotą.
6. **DO WERYFIKACJI** — konkretne luki do domknięcia przed pionem produkcyjnym.

**Skróty:** kasz. — kaszubski; pol. — polski; s. — strona; mp. — miejsce
publikacji; b.d. — brak danych.

**Skala ocen źródeł** (pełne uzasadnienie w `docs/bestiary-sources.md`):
**PRIMARY** — tekst źródłowy ze stroną; **SECONDARY** — cytat lub strona za
opracowaniem; **LIST-LEVEL** — sama nazwa na liście; **GAP** — szukane, nie
znaleziono; **INVENTION** — wynalazek gry. Opisy za A. Labudą są SECONDARY
nawet ze stroną, bo Labuda to rekonstrukcja literacko-etnograficzna.

---

## 2. Zasady bezpieczeństwa kulturowego (obowiązują wszystkie wpisy)

1. **Nie zmywamy demonów.** Wolno wymyślać fabułę, NPC, wieś i rytuał gry.
   Nie wolno wymyślać nazw istot ani przypisywać im cech „bo tak pasuje”.
2. **Rozdzielamy etnografię od fikcji.** Bestiariusz opisuje źródła. Fabuła
   (pakt wsi, dzwon, ofiara co siedem lat, rodzina Kreftów) jest **inwencją gry**
   i musi być tak oznaczona w materiałach prasowych i w grze — np. w dokumencie
   „Nota badawcza” albo w credits.
3. **Nie robimy z Kaszubów „dzikiego ludu”.** Wiara w duchy współistniała
   z katolicyzmem, nie zamiast niego. Kaszubi w grze mają być konkretni,
   nowocześni (2026: smartfon, używane auto, internet na wsi), a nie kostiumowi.
4. **Nie przenosimy odpowiedzialności na ofiarę.** Historyczne praktyki
   (np. odcinanie głowy zmarłemu) pokazujemy jako lęk i bezradność społeczności,
   nie jako „sprawiedliwy rytuał” do naśladowania.
5. **Realna wieś, fikcyjny pakt.** Akcja dzieje się w Lini (powiat wejherowski).
   Pakt, dzwon z 1898 r., rodzina Kreftów i rytuał są wymyślone. Nigdzie nie
   sugerujemy, że mieszkańcy Lini lub Kaszubi praktykują opisane rzeczy; nota
   „co jest fikcją” jest w grze i w credits.
6. **Rétnik jest figurą, nie wrogiem.** W Lini stoi realna drewniana rzeźba
   Rétnika (Jan Redźko, według Aleksandra Labudy). W grze jest punktem
   orientacyjnym na placu i nie ożywa. Nie dostaje wariantu A/B/C.
   Szczegóły miejsca: `docs/linia.md`.
7. **Ortografia i wymowa.** Zapis kaszubski ma znaczenie. Przed nagraniem
   lektora lub publikacją dialogów wymagana konsultacja z osobą
   kaszubskojęzyczną. Wymowy w tym pliku są przybliżeniami.
8. **Brak egzotyzacji i straszenia „obcością”.** Kaszubszczyzna jest językiem
   społeczności, nie klątwą. Postacie mówią po polsku z kaszubskimi wstawkami
   świadomie i oszczędnie (patrz `story/README.md` §7).
9. **Wrażliwość na przemoc.** Wieszczy w źródłach wiąże się z realnym
   bezczeszczeniem zwłok. W grze pokazujemy skutek (strach, cisza, zniszczona
   mogiła), nie instrukcję ani widowiskową pornografię grozy.
10. **Wynalazek oznaczamy.** Zachowanie, mechanikę albo zwyczaj, których nie ma
    w źródle (np. „nie patrz”, ofiara chleba i soli, rozwiązanie zagadki),
    wpisujemy do §4 jako **INVENTION**. Nie podajemy ich jako folkloru.

---

## 2.1 Rodzaje istot w grze (propozycja v0.2)

| Rodzaj | Co to jest | Walka | Istoty |
|---|---|---|---|
| **Wróg** | jedyny typ z AI, 14 instancji, 3 warianty | tak | A — wieszczy (Głodny), B — Ópi (§3.10), C — Stary (§3.1) |
| **Demon-spotkanie** | jednorazowy demon; wydarzenie rozwiązywane mechaniką (mruganie, światło, dźwięk, przedmiot) | **nie**, bez HP | Pólnica, Mòra, Nëczk |
| **Duch opiekuńczy** | dobry duch; udobruchany zagadką lub przedmiotem toruje drogę albo otwiera ukrytą niszę | nie | Krôsniãta, Bòrowô Cotka, Grzenia |
| **Ambient** | element świata bez zachowania | nie | Stolemy, Rétnik |
| **Poza obsadą** | tylko wzmianka | nie | Bòrówc (LIST-LEVEL), Mùmôcz, Topielëca; **wycofany z v1: Pùrtk** (§3.4) |

**Proponowany rozkład na akty** (do decyzji Mariusza):

| Akt (faza) | Demon-spotkanie | Duch opiekuńczy |
|---|---|---|
| I (Dzień) | Mòra (ukrywa się we wsi) | Krôsniãta |
| II (Zmierzch) | Pólnica (lasy i pola) | Bòrowô Cotka (F1) |
| III (Noc) | Nëczk (L1) | Grzenia |

Zasady wspólne:

- **Demon-spotkanie nie ma HP.** Jest presją i zagadką, nie walką. Dlatego nie
  rusza ekonomii amunicji (GDD BAL-18/19/28).
- **Duch opiekuńczy jest ogniwem istniejących P1–P3 albo opcjonalnym dodatkiem
  do jednej z nich**; nie tworzy czwartej zagadki.
- **Nagroda za udobruchanie:** nisza (nie nowe wnętrze) z amunicją
  **przesuniętą z puli** (suma 44/10 bez zmian), jedną notatką fabularną i —
  najwyżej **raz w całej grze** — jednorazowym leczeniem.
- Dopasowanie do zakresu i wymiana pozycji: `docs/backlog.md` BL-25…BL-27.
  Dopóki Mariusz tego nie zatwierdzi, te zasady nie zmieniają `GDD.md` ani
  `scope.md`.

---

## 3. Wpisy

### 3.1 Wieszczy (Wieszczi)

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **wieszczy**; lm. **wieszczi** |
| Wymowa (przybliżenie) | **WIESZ-czy**; lm. **WIESZ-czi** |
| IPA (orientacyjne) | /ˈvjɛʂt͡ʂɨ/ |
| Warianty w grze | **A — Głodny**, **B — Ópi** (decyzja Mariusza 2026-11-07, dawniej „Dzwónnik”; §3.10), **C — Stary** |
| Źródło główne | A. Labuda, *Bògòwie i dëchë naj przodków*, Bolszewo 2008/2012 — **s. DO WERYFIKACJI** |
| Źródło uzupełniające | A. Młyńska, „Kaszubskie upiory, czyli czego bać się nocą na Kaszubach”, Histmag.org, 31.10.2011, CC BY-SA 3.0 |
| Źródło historyczne | *Niemcy o Kaszubach w XIX wieku*, red. J. Borzyszkowski, Gdańsk 2009, **s. 80** (cytat o wieszczym i dzwonach) |
| Źródło leksykalne | B. Sychta, *Słownik gwar kaszubskich na tle kultury ludowej*, t. 1–7, Wrocław 1967–1976 — t. VI, 1973, **s. 144** (hasło *wieszczi*, za csb Wikipedią — SECONDARY) |
| Źródło XIX w. | J. Łęgowski, *Kaszuby i Kociewie*, Poznań 1892, **s. 60, 65, 66** (SECONDARY, domena publiczna); A. Majkowski, *Zdroje Raduni*, Warszawa 1913, ok. s. 54 (PRIMARY, domena publiczna) |

**Poświadczenie i zachowanie (wg źródeł).**
Człowiek urodzony „w czepku” (w nienaruszonych błonach płodowych) miał po
śmierci stać się wieszczim. Wieszczy miał jeść własne ciało, potem krewnych,
a gdy zabrakło krewnych — iść do dzwonów kościelnych i bić w nie; wszystko,
co usłyszało dzwon, miało umierać. Aby temu zapobiec, praktykowano m.in.
czuwanie przy zmarłym („pusta noc”), wkładanie do trumny kartki bez „amen”,
maku, sieci lub cegieł, a w skrajnych przypadkach — odkopanie zwłok i
umieszczenie odciętej głowy między stopami. Ostatnie takie przypadki na
Kaszubach źródła datują na XIX wiek.

**Rola w grze.**
Jedyny typ wroga (`docs/GDD.md` §6.4), 14 instancji, bez respawnu:

- **Wariant A — Głodny.** Świeżo wzbudzony, szybki (2,8 m/s), chaotyczny;
  atakuje z głodu, nie z planu. Występuje w Dzień i Zmierzch.
- **Wariant B — Ópi** (§3.10). Gorszy od wieszczego; według Majkowskiego
  wstaje nocą, idzie do dzwonnicy i dzwoni. Blokuje korytarze i „nosi” dźwięk
  dzwonu. Występuje w Zmierzch i Noc.
- **Wariant C — Stary.** Szymon Kreft, pierwszy wieszczy wsi; wolny, ciężki,
  mówi i pamięta. Tylko Noc, finał.

Wieszczy jest **jednym typem wroga**, a nie trzema demonami. Warianty to stan
rozpadu/ wieku tej samej istoty. Mechaniczne profile: `docs/GDD.md` §6.4.

**Zasady bezpieczeństwa kulturowego.**
- Nie przedstawiamy wieszczego jako „kaszubskiego wampira” w sensie
  popkulturowym (kły, peleryna, romans). To istota głodu, ciała i dzwonu.
- Nie robimy z rytuału odcinania głowy „rozwiązania” bez konsekwencji.
  W finale jest to akt desperacji, nie triumf.
- Nie używamy realnych nazwisk ofiar z XIX-wiecznych relacji.
- Wariant C nie może brzmieć jak „mądry starzec”. Ma być zmęczoną, głodną
  pamięcią wsi.

**DO WERYFIKACJI.**
- Dokładna strona w Labudzie dla opisu wieszczego i „dzwonów”.
- Hasło i strona w Sychcie dla formy `wieszczi`.
- Czy forma „Wieszczi” jako lm. jest akceptowalna w kaszubszczyźnie
  współczesnej, czy lepiej używać opisowo „wieszczy” w l.mn.
- Konsultacja z native speakerem przed nagraniem wokalizacji.
- **Dzwon: wieszczy czy łópi?** Łęgowski (1892, s. 66) przypisuje dzwonienie
  wieszczemu („niełap/połap”), Majkowski (1913) — gorszemu od niego **łópiemu**.
  **Rozstrzygnięte (Mariusz, 2026-11-07):** wariant B to Ópi (§3.10). Wariant A
  zostaje wieszczym w stanie świeżym, C — Starym.
- Czuwanie „pusta noc” służy **wykryciu** budzenia się zwłok (Histmag), a nie
  jego zapobieganiu. Nie używamy go jako uzasadnienia mechaniki „patrzysz — stoi”.

---

### 3.2 Mòra (Zmora)

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **mòra**; pol. **zmora**; spotykane **mora** |
| Wymowa (przybliżenie) | **MWE-ra** (ò labializowane, jak w kasz. *bòk*) |
| IPA (orientacyjne) | /ˈmwɛra/ |
| Wariant w grze | **Demon-spotkanie** (Akt I, Dzień, ukrywa się we wsi — decyzja Mariusza 2026-11-07); poza tym zagrożenie nocne / presja, nie osobny typ wroga |
| Źródło główne | R. Ostrowska, I. Trojanowska, *Bedeker kaszubski*, Gdańsk 1978, **s. 238–239** |
| Źródło uzupełniające | A. Młyńska, „Kaszubskie upiory…”, Histmag.org, 31.10.2011 |
| Źródło leksykalne | J. Treder, *Kaszubi. Wierzenia i twórczość. Ze Słownika Sychty*, Gdańsk 2002 — **s. DO WERYFIKACJI** |
| Źródło leksykalne (hasło) | B. Sychta, t. III, 1969, **s. 102–105** (za csb Wikipedią — SECONDARY); W. Szulist, *Kaszubi kanadyjscy*, Gdańsk 1992, **s. 61** (wejście przez dziurkę od klucza) |

**Poświadczenie i zachowanie (wg źródeł).**
Mora to nocna dusicielka. Miała rekrutować się spośród kobiet — np. najmłodsza
lub najstarsza z siedmiu córek — i działać bez świadomości ciała: po zaśnięciu
opuszczać je i przybierać postać kota, psa, myszy, jabłka, gruszki, źdźbła
słomy, piasku, wiatru, a nawet toczącego się koła. Siadała na piersi śpiącego
i dusiła; męczyła też konie i krowy. Nie zabijała od razu — podduszanie bywało
jej „zabawą”. Obroną było zabezpieczenie drzwi i okien, ustawienie butów tak,
jakby właściciela nie było w łóżku, spanie na brzuchu (mora nie siada na
plecach) oraz złapanie jej w przedmiotowej postaci i zranienie — rana miała
odbić się na ciele kobiety, z której mora wyszła.

**Rola w grze.**
**Decyzja Mariusza 2026-11-07:** Mòra to demon-spotkanie **Aktu I (Dzień)**, ukrywa się we wsi.
Poniższy opis „efektu nocnego” pochodzi z v0.2 i **wymaga przepisania** pod Akt I
(dzień, wieś): jej obecność w dzień ma być ukryta (przedmiotowe postacie: kot, jabłko, źdźbło
słomy…), a nie nocnym duszeniem. Do uzgodnienia z Mariuszem przed pracą nad zagadkami.

Mòra nie jest drugim typem wroga (zakaz scope creep). Występuje jako:

- **efekt nocny w I-3, L1 i I-4:** ucisk na klatce piersiowej, krótkie
  „przebudzenia” z brakiem tchu, fałszywy obraz w lustrze;
- **narracyjny nacisk:** im mniej gracz wie o pakcie, tym częściej mora
  „siada” na ekranie (efekt audio-wizualny, nie walka);
- **ślad fabularny:** jedna z notatek w I-3 opisuje morę jako „tę, która
  wychodzi z człowieka”, co naprowadza Martę na mechanizm wieszczego.

**Zasady bezpieczeństwa kulturowego.**
- Nie czynimy z mory „seksualnego demona”. Źródła mówią o duszeniu i zmęczeniu,
  nie o erotyce.
- Nie używamy mory jako żartu ani „babskiej histerii”. To realny lęk nocny,
  opisywany przez kobiety i mężczyzn.
- Nie mieszamy jej z morą/zmorą ogólnosłowiańską bez przypisu. Jeśli używamy
  motywu spoza Kaszub, oznaczamy to w notatce.

**DO WERYFIKACJI.**
- Strona w Trederze/Sychcie dla mory.
- Czy w źródłach kaszubskich występuje wariant `mòra` vs `mora` — decyzja
  ortograficzna przed dialogami.
- Konsultacja: czy scena „duszenia” nie jest zbyt bliska realnemu paraliżowi
  semnemu; ewentualnie złagodzić w opcjach dostępności.

---

### 3.3 Bòrowô Cotka

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Bòrowô Cotka** („Borowa Matka/Ciotka”) |
| Wymowa (przybliżenie) | **bwo-RO-wo COT-ka** |
| IPA (orientacyjne) | /bwɔˈrɔvɔ ˈt͡sɔtka/ |
| Wariant w grze | **Przewodniczka / opiekunka lasu**, nie wróg |
| Źródło główne | Kaszëbskô Wikipedijô, „Bòrowô Cotka”, hasło oparte na opisie A. Labudy — link w §5 |
| Źródło uzupełniające | Kaszëbskô Jednota, „Mitologia kaszubska”, D. Szymikowski — link w §5 |
| Źródło literackie | H. Makurat, wiersz „wierzã w bòrową cotkã…”, *Testameńtë jimaginacji* — link w §5 |

**Poświadczenie i zachowanie (wg źródeł).**
Bòrowô Cotka to duch borów, siostra Bòrówca. Opiekuje się leśnymi zwierzętami,
ptakami i dobrymi ludźmi; chroni dzieci przed czarownicami i Maniewidem.
Kiedy rodzice idą przez las, daje dzieciom zabawki, bombki i orzechy. W
przysłowiach i mowach potocznych występuje jako „ta, od której dostaje się
orzechy” i „ta, co pasie zające i sarenki”. W kulturze współczesnej jej figury
stoją na szlaku „Poczuj kaszubskiego ducha” (m.in. Smażëno).

**Uwaga źródłowa (2026-11-07).** Opis (csb Wikipedia, wg Labudy, bez strony) mówi,
że Cotka **daje** dzieciom zabawki, bombki i orzechy. Nie znaleziono zwyczaju
składania jej ofiary (chleb, mleko, sól). Każda ofiara dla Cotki w grze jest
**INVENTION** (§4). Jej „test miłosierdzia” z §Rola w grze też jest fikcją gry.

**Rola w grze.**
Bòrowô Cotka jest **ambigwalną sojuszniczką** w F1 (ścieżka do chaty Jadwigi):

- testuje Martę, każąc jej wybierać między ocaleniem Ewy a ocaleniem wsi;
- jeśli Marta okaże miłosierdzie (`mercy`), daje jej **trzecią zwrotkę**
  rytuału i otwiera skrót przez las;
- nie walczy i nie zabija. Jej obecność jest dźwiękiem (trzask gałęzi,
  kołysanka bez słów) i światłem (latarnia z orzechowej łupiny).

Nie jest „bossem lasu”. Jest matką, która sprawdza, czy gracz nadaje się na
rodzica/opiekuna.

**Zasady bezpieczeństwa kulturowego.**
- Nie robimy z niej straszydła ani „wiedźmy z lasu”. W źródłach jest
  opiekunką, nie antagonistką.
- Nie seksualizujemy jej. „Cotka” to ciotka/matka, nie „leśna nimfa”.
- Nie mieszamy jej z rosyjską „Baba Jagą” ani słowiańską „Borową Babą” bez
  wyraźnego przypisu. To osobna, kaszubska postać.
- Jej test nie może promować przemocy wobec dzieci. Wręcz przeciwnie —
  nagradza ochronę Ewy.

**DO WERYFIKACJI.**
- Dokładna strona u Labudy dla opisu Bòrowi Cotczi.
- Czy w źródłach XIX-wiecznych (Ceynowa, Łęgowski) postać występuje, czy jest
  głównie rekonstrukcją Labudy — to wpływa na to, jak mocno można ją
  „historyzować” w grze.
- Konsultacja z native speakerem: czy zdrobnienie „Cotka” jest właściwe w
  dialogu, czy lepiej „Bòrowô Matka”.

---

### 3.4 Pùrtk — WYCOFANY z v1

> **Decyzja Mariusza (2026-11-07): Pùrtk nie występuje w grze.** Wpis zostaje
> jako zapis ustaleń źródłowych, żeby nie wracać do tej samej pracy.

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Pùrtk**; spotykane **Purtk** |
| Status | **wycofany** — nie ma wariantu, roli ani dialogu w v1 |
| Ustalenia źródłowe | Jedna z ludowych nazw diabła (obok Biésa, Kóbla, Kùdiôbła, Kùki) wg Kaszëbskô Jednota — LIST-LEVEL. Opis „duch swarów, smrodu i głupoty” pochodzi z rekonstrukcji Labudy; historyczność postaci jest **kontrowersyjna** (przypis w haśle Wikipedii „Pùrtk”). |
| Powód | decyzja projektowa; dodatkowo słabe oparcie źródłowe (jedna linijka, rekonstrukcja) |

**Odwołania do posprzątania** (stan na 2026-11-07; nie zmieniane, czekają na
decyzję o zastępstwie funkcji — patrz `story/` i `docs/level-bible.md`):
`story/act1.ink` (scena `act1_mill_purtk`), `story/main.ink` (`purtk_bargain`),
`story/outline.md`, `story/README.md`, `docs/level-bible.md` (beat 5, I-2),
`docs/GDD.md` (§6.4, §6.8, §13 pkt 9), `docs/acceptance.md` (FG-F03),
`docs/night-state.md` (sworzeń „docelowo daje go Pùrtk”).

---

### 3.5 Stolem (Stolemë)

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **stolem**; lm. **stolemë** |
| Wymowa (przybliżenie) | **STO-lem**; lm. **sto-LE-me** |
| IPA (orientacyjne) | /ˈstɔlɛm/; /stɔˈlɛmɛ/ |
| Wariant w grze | **Krajobraz / mit założycielski**, nie wróg |
| Źródło główne | T. Bolduan, *Nowy Bedeker Kaszubski*, Gdańsk 1997; R. Ostrowska, I. Trojanowska, *Bedeker kaszubski*, Gdańsk 1978 — **s. DO WERYFIKACJI** |
| Źródło uzupełniające | Kaszëbskô Jednota, „Mitologia kaszubska”; Wikipedia „Stolemy” — linki w §5 |
| Źródło akademickie | A. Kuik-Kalinowska, *Stolemy. Kamienie w świecie literackiej wyobraźni Kaszub* — **s. DO WERYFIKACJI** |

**Poświadczenie i zachowanie (wg źródeł).**
Stolemy to olbrzymy z kaszubskich legend, które przed wiekami miały zamieszkiwać
Kaszuby. Ich istnienie tłumaczy się głazami narzutowymi, ukształtowaniem
krajobrazu i frazeologią (np. „chłopisko stolemnego rostu”). Współcześnie
„Stolem” to także tytuł honorowy (Medal Stolema Klubu Pomorania, od 1967 r.),
więc nazwa ma drugie, żywe znaczenie kulturowe.

**Rola w grze.**
Stolemy są **mitem krajobrazowym Kaszub**, a w grze punktem orientacyjnym w Lini:

- wielkie głazy w F2 i nad L1 mają być „kośćmi Stolemów” — punkt orientacyjny
  i zagadka środowiskowa;
- w I-3 (szkoła) dziecięca wycieczka zostawiła rysunek Stolema, który pomaga
  odczytać układ kamieni;
- w finale (I-4) jeden z głazów jest **sercem dzwonu** — nie jako magiczny
  przedmiot, ale jako element konstrukcji (kamień w fundamentcie wieży).

Stolemy nie pojawiają się jako żywe postacie. Ich „obecność” to skala,
kamień i opowieść. To oszczędza rig, AI i budżet.

**Zasady bezpieczeństwa kulturowego.**
- Nie robimy ze Stolemów „głupich trolli”. W źródłach to olbrzymy
  krajobrazotwórcze, nie monster-of-the-week.
- Nie mieszamy ich z `Stolem` jako medalem/klubem w sposób, który ośmiesza
  wyróżnienie. W grze może paść żart, ale nie drwina z ludzi.
- Nie przypisujemy im kultu religijnego bez źródła. Są legendą, nie bóstwem.
- Nie używamy ich do usprawiedliwienia „przeklętej ziemi”. Kaszuby nie są
  przeklęte; przeklęta jest konkretna decyzja ludzi.

**DO WERYFIKACJI.**
- Strony w Bolduanie i Bedekerze dla Stolemów.
- Strona w Kuik-Kalinowskiej.
- Czy w kaszubszczyźnie poprawna jest forma `stolemë` czy `stolemi` —
  decyzja przed dialogami.
- Konsultacja: czy wykorzystanie głazów jako „kości” nie koliduje z lokalnymi
  legendami o konkretnych głazach; unikać realnych nazw.

---

### 3.6 Pólnica

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Pólnica** |
| Wymowa (przybliżenie) | **DO WERYFIKACJI** |
| Wariant w grze | **Demon-spotkanie** (Akt II, Zmierzch, lasy i pola — decyzja Mariusza 2026-11-07), nie wróg |
| Źródło główne | A. Labuda, *Bògòwie i dëchë naj przodków*, Bolszewo–Wejherowo 2008/2011/2012 — **bez strony**, za csb.wikipedia.org/wiki/Pólnica (SECONDARY) |
| Źródło leksykalne | B. Sychta, *Słownik gwar kaszubskich…*, t. IV, 1970, **s. 122** (za csb Wikipedią — SECONDARY) |

**Poświadczenie i zachowanie (wg źródeł).**
Żeński duch, który „dzejô le dëcht latem”. Przedstawiana jako smukła, piękna
postać z wiankiem z kwiatów na głowie, jadąca na zwierzęciu („szëmel”) przez pola.
Kto choćby raz ją ujrzy, jest „ùrzekłi” (urzeczony, przeklęty) i usycha z
nieszczęśliwej miłości. Powiedzenia: „Pólnica gò mô ùrzekłé.”; „Lôtô za tim
dzewusem jak za taką Pólnicą.” To nie jest atak fizyczny: zagrożeniem jest
samo ujrzenie.

**Rola w grze.**
- Demon-spotkanie bez HP; nie atakuje i nie ściga.
- Zagrożeniem jest **spojrzenie**. Rozwiązanie opiera się na **mruganiu**
  (zamknięciem oczu w odpowiednich momentach gracz mija ją bez „ujrzenia”).
- **INVENTION:** źródła mówią, że zobaczenie szkodzi; nie mówią „nie patrz” ani
  „zamknij oczy”. Motyw spojrzenia jest źródłowy, nakaz nie.

**Zasady bezpieczeństwa kulturowego.**
- Źródło opisuje ją jako nagą. W grze **bez nagości i bez seksualizacji**:
  sylwetka, światło, wianek. To tęsknota i urzeczenie, nie erotyka.
- Nie mieszamy z ogólnosłowiańską Południcą (groźny demon południa, upiór,
  łamie kości, dusi, zadaje zagadki). Kaszubska Pólnica jest piękna i sprzyja
  polom. Jeśli kiedykolwiek użyjemy motywu południcy, oznaczamy go w notatce.
- Nie robimy z niej potwora ani „zjawy z horroru”.

**DO WERYFIKACJI.**
- Zwyczaj ochronny — **GAP** (nie znaleziono).
- Rodzaj i maść „szëmla”, na którym jedzie.
- Sezon: akcja dzieje się na przełomie sierpnia i września (Mariusz, 2026-11-07), czyli
  pod koniec lata. Pasuje do „dzejô le dëcht latem”, ale na granicy; do skonsultowania.
- Wymowa; strony u Labudy; druk Sychty.

---

### 3.7 Nëczk

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Nëczk** |
| Wymowa (przybliżenie) | **DO WERYFIKACJI** |
| Wariant w grze | **Demon-spotkanie** (Akt III, Noc, L1 — propozycja), nie wróg |
| Źródło główne | csb.wikipedia.org/wiki/Nëczk (opis wg Labudy) — **bez przypisów i stron** (SECONDARY) |

**Poświadczenie i zachowanie (wg źródeł).**
Duch wodny „niżészigò szlachù”, sprawca „niewezpiecznëch wodnëch krãcëszków”
(niebezpiecznych wirów). Mieszka w morzach, jeziorach i rzekach; jest sługą
Òmańca. Powiedzenia: „Wej, jak Nëczk wodã miele!”; „W tim jezorze Nëczk wcygô
lëdzy w swòje ledło.”; „Niech ce Nëczk wcygnie w tã przepadniã!” Figura szlaku
„Poczuj Kaszubskiego Ducha” stoi w Niepoczołejcach, nad jeziorem w gminie Linia.

**Rola w grze.**
- Demon-spotkanie bez HP przy brzegu jeziora (L1) w Nocy.
- Zagrożeniem są **wiry i wciąganie**; sam Nëczk nie goni gracza.
- **INVENTION:** konkretna mechanika rozwiązania. Źródła dają tylko wiry i
  wciąganie.

**Zasady bezpieczeństwa kulturowego.**
- Nie robimy z niego wodnika-potwora z kłami; źródło opisuje duch „niższego
  rzędu”, nie bossa.
- Òmańc jest tylko wzmianką (LIST-LEVEL). Nie wprowadzamy go jako postaci.
- Nie używamy nazw realnych jezior ani miejsc figur (V-09).

**DO WERYFIKACJI.**
- Zachowanie poza wirami — **GAP**.
- Znaczenie przymiotnika „mërawi”; wymowa; strona u Labudy.

---

### 3.8 Krôsniãta

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **krôsniãta** |
| Wymowa (przybliżenie) | **DO WERYFIKACJI** |
| Wariant w grze | **Duch opiekuńczy** (Akt I — propozycja), nie wróg |
| Źródło główne | B. Sychta, t. II, 1968, **s. 236–238** (za csb Wikipedią — SECONDARY) |
| Źródło uzupełniające | A. Majkowski, *Zdroje Raduni*, Warszawa 1913, ok. s. 50 (PRIMARY, domena publiczna) |

**Poświadczenie i zachowanie (wg źródeł).**
Domowe duchy („podziemne karzełki” u Majkowskiego). Dobrze traktowane pomagały:
zostawiano im na kominku **garnuszek mleka**; porządkowały izby, pomagały przy
chlebie, skrobaniu bulw i dojeniu krów. Źle traktowane — chorowały domowników
i miały podmieniać niemowlęta. Przed podmianą chroniono noworodka **szkaplerzem**
zawieszonym na szyi do chrztu.

**Rola w grze.**
- Duch opiekuńczy: **mleko w garnuszku na kominku** to jedyny poświadczony dar
  (INVENTION dotyczy tylko tego, co gracz dostaje w zamian).
- Ogniwo P1 albo opcjonalna nisza z amunicją, notatką i, raz w grze, leczeniem.

**Zasady bezpieczeństwa kulturowego.**
- Nie używamy podmiany niemowlęcia jako straszaka ani sceny.
- Nie robimy z nich „sympatycznych skrzatów” ani Kłobuka; źle traktowane są
  groźne.
- Nie dopisujemy im darów spoza źródła (chleb, sól — **GAP**).

**DO WERYFIKACJI.**
- Wymowa; druk Sychty (t. II); tekst dosłowny Majkowskiego ze skanu.

---

### 3.9 Grzenia

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Grzenia** |
| Wymowa (przybliżenie) | **DO WERYFIKACJI** |
| Wariant w grze | **Duch opiekuńczy** (Akt III — propozycja), nie wróg |
| Źródło główne | B. Sychta, t. I, 1967, **s. 379** (za csb Wikipedią — SECONDARY) |

**Poświadczenie i zachowanie (wg źródeł).**
„Strogòtlëwi duch i ògradzan spikù i snicô” — opiekun snu i marzeń. Zaprasza
zmęczonych do snu i budzi śpiących zbyt długo. Formuły ludowe: „Mùszã jic spac, bò
Grzenk sã ju do mie mô.”; „Grzenia mie tłëcze, jidã so spac.”; „Grzenk cë ju piôsk
w òczka sëpie!”. Figura szlaku stoi w Strzepczu.

**Rola w grze.**
- Duch opiekuńczy przywoływany **formułą**, nie darem (nie ma dowodu na ofiarę).
- **INVENTION:** zestawienie Grzeni z Mòrą jako opiekuna snu w kontrze do dusicielki
  (obserwacja gry, nie źródło).

**Zasady bezpieczeństwa kulturowego.**
- Nie dopisujemy ofiary (chleb, mleko) bez źródła — **GAP**.
- Scena snu nie powinna naśladować paraliżu sennego w sposób raniący (V-08).

**DO WERYFIKACJI.**
- Wymowa; druk Sychty (t. I); znaczenie „strogòtlëwi”.

---

### 3.10 Ópi (łópi)

| Pole | Wartość |
|---|---|
| Nazwa kaszubska | **Ópi** (forma współczesna, Kaszëbskô Jednota; przyjęta przez Mariusza 2026-11-07); **łópi** u Majkowskiego (1913) |
| Wymowa (przybliżenie) | **DO WERYFIKACJI** |
| Wariant w grze | **B — wróg**, Akt II–III (decyzja Mariusza 2026-11-07) |
| Źródło główne | A. Majkowski, *Zdroje Raduni*, Warszawa 1913, ok. s. 54 druku (k. 60 skanu) — PRIMARY, domena publiczna; treść potwierdzona, dosłowność cytatu niepotwierdzona |
| Źródło uzupełniające | Kaszëbskô Jednota, „Mitologia kaszubska”: Ópi jako gorszy krewny wieszczego, który „bierze lëdzy jak mór i chëra” — LIST-LEVEL z jednym zdaniem opisu |

**Poświadczenie i zachowanie (wg źródeł).**
Majkowski (pisze „łópi”) nazywa go **gorszym jeszcze od wieszczego**. Taki nocą wstaje z
grobu, idzie do dzwonnicy i dzwoni; jak daleko dosięga głos dzwonów, ludzie
giną gromadami. (Łęgowski, 1892, s. 66, przypisuje to samo dzwonienie wieszczemu,
zwanemu „niełap/połap” — relacje nie są jednolite, patrz `bestiary-sources.md` §8.)

**Rola w grze.**
- Wariant B jedynego typu wroga: ta sama istota co A i C w gorszym stanie.
  Drabina z źródeł: wieszczy (A, świeży) → Ópi (B, dzwon) → Stary (C, Szymon
  Kreft — fikcja gry).
- Blokuje korytarze i „nosi” dźwięk dzwonu; dzwon jest jego znakiem.
- **Ruch tylko niewidziany** (zatwierdzone przez Mariusza 2026-11-07, GDD §6.4,
  BAL-56): nie porusza się i nie atakuje, gdy gracz go widzi; mruganie jest oknem
  ruchu. **INVENTION** — źródła mówią o dzwonieniu z dzwonnicy, nie o spojrzeniu.
  Opisane też w `story/act3.ink` (`act3_open`).

**Zasady bezpieczeństwa kulturowego.**
- Nie przedstawiamy go jako popkulturowego wampira.
- Zbiorowa śmierć od dźwięku dzwonu pokazujemy jako **ciszę i skutek**, nie
  widowisko.
- Nie używamy realnych nazwisk ofiar.

**DO WERYFIKACJI.**
- Wymowa (pisownia ustalona: Ópi).
- Dosłowny tekst Majkowskiego ze skanu (Wikiźródła, `Strona:Zdroje_Raduni.djvu/60`).
- Czy w innych źródłach łópi jest istotą osobną, czy jedynie nazwą wieszczego
  „w gorszym stanie”.

---

## 4. Granica fikcji — czego **nie** ma w źródłach

Poniższe elementy są **wymyślone na potrzeby gry** i nie mogą być prezentowane
jako kaszubski folklor:

| Element gry | Status | Uwaga |
|---|---|---|
| Wieś **Linia** | realna miejscowość | akcja gry; pakt, dzwon i rodzina są fikcją |
| Rodzina **Kreftów** i dziedziczny urząd dzwonnika | fikcja | literatura, nie etnografia |
| **Pakt wsi** — ofiara co siedem lat, imię podawane dzwonowi | fikcja | nie ma źródła; to horrorowa metafora współwiny |
| **Dzwon z 1898 r.** i jego „serce” | fikcja | inspiracja realnymi dzwonami, ale konkretny obiekt jest wymyślony |
| **Szymon Kreft** jako pierwszy wieszczy | fikcja | imię i biografia wymyślone |
| **Rytuał trzech zwrotek** | fikcja | forma literacka, nie cytat z pieśni ludowej |
| **Marta Kreft** jako „dziecko w czepku” | fikcja | wykorzystuje motyw źródłowy, ale konkretna postać jest wymyślona |
| **Demon-spotkanie bez HP** jako format | INVENTION (struktura gry) | źródła opisują demony przez skutki dla ludzi; walka z nimi nie jest poświadczona |
| **Mruganie / „nie patrz”** przy Pólnicy | INVENTION | motyw spojrzenia jest źródłowy („ùrzekłi”), nakaz „nie patrz” nie |
| **Rozwiązanie** zagadki z Nëczkiem | INVENTION | źródło daje tylko wiry i wciąganie |
| **Ofiary** dla Bòrowi Cotki, Bòrówca, Grzeni (np. chleb, sól) | INVENTION | Cotka w źródłach **daje**; jedyny poświadczony dar to mleko dla krôsniąt |
| **Grzenia jako przeciwwaga Mòry** | INVENTION | obserwacja gry |
| **Ukryta nisza** (amunicja, notatka, raz leczenie) | struktura gry | nagroda, nie folklor |
| **Ópi jako wariant B** zamiast „Dzwónnika” | decyzja projektowa | źródło: Majkowski 1913 (łópi gorszy od wieszczego); drabina A→B→C jest interpretacją gry |
| **Ópi rusza się tylko, gdy gracz go nie widzi** (`story/act3.ink`; zatwierdzone 2026-11-07) | INVENTION | źródła: dzwonienie z dzwonnicy, nic o spojrzeniu; mruganie jest oknem na jego ruch |

W grze muszą pojawić się co najmniej dwa nośniki rozróżnienia: nota badawcza
w I-3 oraz wpis w credits/ekranie końcowym. Nie wystarczy „inspirowane
folklorem” w opisie Steam.

---

## 5. Bibliografia i linki

### Źródła podstawowe (książkowe)

- Labuda A., *Bògòwie i dëchë naj przodków (przëłożënk do kaszëbsczi mitologii)*,
  red. B. i J. Labudda, Bolszewo 2008 (wyd. 2012).
- Labuda A., *Bogowie i duchy naszych przodków. Przyczynek do kaszubskiej
  mitologii*, Katowice 2011.
- Sychta B., *Słownik gwar kaszubskich na tle kultury ludowej*, t. 1–7,
  Wrocław 1967–1976.
- Treder J., *Kaszubi. Wierzenia i twórczość. Ze Słownika Sychty*, Gdańsk 2002.
- Ostrowska R., Trojanowska I., *Bedeker kaszubski*, Gdańsk 1978.
- Bolduan T., *Nowy Bedeker Kaszubski*, Gdańsk 1997.
- Łęgowski J. (Nadmorski), *Kaszuby i Kociewie. Język, zwyczaje, przesądy,
  podania, zagadki i pieśni ludowe w północnej części Prus Zachodnich*,
  Poznań 1892.
- *Niemcy o Kaszubach w XIX wieku*, red. J. Borzyszkowski, Gdańsk 2009.
- Ceynowa J., *Dobro zwycięża. Legendy z Kaszub i Pomorza*, Gdańsk 1985.
- Majkowski A., *Zdroje Raduni*, Warszawa 1913 (domena publiczna; Wikiźródła).
- Szulist W., *Kaszubi kanadyjscy*, Gdańsk 1992.
- Hilferding A., *Resztki Słowian na południowym wybrzeżu Morza Bałtyckiego*,
  tłum. N. Perczyńska, oprac. J. Treder, Gdańsk 1989.
- Pełny dziennik dowodów z ocenami: `docs/bestiary-sources.md`.
- Kuik-Kalinowska A., *Stolemy. Kamienie w świecie literackiej wyobraźni
  Kaszub*, Gdańsk–Słupsk (rok do potwierdzenia).

### Źródła online (zweryfikowane 2026-10-29)

- Kaszëbskô Jednota, „Mitologia kaszubska”, autor: Dariusz Szymikowski,
  https://kaszebsko.com/mitologia-kaszubska
- A. Młyńska, „Kaszubskie upiory, czyli czego bać się nocą na Kaszubach”,
  Histmag.org, 31.10.2011, CC BY-SA 3.0,
  https://histmag.org/Kaszubskie-upiory-czyli-czego-bac-sie-noca-na-Kaszubach-6050
- Kaszëbskô Wikipedijô, „Bòrowô Cotka”,
  https://csb.wikipedia.org/wiki/B%C3%B2row%C3%B4_Cotka
- Wikipedia, „Pùrtk”,
  https://pl.wikipedia.org/wiki/P%C3%B9rtk
- Wikipedia, „Stolemy”,
  https://pl.wikipedia.org/wiki/Stolemy
- H. Makurat, „wierzã w bòrową cotkã…”, Skarbnica Kaszubska,
  http://skarbnicakaszubska.pl/wiersze

### Źródła odrzucone lub wymagające ostrożności

- Blogi i „bestiariusze” bez bibliografii — dopuszczalne wyłącznie jako
  trop, nie jako przypis.
- Popularne opracowania łączące Kaszuby z „mitologią słowiańską” bez
  rozróżnienia regionalnego — nie używamy bez oznaczenia.
- Tłumaczenia AI i streszczenia bez autora — nie używamy.

---

## 6. Zbiorcza lista DO WERYFIKACJI

| # | Element | Co trzeba domknąć | Priorytet |
|---|---|---|---|
| V-01 | Wieszczy | strony u Labudy, Sychty; status lm. `wieszczi` | P0 |
| V-02 | Mòra | strona u Tredera/Sychty; wariant zapisu `mòra/mora` | P0 |
| V-03 | Bòrowô Cotka | strona u Labudy; źródła XIX-wieczne vs rekonstrukcja | P1 |
| V-04 | Pùrtk | **wycofany z v1** (Mariusz, 2026-11-07) — zamknięte | — |
| V-05 | Stolem | strony w Bolduanie/Bedekerze; lm. `stolemë/stolemi` | P1 |
| V-06 | Wymowy | konsultacja z native speakerem przed lektorem | P0 |
| V-07 | Nota fikcji | tekst noty „co jest fikcją” do I-3 i credits | P0 |
| V-08 | Wrażliwość | scena duszenia/mory a paraliż senny — review | P1 |
| V-09 | Nazwa wsi | Linia jest realna; sprawdzić, czy gra nie sugeruje, że mieszkańcy praktykują pakt, i uzgodnić pisownię z gminą | P0 |
| V-10 | Prawa | cytaty z Labudy/Sychty — sprawdzić zakres cytowania | P0 |
| V-11 | Pólnica | zwyczaj ochronny (GAP), maść „szëmla”, wymowa; sezon: **przełom sierpnia i września** (koniec lata, na granicy „latem”) | P0 |
| V-12 | Ópi | wymowa, dosłowny tekst Majkowskiego; pisownia i dzwon rozstrzygnięte: **wariant B = Ópi** | P0 |
| V-13 | Labuda | wszystkie opisy „za Labudą” bez stron; to rekonstrukcja | P0 |
| V-14 | Sychta, Łęgowski | strony z cytowań (Wikipedia); sprawdzić w druku lub skanie | P0 |
| V-15 | Ofiary | brak poświadczonych ofiar dla Cotki, Bòrówca, Grzeni | P1 |

---

## 7. Kontrakt dla pozostałych agentów

- **`writer`** może używać wyłącznie nazw i cech z §3. Nowa istota = nowy wpis
  z źródłem, nie „lore” w dialogu.
- **`level-designer`** dostaje z tego pliku: warianty wroga (A/B/C), miejsca
  występowania (Wieszczy), oraz listę istot, których **nie** wolno stawiać
  jako wrogów (Mòra, Bòrowô Cotka, Stolem, Pólnica, Nëczk, Krôsniãta,
  Grzenia; Pùrtk wycofany z v1). Pólnica, Mòra i Nëczk to **demony-spotkania bez HP** (§2.1).
- **`programmer`** implementuje **jeden typ wroga** z trzema profilami;
  Mòra to efekt/ambient, nie AI.
- **`artist`** nie generuje „konceptów” istot spoza tego pliku. Każdy asset
  z istotą ma wpis w `art/manifest.json` i odniesienie do tego dokumentu.
- **`game-designer`** może zmienić liczby, nie nazwy. Zmiana nazwy = zmiana
  tego pliku przez `writer` + review.

---

## 8. Historia zmian

| Wersja | Data | Zmiana | Autor |
|---|---|---|---|
| 0.1 | 2026-10-29 | Pierwszy bestiariusz: 5 istot, źródła, zasady, granica fikcji | `writer` |
| 0.2 | 2026-11-07 | Rodzaje istot (§2.1), nowe wpisy Pólnica/Nëczk/Krôsniãta/Grzenia, dowody dla wieszczego/mòry/Cotki, nowe wiersze §4 i §6, dziennik źródeł | Claude + Mariusz |
| 0.3 | 2026-11-07 | Pùrtk wycofany (§3.4); wariant B = łópi (§3.10); sezon akcji: przełom sierpnia i września | Claude + Mariusz |
| 0.4 | 2026-11-07 | Pisownia **Ópi** (forma współczesna); ruch tylko niewidziany zatwierdzony (BAL-56); oczyszczenie historii i GDD z Pùrtka | Claude + Mariusz |
