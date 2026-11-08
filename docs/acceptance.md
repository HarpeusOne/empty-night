# Trauma Village — Kryteria akceptacji

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Właściciel | `game-designer` |
| Dotyczy | `docs/GDD.md` v0.1, `docs/scope.md` v0.1, `docs/day-night.md` v0.1 |

**Zasada:** każde kryterium jest mierzalne i ma metodę weryfikacji. Sformułowania
„działa dobrze”, „płynnie”, „ładnie wygląda” są **niedopuszczalne** w review —
jeśli nie da się tego zmierzyć, kryterium nie istnieje.

---

## 0. Metody weryfikacji

| Kod | Metoda | Kto uruchamia | Artefakt |
|---|---|---|---|
| **TH** | test headless Godot (`--headless --script res://tests/…`) | `programmer` | log testu, exit code 0 |
| **AU** | skrypt automatyczny (licznik stringów, parzystość PL/EN, licznik amunicji) | `programmer` | raport JSON |
| **PT** | ręczny playtest z pomiarem czasu i liczby śmierci | Mariusz / Pucek | wypełniony arkusz playtestu |
| **PR** | profilowanie (Godot profiler, monitor FPS, draw calls) | `programmer` | zrzut z profilera |
| **IV** | `python3 tools/ink_check.py` | `writer` | PASS/FAIL |
| **IN** | inspekcja plików/scen przez agenta | Pucek | notatka review |
| **LT** | test lokalizacji (przełączenie PL/EN, przegląd 100% stringów) | `writer` + Pucek | lista braków |

Każdy przebieg akceptacyjny zapisuje: wersję builda (commit-hash lub data),
sprzęt, sterownik, urządzenie wejścia.

---

## A. Vertical slice — VS-1 „Pierwsza ulica”

Zakres: ulica V1, plac SQ, wnętrze I-1, wejście do F1, faza Dnia + przejście
Dzień→Zmierzch. Czas: **20–25 min**. Wszystkie systemy w wersji finalnej.

### A.1 Funkcjonalne

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| VS-F01 | Start gry: tytuł → rozgrywka | ≤ 3 akcje UI, ≤ 20 s od uruchomienia | PT |
| VS-F02 | Kamera OTS nie przenika przez ściany I-1 | 0 przypadków w 5 min testu w I-1 | PT + IN |
| VS-F03 | Celowanie + strzał obiema broniami | 100 strzałów, 0 crashy, 0 błędów w logu | TH |
| VS-F04 | Rejestracja trafienia w nieruchomy cel z 10 m | 100/100 trafień (raycast, cel 1 m²) | TH |
| VS-F05 | Obrażenia broni zgodne z BAL-10/BAL-14 | pistolet = 25, strzelba = 60 (10×6) | TH |
| VS-F06 | HP wroga zgodne z BAL-20/BAL-21 | A: 2 strzały w tors; B: 4 strzały w tors | TH |
| VS-F07 | Zagadka P1 — łańcuch 3 przedmiotów | rozwiązanie w 6 ± 3 min, 0 utraconych przedmiotów | PT |
| VS-F08 | Zapis i odczyt na 2 świecach | 10 cykli save→load, stan 100% zgodny (HP, amunicja, plecak, faza, świece, wrogowie, drzwi, zagadki, NPC); 3 próby przerwania zapisu wrogiem → 0 przerwań | TH |
| VS-F09 | Plecak 6 slotów | 6 przedmiotów wchodzi, 7. odrzucony z komunikatem | TH |
| VS-F10 | Sterowanie pada i klawiatury | pełne przejście slice na obu urządzeniach | PT |
| VS-F11 | Przełączenie PL↔EN | bez restartu, ≤ 2 s, 0 brakujących kluczy | LT + AU |
| VS-F12 | Pauza, alt-tab, powrót | brak utraty postępu, brak zawieszenia w 5/5 próbach | PT |
| VS-F13 | Przejście Dzień→Zmierzch | trigger P1; fallback 28 min od startu Aktu I wyłącznie po P1; czas 30 ± 3 s, gracz zachowuje kontrolę | TH + PT |
| VS-F14 | Leczenie przy świecy | HP 100 po interakcji z 1 HP | TH |
| VS-F15 | Śmierć i retry | powrót do ostatniego save'a w ≤ 6 s | PT |

### A.2 Wydajnościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| VS-P01 | FPS @1920×1080, preset „średni PC” (GTX 1050 / RX 570) | średnio ≥ 60, 1% low ≥ 45 | PR |
| VS-P02 | FPS na Steam Deck | ≥ 40, 1% low ≥ 30 | PR |
| VS-P03 | Draw calls w najgorszym kadrze (SQ w Zmierzchu) | ≤ 250 | PR |
| VS-P04 | Trójkąty w kadrze | ≤ 350 000 | PR |
| VS-P05 | Czas ładowania slice'a | ≤ 8 s SSD, ≤ 15 s HDD | PR |
| VS-P06 | Klatka podczas przejścia fazy | 0 klatek > 50 ms w 30 s przejścia | PR |
| VS-P07 | Pamięć procesu | ≤ 1,5 GB RSS | PR |
| VS-P08 | Podmiana `PhaseProfile` | ≤ 200 ms, bez przeładowania sceny | PR + IN |
| VS-P09 | Latencja wejścia (pad, 60 FPS) | ≤ 100 ms do ruchu na ekranie | PR |

### A.3 Narracyjne / treściowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| VS-N01 | Walidator Ink | PASS (`tools/ink_check.py`) | IV |
| VS-N02 | Placeholdery w tekście | 0 wystąpień `TBD`, `Lorem`, `XXX` w stringach widocznych graczowi | AU |
| VS-N03 | Parzystość PL/EN | 100% kluczy, 0 pustych tłumaczeń | AU |
| VS-N04 | Dokumenty w slice | ≥ 4 czytelne notatki | IN |
| VS-N05 | NPC w slice | 1 (NPC-1), dialog kompletny, ≥ 2 węzły wyboru | IN + PT |
| VS-N06 | Folklor | 100% nazw ma wpis w `docs/bestiary.md`; 0 nazw wymyślonych | IN |
| VS-N07 | Tekst nie wychodzi poza ekran przy 640×480 | 0 przycięć na 100% stringów UI | LT |
| VS-N08 | Czas czytania | żaden napis nie znika przed 3,5 s | TH + IN |

### A.4 Jakościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| VS-Q01 | Błędy blokujące (crash, softlock, brak progresji) | **0** | PT |
| VS-Q02 | Błędy nieblokujące znane i zalogowane | ≤ 10, każdy z krokiem reprodukcji | IN |
| VS-Q03 | Ciągłe przejście slice'a | 3/3 przebiegi po 20–25 min bez crasha | PT |
| VS-Q04 | Softlock | 0 w 10 przebiegach (w tym celowe próby) | PT |
| VS-Q05 | Czytelność wroga w Zmierzchu (faza na końcu VS) | gracz rozpoznaje wroga z ≥ 14 m | PT |
| VS-Q06 | Odczucie „ta sama przestrzeń, inny nastrój” | 3/3 testerów rozpoznaje SQ, ale ocenia nastrój jako inny | PT (ankieta 1–5, próg ≥ 4) |
| VS-Q07 | Sterowanie — subiektywna ocena | ≥ 4/5 w ankiecie (skala 1–5) | PT |

### A.5 Definition of Done — VS-1

- [ ] Wszystkie VS-F, VS-P, VS-N, VS-Q na zielono lub jawnie odstąpione przez Mariusza.
- [ ] `python3 tools/ink_check.py` → PASS.
- [ ] Test headless VS przechodzi w CI lokalnym (exit 0).
- [ ] Build uruchamia się na Windows i Linux bez dodatkowych zależności.
- [ ] Zapis VS jest w formacie docelowym (nie tymczasowym).
- [ ] Playtest Mariusza: 20–25 min, ≤ 4 śmierci, brak wrażenia „walksimulator”.
- [ ] Wszystkie stałe BAL użyte w VS są zgodne z `GDD.md` §10 (test porównuje wartości).

---

## B. Pełna gra (v1.0)

### B.1 Funkcjonalne

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| FG-F01 | Kompletność zawartości | 11 stref, 4 wnętrza, 2 korytarze, brzeg, 4 NPC, 3 zagadki | IN |
| FG-F02 | Przejścia faz | 2 przejścia (Dzień→Zmierzch 30 s, Zmierzch→Noc 45 s), 0 powrotów | TH + PT |
| FG-F03 | Wrogowie | 14 instancji (4 A / 6 B / 4 C), 0 respawnu; po loadzie stan wrogów zgodny z zapisem; 0 dodatkowych typów wroga (Mòra/Bòrowô Cotka/Stolem/Pólnica/Nëczk/Krôsniãta/Grzenia nie są wrogami) | TH |
| FG-F04 | Amunicja w świecie | suma 44 pistolet / 10 strzelba, rozkład 14/16/14 i 0/6/4 | TH |
| FG-F05 | Świece | 6 (2/2/2), zapis nielimitowany, pełne HP, stan trwały między fazami | TH |
| FG-F06 | Sloty zapisu | 3 manualne + 1 auto, 20 cykli save→load na slot bez korupcji; w tym stany wrogów, drzwi, świec, zagadek i NPC | TH |
| FG-F07 | Plecak | 6 slotów, maks. 3 przedmioty zagadkowe naraz, 0 softlocków z pełnym plecakiem | TH + PT |
| FG-F08 | Zagadki | 3, każda rozwiązywalna bez oddania strzału; P1 i P2 bez fail state | PT |
| FG-F09 | Zakończenia | oba osiągalne; `ENDING_1` i `ENDING_2` zależne wyłącznie od P3 | TH + PT |
| FG-F10 | Blokada sekwencji | P2 niemożliwe przed P1, P3 niemożliwe przed P2, wejście do Aktu III niemożliwe przed Nocą; fallback fazy nie omija P1/P2 | TH |
| FG-F11 | Zapisy kompatybilne | save z aktu I wczytuje się po restarcie gry i po aktualizacji builda w obrębie v1 | TH |
| FG-F12 | Sterowanie | pełne przejście gry na padzie i na klawiaturze | PT |
| FG-F13 | PL/EN | pełne przejście w obu językach | PT + LT |
| FG-F14 | Pauza/menu/quit | 0 utraty postępu, quit z poziomu pauzy działa | PT |
| FG-F15 | Brak martwych stref | każda z 11 stref odwiedzana w 100% przebiegów | TH (log pozycji) |
| FG-F16 | Ópi (B) — ruch tylko niewidziany | wariant B nie porusza się i nie atakuje, gdy jest w kadrze, ma LOS, mieści się w zasięgu widzenia gracza i oczy są otwarte; porusza się, gdy gracz patrzy w bok, mruga, widoczność przesłania ściana albo wróg jest poza zasięgiem widzenia (BAL-56) | TH |

### B.2 Wydajnościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| FG-P01 | FPS @1080p średni PC | średnio ≥ 60, 1% low ≥ 45 | PR |
| FG-P02 | FPS Steam Deck | ≥ 40, 1% low ≥ 30 | PR |
| FG-P03 | Draw calls / trójkąty | ≤ 250 / ≤ 350 000 w najgorszym kadrze gry | PR |
| FG-P04 | Czas ładowania (start, load save) | ≤ 8 s SSD, ≤ 15 s HDD | PR |
| FG-P05 | Pamięć | ≤ 2,0 GB RSS po 105 min sesji | PR |
| FG-P06 | Wycieki | wzrost RSS ≤ 150 MB między 10. a 100. minutą sesji | PR |
| FG-P07 | Zacinanie w walce | 0 klatek > 100 ms w 20 min walki | PR |
| FG-P08 | Stabilność 105 min | 3/3 pełne przebiegi bez crasha | PT |
| FG-P09 | Podmiana faz | ≤ 200 ms, 0 klatek > 50 ms | PR |
| FG-P10 | Rozdzielczości | 1280×720, 1920×1080, 2560×1440, 3440×1440 — UI nie wychodzi poza ekran | IN |

### B.3 Narracyjne / treściowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| FG-N01 | Objętość tekstu PL | 9 000 słów ± 20% (7 200–10 800) | AU |
| FG-N02 | Parzystość PL/EN | 100% kluczy, 0 pustych, 0 nieprzetłumaczonych zdań | AU |
| FG-N03 | Stringi UI | ≤ 400 kluczy | AU |
| FG-N04 | Walidator Ink | PASS na wszystkich plikach `story/` | IV |
| FG-N05 | Dokumenty | 20–25 notatek, każda czytelna i przypisana do strefy | IN |
| FG-N06 | NPC | 4, każdy z co najmniej 1 funkcją w zagadce lub finale | IN |
| FG-N07 | Folklor | 100% nazw z `docs/bestiary.md`; 0 nazw bez źródła | IN |
| FG-N08 | Zakończenia | 2, każde 2–3 min, oba mają epilog i powrót do menu | PT |
| FG-N09 | Spójność narracji | 0 sprzeczności w faktach świata na liście 20 faktów kanonu | IN |
| FG-N10 | Brak spoilerów w UI | nazwy zagadek i celów nie zdradzają rozwiązania | IN |
| FG-N11 | Napisy | 42 znaki/linia, maks. 2 linie, 0 przycięć przy 1,3× ekspansji EN | AU + LT |

### B.4 Jakościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| FG-Q01 | Błędy blokujące | **0** w dniu wydania | PT |
| FG-Q02 | Błędy nieblokujące | ≤ 10 znanych, 0 w kategorii „utrata postępu” | IN |
| FG-Q03 | Czas przejścia (5 testerów, pierwszy raz) | mediana 100–110 min, wszystkie w 90–120 min | PT |
| FG-Q04 | Liczba śmierci | mediana 2–4 na pierwsze przejście | PT |
| FG-Q05 | Czas rozwiązania zagadki | mediana ≤ 10 min na zagadkę; żaden tester > 20 min bez podpowiedzi | PT |
| FG-Q06 | Wykorzystanie amunicji | testerzy kończą z 0–10 nabojami pistoletu i 0–3 strzelby | PT |
| FG-Q07 | Odczucie horroru | ≥ 4/5 w ankiecie na 5 testerach | PT |
| FG-Q08 | Frustracja | ≤ 2/5 „gra jest niesprawiedliwa” | PT |
| FG-Q09 | Powtórne przejście | drugie przejście 75–95 min (potwierdza, że gracz nie błądzi i zna topografię) | PT |
| FG-Q10 | Dostępność | remap, napisy 3 rozmiary, inwersja Y, wyłączenie wstrząsu — wszystkie działają | PT |
| FG-Q11 | Czytelność wroga w Nocy | 3/3 testerów rozpoznaje wroga z ≥ 10 m przy latarce | PT |

### B.5 Definition of Done — pełna gra

- [ ] Wszystkie FG-* na zielono lub odstąpione pisemnie przez Mariusza.
- [ ] 0 błędów blokujących, 0 utraty postępu.
- [ ] Build Windows + Linux, uruchamiany bez konsoli deweloperskiej.
- [ ] 3/3 pełne przebiegi bez crasha na sprzęcie docelowym.
- [ ] Steam Deck: 40 FPS stabilne, sterowanie działa bez konfiguracji użytkownika.
- [ ] PL i EN przetestowane end-to-end.
- [ ] Brak plików tymczasowych, placeholderów i nieużytych assetów w buildzie.
- [ ] `docs/scope.md` §9 — wszystkie mierniki zakresu spełnione.

---

## C. Demo (publiczne)

Zakres: **Akt I (Dzień) + pierwsze ~10 min Aktu II**, samodzielne, kończy się
cliffhangerem. Czas: **30–40 min**. Save z demo **nie przenosi się** do pełnej
wersji (decyzja: koszt > zysk; kandydat do backlogu P1).

### C.1 Funkcjonalne

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| DM-F01 | Samodzielność | demo działa bez pełnej gry; osobny export preset z tego samego projektu, bez plików Aktu III | IN |
| DM-F02 | Czas | 30–40 min, mediana 34 min | PT |
| DM-F03 | Kompletność systemów | wszystkie systemy produkcyjne z §6 GDD; P2, P3, wariant C i zakończenia nie występują | IN |
| DM-F04 | Koniec demo | ekran końcowy z CTA, powrót do menu, 0 zawieszeń | PT |
| DM-F05 | Save w demo | 3 świece (2 z Aktu I + 1 z pierwszych 10 min Aktu II), zapis/odczyt 10 cykli | TH |
| DM-F06 | Brak dostępu do treści pełnej gry | 0 plików z pozostałej części Aktu II, Aktu III i finałów w buildzie demo | IN |
| DM-F07 | Sterowanie | pad + klawiatura, remap | PT |
| DM-F08 | PL/EN | pełne przejście w obu | PT |

### C.2 Wydajnościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| DM-P01 | FPS @1080p | ≥ 60 średnio, 1% low ≥ 45 | PR |
| DM-P02 | FPS Steam Deck | ≥ 40 | PR |
| DM-P03 | Czas ładowania | ≤ 8 s SSD | PR |
| DM-P04 | Rozmiar builda | ≤ 4 GB | IN |
| DM-P05 | Stabilność | 3/3 przebiegi 30–40 min bez crasha | PT |

### C.3 Narracyjne / treściowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| DM-N01 | Parzystość PL/EN | 100% | AU |
| DM-N02 | Walidator Ink | PASS | IV |
| DM-N03 | Placeholdery | 0 | AU |
| DM-N04 | Cliffhanger | ostatnia scena kończy się w momencie podniesionego napięcia (ocena 3/3 testerów) | PT |
| DM-N05 | Materiały sklepowe | 1 trailer ≤ 60 s, ≥ 6 screenshotów 1920×1080, opis PL/EN | IN |

### C.4 Jakościowe

| ID | Kryterium | Próg | Metoda |
|---|---|---|---|
| DM-Q01 | Błędy blokujące | 0 | PT |
| DM-Q02 | Błędy nieblokujące | ≤ 5 | IN |
| DM-Q03 | Pierwsze 5 min | ≥ 4/5 testerów kończy pierwsze 5 min bez porzucenia | PT |
| DM-Q04 | Konwersja intencji | ≥ 3/5 testerów deklaruje chęć zagrania w pełną wersję | PT (ankieta) |
| DM-Q05 | Wydajność na słabszym sprzęcie | 30 FPS na iGPU (Intel Iris Xe) przy 720p | PR |

### C.5 Definition of Done — demo

- [ ] Wszystkie DM-* na zielono.
- [ ] Build demo nie zawiera assetów ani tekstów z Aktów II (poza 10 min) i III.
- [ ] 0 błędów blokujących, 0 utraty postępu.
- [ ] Demo przetestowane na czystej maszynie bez Godota.
- [ ] Materiały sklepowe gotowe i zgodne z `docs/art-bible.md`.
- [ ] Zgoda Mariusza na publikację.

---

## D. Traceability — stałe balansu → kryteria

| Stała | Wartość | Kryterium weryfikujące |
|---|---|---|
| BAL-01 HP gracza | 100 | VS-F14, FG-Q04 |
| BAL-10/14 obrażenia broni | 25 / 60 | VS-F05 |
| BAL-18/19 amunicja | 44 / 10 | FG-F04, FG-Q06 |
| BAL-20/21/22 wrogowie | 50/100/150 HP | VS-F06, FG-F03 |
| BAL-28 liczba wrogów | 14 (4/6/4) | FG-F03 |
| BAL-35 świece | 6 (2/2/2) | VS-F08, FG-F05 |
| BAL-36 sloty zapisu | 3 + 1 auto | FG-F06 |
| BAL-37 zapis | 2,5 s + 0,4 s + i-frames | VS-F08, FG-F06 |
| BAL-39 sloty plecaka | 6 | VS-F09, FG-F07 |
| BAL-41 zakończenia | 2 | FG-F09 |
| BAL-43 czas przejścia | 105 (90–120) | FG-Q03 |
| BAL-45/46 przejścia faz | 30 s / 45 s | VS-F13, FG-F02 |
| BAL-48/49 wydajność | 60 FPS / ≤250 DC | VS-P01, VS-P03, FG-P01, FG-P03 |
| BAL-50 ładowanie | ≤ 8 s SSD | VS-P05, FG-P04 |
| BAL-52 tekstury | 256²/128²/512² | IN (zgodność z `docs/art-bible.md`) |
| BAL-53/54 lokalizacja i napisy | 9 000 słów / 42 znaki | FG-N01, FG-N11 |

---

## E. Czego ten dokument nie akceptuje

- „Wygląda dobrze” bez zrzutu ekranu i porównania z `docs/art-bible.md`.
- „Testowane ręcznie” bez arkusza playtestu (czas, śmierci, błędy).
- „Działa na moim komputerze” — wymagany sprzęt docelowy lub Steam Deck.
- Odstąpienie od kryterium bez pisemnej notatki Mariusza w tym pliku.
