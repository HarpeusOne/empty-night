# Empty Night — Backlog

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Właściciel | `game-designer` |
| Źródło zakresu | `docs/scope.md` |

**Zasada:** ten plik jest jedynym miejscem na pomysły spoza zakresu v1. Wpis
tutaj **nie jest obietnicą** — jest zapisem, że pomysł został zauważony i
świadomie odłożony. Wpisy są **append-only**: nikt nie usuwa cudzych pozycji.
Zmiana priorytetu lub decyzja o realizacji wymaga nowej linii w „Historii
zmian” (§3) z podaniem autora i daty.

**Priorytety:**
- **P0** — blokuje v1 lub naprawia błąd blokujący. Do zrobienia przed pełną grą.
- **P1** — dobry kandydat na post-launch; sensowny stosunek koszt/zysk.
- **P2** — do rozważenia po premierze; może nigdy nie wejść.

---

## 1. Tabela

| ID | Pomysł | Prio | Kandydat post-launch | Powód odłożenia | Źródło |
|---|---|---|---|---|---|
| BL-01 | **NG+ (New Game Plus)** — drugie przejście z zachowaną bronią i nowymi wariantami wroga | P1 | tak | Wymaga drugiego balansu amunicji, drugiego rozkładu 14 wrogów i testu 90–120 min. Zysk: retencja po premierze. Koszt: ~3 tyg. | game-designer |
| BL-02 | **Photo mode** — pauza, kamera swobodna, filtry, eksport PNG | P2 | tak | Tani technicznie (Godot ma `Camera3D` + `Viewport`), ale wymaga osobnego UI i blokady AI. Nie wnosi nic do pierwszego przejścia. Dobry dodatek marketingowy. | game-designer |
| BL-03 | **Co-op multiplayer (2 graczy)** | P2 | nie | Poza zakresem. Sieć, synchronizacja AI, drugi gracz psuje cały balans amunicji i świec. Koszt liczony w miesiącach, nie tygodniach. | game-designer |
| BL-04 | **Dubbing PL** (głosy NPC i wroga) | P1 | tak (warunkowo) | Poza zakresem. Casting + studio + 2 języki + lip-sync = 3–4 tyg. i realny budżet. Ma sens tylko przy sprzedaży pokrywającej koszt. | writer |
| BL-05 | **Crafting** — łączenie przedmiotów, amunicja z komponentów | P2 | nie | Poza zakresem i sprzeczne z filarem „amunicja to decyzja”. Crafting rozmywa ekonomię 44/10 naboi. | game-designer |
| BL-06 | **Open world / większa mapa** | P2 | nie | Poza zakresem. Większa mapa zjada budżet 105 min na chodzenie i wymaga strumieniowania. Linearność jest cechą, nie ograniczeniem. | game-designer |
| BL-07 | **Drzewko ulepszeń broni** | P2 | nie | Poza zakresem. 2 bronie × 3 ulepszenia = 6 nowych stanów balansu, nowe UI, nowe animacje. Zero zysku dla horroru tempo+audio. | game-designer |
| BL-08 | **Trzecia broń — broń biała (kij/kilof)** | P1 | tak | Kusi, bo daje odpowiedź na brak amunicji. Ale: nowy zestaw animacji, nowy balans zasięgu, nowa ekonomia. Kandydat po premierze jako „hard mode”. | game-designer |
| BL-09 | **Drugi typ wroga / mini-boss** | P1 | tak | Poza zakresem (1 typ, 3 warianty). Nowy rig + nowe AI + nowe animacje ≈ 4 tyg. Warianty A/B/C pokrywają całą krzywą. | level-designer |
| BL-10 | **Poziomy trudności (easy/normal/hard)** | P1 | tak | v1 ma jeden profil balansowany pod 105 min. Trzy poziomy = 3× playtest. Tanie po premierze, jeśli ograniczyć do mnożnika obrażeń i amunicji. | game-designer |
| BL-11 | **Przenoszenie save'a z demo do pełnej gry** | P1 | tak | Świadomie wycięte z demo (koszt formatu zgodności i QA). Wraca, jeśli demo zbierze wystarczająco dużo wishlistów. | game-designer |
| BL-12 | **Osiągnięcia Steam + karty kolekcjonerskie** | P1 | tak | Wymaga integracji Steamworks i 20–30 zaprojektowanych osiągnięć. Tanie, ale poza v1. | programmer |
| BL-13 | **Chapter select / speedrun timer** | P2 | tak | Wymaga zapisu stanu na starcie każdego aktu i osobnego UI. Sensowne dopiero, gdy gra ma społeczność speedrunową. | programmer |
| BL-14 | **Galeria konceptów + komentarz dewelopera** | P2 | tak | Treść marketingowa, nie mechanika. Zależy od `art/manifest.json` i ilości gotowych assetów. | artist |
| BL-15 | **Gyro aim na padzie** | P2 | tak | Nisza. Wymaga kalibracji i osobnego testu. Pad + klawiatura pokrywają zakres v1. | programmer |
| BL-16 | **Dynamiczna pogoda (deszcz, burza)** | P2 | nie | Czwarty profil światła + VFX + wpływ na audio. Trzy fazy już dają pełną krzywą nastroju; pogoda rozmyłaby czytelność sygnałów wroga. | artist |
| BL-17 | **Audiologgi / radio** | P2 | tak | Świetne narracyjnie, ale dubbing jest poza zakresem, a czysty tekst w radiu jest gorszy niż notatka. Wraca razem z BL-04. | writer |
| BL-18 | **Trzecie zakończenie („true ending”)** | P2 | nie | Świadomie odrzucone: +1 scena finałowa, +1 ścieżka QA, +~2 h pracy, zero zysku. Dwa zakończenia są czytelne i wystarczające. | writer |
| BL-19 | **Licencjonowana kaszubska muzyka ludowa** | P2 | tak | Koszt licencji + negocjacje. v1 korzysta z pakietów i 2 autorskich cue'ów. Wzmacnia autentyczność, więc warto wrócić przy budżecie. | artist |
| BL-20 | **Rozszerzona dostępność** (tryb niewidzialnego wroga, pełny remap UI, opisy dźwiękowe) | P1 | tak | v1 ma 4 opcje (remap, napisy, inwersja Y, wstrząs). Pełna dostępność to osobny pass projektowy i test z graczem. | game-designer |
| BL-21 | **Fotorealistyczny look (odejście od PS2)** | P2 | nie | Sprzeczne z decyzją artystyczną i budżetem 1 dewelopera. PS2-style jest tani i spójny. | artist |
| BL-22 | **Wersja mobilna / Switch** | P2 | nie | Nowy port, nowe sterowanie, nowe ograniczenia pamięci. Poza horyzontem v1. | game-designer |
| BL-23 | **Mòra — mechaniczny hazard nocny** (duszenie, utrata HP, przebudzenia) | P2 | tak | Bestiariusz opisuje morę jako efekt; w v1 zostaje ambientem/narracją bez HP i bez AI. Pełny hazard to drugi system nocny i nowy balans — poza zakresem 1 typu wroga. | writer |
| BL-24 | **Adaptacyjna warstwa audio przy niskim HP** (heartbeat, oddech) | P1 | tak | Dynamiczny miks jest poza zakresem v1 (scope §3). W v1 stinger + cisza; warstwa HP to tani efekt po premierze, ale wymaga testu miksowania. | programmer |
| BL-25 | **Demony-spotkania bez HP** (3, po jednym na akt: Mòra — akt I, Pólnica — akt II, Nëczk — akt III) — wydarzenia rozwiązywane mechaniką (mruganie, światło, dźwięk, przedmiot) | P1 | tak | **Skład zatwierdzony przez Mariusza 2026-11-07 jako zawartość istniejących zagadek; formalna wymiana zakresu do potwierdzenia** (scope §8): to nowy rodzaj treści obok 1 typu wroga i 3 zagadek. Bez HP nie rusza ekonomii amunicji, ale wymaga wymiany pozycji o podobnym koszcie. Szczegóły: `docs/bestiary.md` §2.1. | game-designer |
| BL-26 | **Ukryte nisze duchów opiekuńczych** (amunicja przesunięta z puli, notatka, najwyżej 1 jednorazowe leczenie w grze) | P1 | tak | **Leczenie raz w grze zatwierdzone przez Mariusza 2026-11-07; reszta do potwierdzenia.** Amunicja: przesunięcie w ramach sumy 44/10 (BAL-18/19), bez dodawania. Leczenie to wyjątek od BAL-07 i wymaga zmiany GDD §6.5. Nisza ma być w istniejącej strefie, nie nowym wnętrzem. | game-designer |
| BL-27 | **Boss z HP** (demon kaszubski jako walka) | P2 | nie | **Odrzucone na rzecz BL-25** (decyzja Mariusza 2026-11-07, „jeśli bardziej pasuje do wierzeń”): źródła opisują demony przez skutki dla ludzi, nie przez walkę; boss z HP łamie scope (2. typ wroga, osobny rig/AI) i ekonomię amunicji (BAL-28). | game-designer |

---

## 2. Szablon wpisu

```
| BL-XX | **Nazwa pomysłu** | P0/P1/P2 | tak/nie | Jedno-dwuzdaniowy powód odłożenia (koszt vs zysk). | agent |
```

---

## 3. Historia zmian

| Wersja | Data | Zmiana | Autor |
|---|---|---|---|
| 0.1 | 2026-10-29 | Utworzenie backlogu, 22 pozycje startowe | game-designer |
| 0.2 | 2026-10-29 | Dodano BL-23 (Mòra jako mechaniczny hazard); synchronizacja z bestiariuszem | game-designer |
| 0.3 | 2026-10-29 | Dodano BL-24 (adaptacyjna warstwa audio HP); usunięto ją z day-night jako scope creep | game-designer |
| 0.4 | 2026-11-07 | Dodano BL-25…BL-27 (demony-spotkania, ukryte nisze, boss z HP odrzucony) po rozmowie z Mariuszem; powiązane z bestiariuszem v0.2 | Claude + Mariusz |
