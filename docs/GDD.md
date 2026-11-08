# Empty Night — Game Design Document

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Status | draft do review Pucka / Mariusza |
| Właściciel | `game-designer` |
| Silnik | Godot 4.7 |
| Platforma | Windows / Linux / Steam Deck (Steam) |
| Powiązane | `docs/scope.md`, `docs/acceptance.md`, `docs/backlog.md`, `docs/day-night.md` |

> **Konwencja nazw folkloru.** W tym dokumencie wróg występuje jako
> **wariant A / B / C**. Nazwy istot, imiona NPC i terminologia ludowa
> pochodzą wyłącznie z `docs/bestiary.md` (właściciel: `writer`) i **nie są
> wymyślane tutaj**. Do czasu powstania bestiariusza obowiązują oznaczenia
> literowe.

---

## 1. Wizja i fantasy gracza

**Zdanie produktowe.** Linearny survival horror w stylu PS2: jedna kaszubska
wieś, jeden dzień, jedna noc, jedna droga wyjścia.

**Fantasy gracza.** Gracz chce czuć się *mały* w miejscu, które zna, ale które
przestało być znajome. Nie jest żołnierzem — jest kimś, kto ma pistolet i
osiem naboi. Horror bierze się z tego, że **wioska się nie zmienia, tylko
ciemnieje**: te same trzy ulice, ten sam plac, ta sama droga nad jezioro, ale
o 22:00 są nie do przejścia bez świecy i latarki.

**Trzy filary (każda decyzja musi obsłużyć co najmniej jeden):**

1. **Ta sama przestrzeń, trzy nastroje.** Jedna geometria, trzy profile
   światła/mgły/dźwięku. Zero nowych leveli na fazę — patrz `docs/day-night.md`.
2. **Amunicja to decyzja, nie zasób.** 44 naboje do pistoletu i 10 do strzelby
   na całą grę. Zabicie wszystkiego jest niemożliwe i nie jest celem.
3. **Tempo zamiast mechanik.** Brak craftingu, drzewka, ekwipunku z wagą.
   Sześć slotów, dwie bronie, trzy zagadki, jeden typ wroga w trzech wariantach.

**Czego gra nie robi.** Nie straszy jumpscare'ami w rytmie co 30 s, nie daje
graczowi przewagi liczebnej, nie tłumaczy świata w kodzie — świat tłumaczą
dokumenty i NPC (właściciel treści: `writer`).

---

## 2. Cel gry

**Cel fabularny (systemowo).** Gracz przechodzi przez trzy akty w jednej
przestrzeni i w finale podejmuje **jedną decyzję** w zagadce 3, która wybiera
jedno z dwóch zakończeń.

**Cel mechaniczny.** Dotrzeć z punktu startowego do finału, rozwiązując trzy
zagadki i przeżywając 14 spotkań z wrogiem, przy budżecie amunicji, który przy
celności 70% wystarcza na ok. 11–12 z 14 zabójstw.

**Cel emocjonalny.** Ostatnie 20 minut gry gracz ma przejść bez sprintu,
bo wie, że sprint jest głośny (BAL-24).

**Warunek porażki.** HP gracza = 0. Gracz wraca do ostatniego zapisu; jeśli
żadnego nie ma — do ostatniego auto-checkpointu aktu (BAL-09). Brak ekranu
game over z restartem całej gry.

---

## 3. Pętla rozgrywki

### 3.1 Mikro (5–20 s) — pętla napięcia

```
rozejrzyj się → usłysz/ zobacz wroga → wybierz: unik / walka / ucieczka
   → (walka) wyceluj → strzał → przeładuj (1,6 s okna) → odsuń się
   → (unik) zmień prędkość (sprint = hałas 12 m) → sprawdź korytarz ucieczki
```

Mikropętla jest **jedna** i nie zmienia się przez całą grę. Zmienia się tylko
to, co ją zasila: faza dnia (zasięg widzenia wroga), wariant wroga (prędkość i
HP) i zapas amunicji.

### 3.2 Mezo (2–6 min) — pętla pokoju / ulicy

```
wejście w strefę → rozpoznanie (dźwięk, światło, ślady)
   → interakcja (przedmiot / dźwignia / NPC) → reakcja świata (otwarcie drogi,
     zapalenie świecy, przejście fazy) → wyjście w nową strefę
```

Strefa ma zawsze jedno wejście „drogie” (z wrogiem) i jedno wyjście
„tanie” (po rozwiązaniu). Level-designer nie projektuje ślepych zaułków bez
wyjścia — gra jest linearna.

### 3.3 Makro (cała gra) — pętla aktu

```
Akt → nowa faza dnia → nowy wariant wroga → nowa zagadka → nowe drogi otwarte
   → świeca (save + pełne HP) → następny akt
```

Makropętla jest **trzyrazowa** i zamknięta. Nie ma powrotu do poprzedniej fazy.

---

## 4. Struktura gry i budżet minut

Cel: **105 min** pierwszego przejścia. Zakres akceptowalny: 90–120 min
(BAL-43). 90 min = gracz zna zagadki i pomija dialogi; 120 min = eksploracja
dokumentów + 3–4 śmierci.

| Etap | Faza | Czas (min) | Obszary | Wróg | Zagadka | Świece |
|---|---|---:|---|---|---|---:|
| Prolog / tytuł | — | 2 | menu, ekran tytułowy | — | — | — |
| Akt I | Dzień | 28 | V1, V2, V3, SQ, I-1, I-2, wejście F1 | 2× A | P1 | 2 |
| Akt II | Zmierzch | 38 | F1, F2, I-3, L1, SQ | 2× A, 4× B | P2 | 2 |
| Akt III | Noc | 33 | SQ, I-4, L1, F2, kościół | 2× B, 4× C | P3 | 2 |
| Finał | Noc | 4 | strefa finałowa | — | decyzja | — |
| **Suma** | | **105** | | **14** | **3** | **6** |

**Uwaga:** `I-4` to wnętrze kościoła w obrębie SQ; w tabeli „kościół” oznacza
finałową część I-4, a nie piąte wnętrze. Liczba wnętrz pozostaje **4**.

**Skala świata.** Footprint playable ≈ 240 × 180 m. Łączny dystans pierwszego
przejścia ≈ **3,0–3,4 km**. Przy efektywnej prędkości z postojami
**1,5–1,7 m/s** daje to **30–38 min samego ruchu** — resztę budżetu zjadają
zagadki, walka, dialogi i czytanie. To uzasadnia rozmiar mapy: większa mapa
zjadłaby budżet minut bez dodania napięcia.

**Rozbicie minut w aktach:**

| Akt | Eksploracja / przejścia | Dialogi / dokumenty | Zagadka | Walka | Suma |
|---|---:|---:|---:|---:|---:|
| I | 12 | 6 | 6 | 4 | 28 |
| II | 14 | 6 | 8 | 10 | 38 |
| III | 10 | 5 | 7 | 11 | 33 |

Walka rośnie (4 → 10 → 11 min), a eksploracja rośnie do Aktu II i dopiero potem
spada (12 → 14 → 10), bo w Zmierzchu gracz jeszcze poznaje nowe drogi, a w Nocy
zna już topografię. To jest cała „krzywa trudności” — nie ma menu difficulty.

**NPC:** 4 łącznie — 2 w Akcie I (dawca przedmiotu, dawca informacji), 1 w Akcie
II (blokada, która barykaduje I-1/I-2 w Nocy) i 1 w Akcie III (świadek finału).
Dialog jest opcjonalny i nigdy nie blokuje zagadki.

---

## 5. Fazy dnia

Pełna specyfikacja: **`docs/day-night.md`**. Skrót:

| Faza | Czas w grze | Widoczność | Warianty wroga | Leash | Światła omni |
|---|---|---:|---|---:|---:|
| Dzień | 14:00–17:00 | 60 m | A | 20 m | 0 |
| Zmierzch | 18:30–20:00 | 35 m | A, B | 35 m | 6 |
| Noc | 22:00–03:00 | 12 m (20 m z latarką) | B, C | 60 m | 12 |

Przejścia: Dzień→Zmierzch **30 s**, Zmierzch→Noc **45 s**, bez cięcia kamery,
gracz zachowuje kontrolę. Brak powrotu.

**Zasada twarda:** trzy fazy to **jeden plik levelu**. Podmieniane są wyłącznie
`PhaseProfile` (światło, mgła, sky), emitery dźwięku, materiały i stany
kolizji. Nowe meshe w fazie = naruszenie zakresu (→ `docs/backlog.md`).

---

## 6. Systemy

### 6.1 Kamera OTS i ruch

- Third-person over-the-shoulder, stała strona (prawe ramię).
- Wysokość kamery 1,55 m, offset barku 0,45 m, dystans 2,2 m (biodro) /
  1,5 m (celowanie). FOV 65° / 50°. (BAL-30, BAL-31)
- Kolizja kamery: sfera 0,25 m, brak auto-obrotu — gracz sam prowadzi kamerę.
  Uzasadnienie: auto-kamera w ciasnych wnętrzach psuje orientację i jest
  droższa w implementacji.
- Prędkości: chód 2,0 m/s, sprint 4,2 m/s, crouch 1,1 m/s, chód z celowaniem
  1,2 m/s (BAL-02…05). Sprint > prędkość najszybszego wroga (2,8 m/s) — ucieczka
  zawsze możliwa, ale kosztuje staminę i hałas.
- Stamina 100, drain 20/s (5 s sprintu = 21 m), regen 12/s po 1,5 s przerwy
  (BAL-06). Sprint to narzędzie, nie tryb poruszania się.
- Quick-turn 180° w 0,35 s (BAL-34) — jeden przycisk, bo OTS bez quick-turnu
  w ciasnych korytarzach jest frustrujący.

### 6.2 Celowanie i strzelanie

- Celowanie na przytrzymanie (RMB / R1). W trybie celowania prędkość spada do
  1,2 m/s, FOV 50°, pojawia się crosshair i licznik amunicji.
- Strzał hitscan (raycast), bez balistyki pocisku. Uzasadnienie: PS2-style,
  tanie w implementacji i testowalne headless.
- Rozrzut: pistolet 0,9° w bezruchu / 2,0° w ruchu; z biodra 7° (praktycznie
  nieużyteczne — wymusza celowanie). Strzelba: stożek 8° zawsze (BAL-12, BAL-15).
- Brak laser sight, brak auto-aim, brak lock-on.
- Odrzut: 1,5° w górę na strzał z pistoletu, 6° ze strzelby; powrót 0,25 s.
- Trafienie w głowę: ×2 obrażenia dla pistoletu. Strzelba bez mnożnika
  (i tak zabija wariant A jednym strzałem).

### 6.3 Broń

| Parametr | Pistolet | Strzelba | Uwaga |
|---|---|---|---|
| Obrażenia | 25 | 60 (10 × 6 pellet) | BAL-10, BAL-14 |
| Pojemność | 8 | 6 (rurowy) | |
| ROF | 0,45 s | 0,9 s | BAL-13, BAL-16 |
| Przeładowanie | 1,6 s (całe) | 0,6 s / nabój | przerywalne |
| Zasięg pełny | ≤ 18 m | ≤ 4 m | BAL-11, BAL-15 |
| Zasięg maks. | 30 m (−50% dmg) | 9 m (0 dmg) | |
| Rozrzut | 0,9° / 2,0° | 8° stożek | |
| Slot plecaka | 1 | 1 | |

**Uzasadnienie ekonomii:** łącznie **44 naboje pistoletowe (1100 dmg)** i
**10 strzelby (600 dmg)** = **1700 potencjalnych obrażeń** przy trafieniach w
tors, bez headshotów. Pełne wyczyszczenie
mapy wymaga 1400 dmg (4×50 + 6×100 + 4×150), czyli **82% celności** bez ani
jednego zmarnowanego naboju. Przy realistycznych 70% gracz zadaje ~1190 dmg,
co wystarcza na **11–12 z 14** zabójstw. Dlatego projekt zakłada **ominięcie
2–3 wrogów** — to nie jest opcja, to jest plan. Pełny clear jest możliwy
wyłącznie dla gracza, który nie pudłuje i walczy z bliska.

Amunicja narastająco: Akt I **14 / 0**, Akt II **16 / 6**, Akt III **14 / 4**
(BAL-18, BAL-19). Strzelba wchodzi na starcie Aktu II — do tego czasu gracz
uczy się celowania na wariancie A.

### 6.4 Wróg — jeden typ, trzy warianty

Nazwy wariantów: `docs/bestiary.md` — **A — Głodny**, **B — Ópi**,
**C — Stary**. Poniżej wyłącznie profil mechaniczny. Wariant C ma 4 instancje;
finałowa, unikalna instancja to Szymon Kreft (postać z bestiariusza), pozostałe
3 to „starzy” wieszczi bez własnych imion. Finałowy C może mieć skryptowaną
kwestię w Ink, ale nie jest bossem i nie dodaje nowego AI.

| Parametr | Wariant A | Wariant B | Wariant C |
|---|---:|---:|---:|
| HP | 50 | 100 | 150 |
| Prędkość | 2,8 m/s | 1,9 m/s | 1,4 m/s |
| Zasięg ataku | 1,6 m | 2,0 m | 2,5 m |
| Obrażenia | 15 | 25 | 30 |
| Kadencja ataku | 1,4 s | 1,8 s | 2,6 s |
| Telegraph (windup) | 0,35 s | 0,5 s | 0,8 s |
| Stagger od pistoletu | 0,15 s | 0,10 s | 0,05 s |
| Stagger od strzelby | 0,6 s | 0,4 s | 0,25 s |
| Występowanie | Dzień, Zmierzch | Zmierzch, Noc | tylko Noc |

**Role w designie:** A = pościg (szybszy niż chód gracza, wymusza sprint lub
walkę), B = standard (blokuje korytarz; ruch tylko niewidziany, patrz niżej), C = tank
(wymusza strzelbę lub obejście).

**Ópi (B) — ruch tylko niewidziany.** Wariant B nie porusza się i nie atakuje,
dopóki gracz go widzi: jest w kadrze kamery, ma linię widzenia i mieści się w
zasięgu widzenia gracza (Dzień 60 m, Zmierzch 35 m, Noc 12 m, 20 m z latarką),
a oczy gracza są otwarte. Poza kadrem, za przeszkodą, w ciemności poza zasięgiem
albo podczas mrugnięcia porusza się normalnie (1,9 m/s). **Mruganie jest oknem
ruchu:** mrugnięcie automatyczne trwa 0,55 s (ok. 0,37 s „zamkniętych oczu”),
ręczne 0,22 s (ok. 0,15 s), więc przybliża go o ok. 0,7 m, odpowiednio ok. 0,3 m.
To modyfikator AI wariantu B, nie nowy typ wroga ani rig; domyślnie obejmuje
wszystkie 6 instancji B (flaga per instancja). HP, obrażenia i ekonomia amunicji
bez zmian. Źródło: wynalazek gry (`docs/bestiary.md` §3.10, §4).

**Czas do zabicia gracza przy kontakcie bez przerwy:** A 7 trafień × 1,4 s =
**9,8 s**; B 4 × 1,8 = **5,4 s**; C 4 × 2,6 = **7,8 s** (BAL-01, BAL-20…22).
Wszystkie warianty zabijają w 5–10 s — dość czasu na reakcję, za mało na
wahanie.

**Percepcja (BAL-23, BAL-24):**

| Kanał | Wartość |
|---|---|
| Stożek widzenia | 100° poziomo |
| Zasięg wzroku: Dzień / Zmierzch / Noc | 18 / 14 / 10 m |
| Modyfikator: latarka włączona | +6 m |
| Słyszenie: strzał | 45 m |
| Słyszenie: sprint | 12 m |
| Słyszenie: chód | 4 m |
| Słyszenie: crouch | 0 m |

**Latarka to wybór, nie udogodnienie.** Włączona = widzisz 20 m, ale wróg
widzi cię 6 m dalej. Wyłączona = widzisz 12 m. To jedyna „mechanika ryzyka”
poza amunicją i jest darmowa w implementacji (jeden bool do percepcji).

**AI — stany:** `idle → patrol → suspicious → search → chase → attack →
stagger → dead`. Search trwa 20 s (Dzień/Zmierzch) / 25 s (Noc), potem powrót
do patrolu. Leash: **20 / 35 / 60 m** zależnie od fazy (BAL-25, BAL-26).

**Liczba wrogów:** 14 na całą grę, bez respawnu (BAL-28, BAL-29):
Akt I `2× A`, Akt II `2× A + 4× B`, Akt III `2× B + 4× C`.
Brak respawnu = przewidywalna ekonomia amunicji i testowalność. Przejście fazy
despawnuje starą obsadę i spawnuje nową w istniejących punktach; to **nowe
instancje z sumy 14**, nie respawn zabitych.

**Istoty niebędące wrogami.** Mòra, Bòrowô Cotka, Stolem, Pólnica, Nëczk,
Krôsniãta i Grzenia są w `docs/bestiary.md` elementami narracyjnymi/ambientowymi
(rodzaje: demon-spotkanie, duch opiekuńczy, ambient — bestiariusz §2.1), nie
typami wroga: nie mają HP. Bòrowô Cotka i Krôsniãta mogą być NPC-1…4, ale ich
funkcje muszą mieścić się w 4 NPC i 3 zagadkach. Pùrtk został wycofany z v1
(2026-11-07). Żadna z tych istot nie
dodaje systemu poza v1; ewentualny mechaniczny hazard mory → `docs/backlog.md`.

### 6.5 Obrażenia, śmierć, retry

- Gracz: 100 HP, brak regeneracji, brak przedmiotów leczniczych.
- **Pełne HP wraca wyłącznie przy zapisie na świecy** (BAL-07). To czyni
  świecę decyzją (wrócić się wyleczyć czy iść dalej) i eliminuje cały system
  apteczek z zakresu.
- I-frames po trafieniu: 0,6 s (BAL-08).
- Śmierć → wczytanie ostatniego zapisu. Brak zapisu → auto-checkpoint aktu
  (BAL-38).
- Brak ekranu „game over” z wyborem — fade 2 s, load, fade 2 s.

### 6.6 Plecak — 6 slotów

- **6 slotów** (BAL-39). Bronie i latarka zajmują slot trwale po zdobyciu
  (3 sloty po Akcie II), zostawiając **3 sloty na przedmioty zagadkowe**.
- Amunicja **nie zajmuje slotu** — jest licznikiem w HUD (widocznym tylko przy
  celowaniu).
- Klucze i dokumenty trafiają do osobnej, nielimitowanej zakładki
  `Dokumenty` — zapobiega softlockowi przez zapchany plecak.
- **Twarde ograniczenie dla level-designera:** maks. **3 przedmioty zagadkowe
  jednocześnie** w całym łańcuchu. Czwarty = błąd projektu, nie błąd gracza.
- Podnoszenie: promień 2,5 m, stożek 60° od środka ekranu, czas 0,4 s
  (BAL-40). Bez animacji podnoszenia — PS2-style.

### 6.7 Świece i zapis

- **6 świec** w świecie: Akt I 2, Akt II 2, Akt III 2 (BAL-35).
- Interakcja: zapalenie (jednorazowe, stan trwały) → **zapis** + **pełne HP**.
- **Liczba zapisów nielimitowana** na świecę. Uzasadnienie: system „ładunków”
  wymaga UI, licznika i balansu, a jedyną realną karą w horrorze jest droga
  powrotna. Odległość między świecami: **90–180 s** marszu (≈ 145–290 m przy
  1,6 m/s) — to jest koszt zapisu.
- Zapis trwa 2,5 s (animacja) + 0,4 s (zapis na dysk). Podczas animacji gracz
  jest unieruchomiony, ale ma **i-frames 2,5 s** i zapis nie może zostać
  przerwany. Świece stoją w osłoniętych wnękach, nie na otwartej ulicy.
- **Sloty zapisu: 3 manualne + 1 auto** (BAL-36). To NIE jest to samo co
  6 slotów plecaka — mylenie tych liczb jest błędem.
- Auto-checkpoint: 2 (przejście Dzień→Zmierzch, Zmierzch→Noc) (BAL-38).
- Świeca jest jednocześnie **latarnią nawigacyjną w Nocy** — pali się we
  wszystkich fazach po zapaleniu, więc pełni trzy role: save, heal, landmark.
- Wymaganie techniczne: zapis zawiera `phase_id`, 6 booli świec, pozycję gracza,
  HP, amunicję, flagi P1/P2/P3, `ending_flag`, `witness_flag`, stan drzwi, stan
  przedmiotów zagadek, stan NPC oraz stan 14 wrogów (żywy/martwy/pozycja).

### 6.8 Zagadki — 3

Projekt szczegółowy: `docs/level-bible.md` (`level-designer`). Tutaj kontrakt
systemowy:

| ID | Typ | Akt | Ogniwa | Fail state | Wpływ na świat |
|---|---|---|---:|---|---|
| P1 | Łańcuch przedmiotów | I | 3 | brak (przedmioty nie znikają) | otwiera przejście do Aktu II (trigger fazy) |
| P2 | Sekwencja środowiskowa | II | 4 | brak (natychmiastowy reset, 0 kary) | otwiera Noc (trigger fazy) |
| P3 | Wybór | III | 2 rozwiązania | brak (oba poprawne) | ustawia `ending_flag` |

Zasady wspólne:
- Żadna zagadka nie wymaga walki ani amunicji — można ją rozwiązać bez
  wystrzału. Wróg jest presją, nie kluczem.
- Każda zagadka ma **3 poziomy podpowiedzi**: obserwacja świata → dokument →
  dialog NPC. Brak systemu podpowiedzi na timerze (oszczędność implementacji).
- Zagadka nigdy nie wymaga przedmiotu, którego gracz nie może już zdobyć
  (brak jednorazowych, przepadających kluczy).
- P1 i P2 są **bramkami faz** — nie da się ich pominąć, więc nie da się
  zablokować przejścia fazy. Fallback fazy (BAL-46) odpala się wyłącznie po
  rozwiązaniu zagadki, więc nie omija bramki.
- Elementy bestiariusza (np. trzecia zwrotka Bòrowô Cotki, mleko dla Krôsniąt)
  mogą być ogniwami P1/P2, ale nie tworzą czwartej zagadki ani trwałego fail
  state; każda ingerencja NPC jest odwracalna.

### 6.9 Zakończenia — 2

- `ending_flag` (bool) ustawiany **wyłącznie** w P3 (BAL-41).
- Test Bòrowô Cotki (bestiariusz) może przygotować wybór, ale **nie ustawia**
  `ending_flag`; jeśli ma być decyzją, może zmienić `witness_flag` lub wejść
  do P3. Trzecie zakończenie nadal nie istnieje.
- Dwa zakończenia: `ENDING_1` / `ENDING_2`, każde 2–3 min (wliczone w 4 min
  finału).
- Drugorzędna flaga z Aktu II (`witness_flag`) **nie tworzy trzeciego
  zakończenia** — zmienia jeden akapit epilogu. Uzasadnienie: trzecie
  zakończenie to +1 scena, +1 QA path, +~2 h pracy przy zerowym zysku dla
  gracza.
- Po zakończeniu: ekran z podsumowaniem (czas, zabójstwa, śmierci) i powrót
  do menu. Brak NG+ (→ backlog).

### 6.10 Latarka

- Slot 1, toggle (F / Y), brak baterii. Uzasadnienie: zarządzanie baterią to
  czwarty zasób — za dużo przy 6 slotach i 105 min.
- Wpływ: +8 m zasięgu widzenia gracza w Nocy (12 → 20 m) i **+6 m zasięgu
  percepcji wroga w każdej fazie** (BAL-23).
- W Dzień i Zmierzchu włączona nie daje przewagi, a zwiększa percepcję wroga —
  to czysta wada, więc gracz ją wyłącza. W Nocy jest wyborem: widzisz dalej,
  ale wróg widzi cię szybciej.

### 6.11 NPC i dialog

- **4 NPC** (NPC-1…NPC-4), funkcje: dawca przedmiotu, dawca informacji,
  blokada drogi, świadek finału. Rozmieszczenie: 2 w Akcie I, 1 w Akcie II
  (NPC-3, blokada, która barykaduje I-1/I-2 w Nocy — patrz `docs/day-night.md`
  §4.3) i 1 w Akcie III (świadek finału).
- Konkretne imiona i mapowanie NPC-1…4: `docs/bestiary.md`; suma musi pozostać
  **4** (2/1/1), a każdy NPC ma jedną funkcję.
- Dialog w **Ink**, tekst PL/EN, bez dubbingu i bez runtime LLM. Dialog jest
  modalny (pauzuje grę), ale nigdy nie blokuje zagadki ani przejścia fazy.
- Każdy NPC ma **jedną funkcję**; brak quest logu, brak wskaźnika celu.
- Dialogi są opcjonalne. Gracz, który je pomija, musi mieć wszystkie informacje
  potrzebne do P1–P3 w świecie i dokumentach (3 poziomy podpowiedzi, §6.8).

### 6.12 Intro, kamera i widok

Gra zaczyna się cutscenką: samochód wjeżdża do Lini, zatrzymuje się przy
tablicy, postać wysiada i pojawia się kwestia „Znowu na tym wydupiu, boże.”.
Cutscenkę można pominąć Enter/Esc. Domyślnie kamera jest first-person z oczu;
klawisz **V** przełącza na OTS za postacią (do oglądania modelu i testów).

### 6.13 HUD i broń pierwszoosobowa

HUD jest graficzny: panel zdrowia i mrugania w lewym dolnym rogu, panel
ekwipunku u góry, ikony zdrowia/oka, stylizowane paski. Amunicja nie jest
osobnym licznikiem 2D: jest `Label3D` przypięty do widocznej broni
pierwszoosobowej (pistolet/strzelba), która ma tekstury, kołysanie, odrzut,
błysk wylotu i animację przeładowania. Kamerą jest głowa/oczy postaci.

### 6.14 Mruganie

Nowa mechanika na życzenie Mariusza. Pasek „MRUGANIE” w HUD (lewy dół, nad HP)
powoli się wyczerpuje (14 s). Gdy spadnie do zera, postać mruga
automatycznie, na 0,55 s zasłaniając obraz; po mrugnięciu pasek wraca do 100.
Klawisz **B** / przycisk **Y** pozwala mrugnąć wcześniej, natychmiast
odnawiając pasek (0,22 s zasłony, cooldown 0,35 s). Nie ma kary za pełny
pasek ani za mruganie ręczne; mechanika jest rytmem i narzędziem do
planowania widoczności, a nie drugim paseczkiem HP.

---

## 7. Sterowanie (pad + klawiatura)

### 7.1 Pad (Xbox / DualShock, layout Xbox w UI)

| Akcja | Pad |
|---|---|
| Ruch | Lewy drążek |
| Kamera | Prawy drążek |
| Sprint (hold) | LB / L1 |
| Celowanie (hold) | RB / R1 |
| Strzał | RT / R2 |
| Interakcja | A / Cross |
| Anuluj / wstecz | B / Circle |
| Przeładowanie | X / Square |
| Latarka | Y / Triangle |
| Mrugnięcie | R3 |
| Quick-turn 180° | LT / L2 |
| Crouch (toggle) | D-pad ↑ |
| Zmiana broni | D-pad ← / → |
| Plecak | D-pad ↓ |
| Pauza | Start / Options |

### 7.2 Klawiatura + mysz

| Akcja | Klawisz |
|---|---|
| Ruch | WASD |
| Kamera | Mysz |
| Sprint (hold) | Shift |
| Crouch (toggle) | Ctrl |
| Celowanie (hold) | Prawy przycisk myszy |
| Strzał | Lewy przycisk myszy |
| Interakcja | E |
| Przeładowanie | R |
| Latarka | F |
| Mrugnięcie | B / R3 |
| Widok FP/OTS | V / Back |
| Quick-turn 180° | Q |
| Broń 1 / 2 | 1 / 2 |
| Plecak | Tab |
| Pauza | Esc |

### 7.3 Zasady sterowania

- Pełny remap obu urządzeń, zapis w `user://input.cfg`.
- Automatyczne wykrywanie urządzenia i podmiana promptów (ikony pada ↔ klawisze)
  w czasie ≤ 0,2 s od ostatniego inputu.
- Martwa strefa drążka: 0,18. Czułość myszy 0,5–6,0 (domyślnie 2,0), pada
  0,5–6,0 (domyślnie 2,5) (BAL-32). Inwersja osi Y: opcja.
- Brak QTE. Brak sekwencji przycisków. Jedyny „timing” to windup wroga.

---

## 8. UX / HUD

**Zasada:** HUD jest niewidoczny, dopóki nie jest potrzebny.

| Element | Kiedy widoczny | Uwagi |
|---|---|---|
| HP | tylko po otrzymaniu obrażeń, 4 s | brak paska przy pełnym HP |
| Amunicja | tylko w trybie celowania | `8 / 12` format, nie ikony |
| Crosshair | tylko w celowaniu | 4 kreski, 12 px |
| Prompt interakcji | w promieniu 2,5 m i stożku 60° | czas reakcji UI ≤ 0,1 s |
| Komunikat zapisu | 2,5 s podczas animacji | „Zapisano” PL / „Saved” EN |
| Napisy | zawsze gdy jest kwestia | 42 znaki/linia, maks. 2 linie |
| Plecak | po wciśnięciu | pauzuje grę, 6 slotów w rzędzie |
| Brak minimapy, brak kompasu, brak quest logu, brak wskaźnika celu | — | orientacja = światło i dźwięk |

**Czytelność (mierzalna):**
- Minimalny rozmiar fontu: 22 px przy 1080p (skalowanie UI 0,75–1,5).
- Kontrast tekstu do tła ≥ 4,5:1 (WCAG AA).
- Napisy: prędkość 40 znaków/s, minimalny czas wyświetlenia 3,5 s.
- Prompt interakcji zawsze w tym samym miejscu ekranu (dół, 18% wysokości).

**Dostępność (4 opcje, nie więcej):** remap, rozmiar napisów (3 stopnie),
inwersja Y, wyłączenie drgań kamery (wstrząs kamery jest jednym z głównych
nośników strachu — musi być wyłączalny).

---

## 9. Audio

**Zasada:** horror to tempo i audio, nie liczba mechanik. Dźwięk jest
głównym nośnikiem informacji o wrogu — gracz musi móc **usłyszeć** wroga
zanim go zobaczy.

| Warstwa | Zawartość | Głośność | Uwagi |
|---|---|---|---|
| Ambient bazowy | wiatr, oddech wsi | −18 LUFS | pętla 60–90 s, crossfade 3 s między fazami |
| Ambient lokalny | las, woda, wnętrza | −20 LUFS | `AudioStreamPlayer3D`, max 8 jednocześnie |
| Diegetyczne | kroki, świeca, drzwi, broń | −12 LUFS | 3 warianty kroków (chodnik, ziemia, drewno) |
| Sygnały wroga | kroki wroga, oddech, „zauważenie” | −9 LUFS | **słyszalne z 20 m (Dzień) / 25 m (Zmierzch, Noc)**, celowo głośniejsze niż ambient |
| Muzyka | 3 utwory (1/faza) + 2 stingery | −18 LUFS | stinger: start pościgu, śmierć |
| Finał | 2 cue (po jednym na zakończenie) | −16 LUFS | |

- **Brak dubbingu** (poza zakresem) — wszystkie kwestie tekstowe, wokalizacje
  wroga to niewerbalne warstwy (oddech, kroki, krzyk).
- Master: peak −6 dBFS, bez normalizacji do −14 LUFS (horror potrzebuje dynamiki).
- Muzyka nie gra w pętli w walce — stinger + cisza jest straszniejsza niż
  loop. Uzasadnienie: tańsze i skuteczniejsze.
- Dźwięk faz: Dzień = ptaki + wiatr; Zmierzch = owady + dzwon (diegetyczny);
  Noc = niski drone + woda + pojedyncze odgłosy. Szczegóły: `docs/day-night.md`.
- **Ryzyko:** 7 cue'ów muzycznych + ambienty to realny koszt. Mitygacja:
  licencjonowane pakiety + 2 autorskie utwory. Właściciel: `artist` (zakup),
  `programmer` (integracja).

---

## 10. Rejestr stałych balansu

Jedno źródło prawdy. Każda zmiana wartości wymaga aktualizacji tego wiersza,
`docs/day-night.md` i `docs/acceptance.md`. Właściciel = agent, który
implementuje lub dostarcza wartość.

| ID | Nazwa | Wartość | Uzasadnienie | Właściciel |
|---|---|---|---|---|
| BAL-01 | HP gracza | 100 | okrągła baza, 4 trafienia wariantu B = śmierć | programmer |
| BAL-02 | Prędkość chodu | 2,0 m/s | PS2-horror (SH2 ≈ 1,9), tempo eksploracji | programmer |
| BAL-03 | Prędkość sprintu | 4,2 m/s | > 2,8 m/s wariantu A, ucieczka zawsze możliwa | programmer |
| BAL-04 | Prędkość crouch | 1,1 m/s | wolniej niż wariant C (1,4) — skradanie to ryzyko | programmer |
| BAL-05 | Prędkość w celowaniu | 1,2 m/s | kara za celowanie, wymusza planowanie | programmer |
| BAL-06 | Stamina / drain / regen | 100 / 20/s / 12/s po 1,5 s | 5 s sprintu = 21 m = jeden korytarz | programmer |
| BAL-07 | Leczenie przy świecy | pełne 100 HP | eliminuje system apteczek | programmer |
| BAL-08 | I-frames po trafieniu | 0,6 s | mniej = stunlock, więcej = brak presji | programmer |
| BAL-09 | Śmierć → retry | ostatni save, else checkpoint aktu | brak utraty 100 min postępu | programmer |
| BAL-10 | Obrażenia pistoletu | 25 | 2 strzały A, 4 B, 6 C | programmer |
| BAL-11 | Zasięg pistoletu | 30 m max, pełny ≤18 m, −50% do 30 m | ulica ma ~40 m — trzeba podejść | programmer |
| BAL-12 | Rozrzut pistoletu | 0,9° / 2,0° / 7° (hip) | hip-fire bezużyteczny = wymuszone celowanie | programmer |
| BAL-13 | ROF / reload pistoletu | 0,45 s / 1,6 s | 1,6 s to okno na atak wroga | programmer |
| BAL-14 | Obrażenia strzelby | 60 (10 × 6) | 1 strzał A, 2 B, 3 C | programmer |
| BAL-15 | Zasięg strzelby | pełny ≤4 m, 0 na 9 m, stożek 8° | broń do ciasnych wnętrz, nie do ulicy | programmer |
| BAL-16 | ROF / reload strzelby | 0,9 s / 0,6 s na nabój | przeładowanie przerywalne = decyzja | programmer |
| BAL-17 | Mnożnik headshot | ×2 (tylko pistolet) | nagroda za precyzję, nie zmienia ekonomii | programmer |
| BAL-18 | Amunicja pistoletu (I/II/III) | 44 = 14 / 16 / 14 | 1100 dmg; pełny clear wymaga 82% celności | level-designer |
| BAL-19 | Amunicja strzelby (I/II/III) | 10 = 0 / 6 / 4 | 600 dmg; broń wchodzi w Akcie II | level-designer |
| BAL-20 | Wariant A — profil | HP 50, 2,8 m/s, 1,6 m, 15 dmg, 1,4 s, windup 0,35 s | pościg, zabija w 9,8 s | programmer |
| BAL-21 | Wariant B — profil | HP 100, 1,9 m/s, 2,0 m, 25 dmg, 1,8 s, windup 0,5 s | standard, zabija w 5,4 s | programmer |
| BAL-22 | Wariant C — profil | HP 150, 1,4 m/s, 2,5 m, 30 dmg, 2,6 s, windup 0,8 s | tank, zabija w 7,8 s | programmer |
| BAL-23 | Percepcja wzrokowa | 100°, 18/14/10 m, +6 m latarka | faza dnia = mechanika, nie filtr | programmer |
| BAL-24 | Percepcja słuchowa | strzał 45, sprint 12, chód 4, crouch 0 m | sprint ma cenę, crouch jest cichy | programmer |
| BAL-25 | Leash pościgu | 20 / 35 / 60 m (Dzień/Zmierzch/Noc) | noc = brak bezpiecznych stref | programmer |
| BAL-26 | Czas search | 20 s / 25 s (Noc) | dość, by przeczekać, za mało, by się nudzić | programmer |
| BAL-27 | Stagger od broni | pistolet 0,15 s; strzelba 0,6/0,4/0,25 s | strzelba = kontrola tłumu | programmer |
| BAL-28 | Liczba wrogów | 14 (4 A / 6 B / 4 C) | 1400 dmg wymagane vs 1700 dostępne = 82% celności na full clear | level-designer |
| BAL-29 | Respawn | brak | przewidywalna ekonomia, testowalność | programmer |
| BAL-30 | Kamera OTS | 2,2 m / 1,5 m, offset 0,45 m, h 1,55 m | widoczność celu i otoczenia | programmer |
| BAL-31 | FOV | 65° / 50° (celowanie) | PS2-era, mniej chorób lokomocyjnych | programmer |
| BAL-32 | Czułość | mysz 2,0, pad 2,5 (zakres 0,5–6,0) | domyślna wartość z playtestu | programmer |
| BAL-33 | Kolizja kamery | sfera 0,25 m | brak przenikania przez ściany wnętrz | programmer |
| BAL-34 | Quick-turn | 180° / 0,35 s | ciasne korytarze, OTS bez tego boli | animator |
| BAL-35 | Świece (I/II/III) | 6 = 2 / 2 / 2 | 90–180 s marszu między nimi | level-designer |
| BAL-36 | Sloty zapisu | 3 manualne + 1 auto | ≠ 6 slotów plecaka | programmer |
| BAL-37 | Czas zapisu | 2,5 s animacja + 0,4 s zapis + i-frames 2,5 s | brak przerwania przez wroga; świece w osłoniętych wnękach | programmer |
| BAL-38 | Auto-checkpointy | 2 (przejścia faz) | gracz bez save'a nie traci aktu | programmer |
| BAL-39 | Sloty plecaka | 6 (3 bronie/light + 3 przedmioty) | maks. 3 przedmioty zagadkowe naraz | programmer |
| BAL-40 | Promień interakcji | 2,5 m, stożek 60°, 0,4 s | czytelne w 640×480 | programmer |
| BAL-41 | Zakończenia | 2, flaga tylko z P3 | 3. zakończenie = +1 scena, +QA, zero zysku | writer |
| BAL-42 | Zagadki | 3 (łańcuch / sekwencja / wybór) | eskalacja typu, nie liczby | level-designer |
| BAL-43 | Czas przejścia | 105 min cel, 90–120 zakres | zakres v1 | game-designer |
| BAL-44 | Budżet aktów | 2 / 28 / 38 / 33 / 4 min | patrz §4 | game-designer |
| BAL-45 | Czas przejścia faz | 30 s / 45 s | bez cięcia kamery, gracz ma kontrolę | programmer |
| BAL-46 | Trigger faz | P1 / P2; fallback 28/66 min od startu Aktu I **tylko po rozwiązaniu danej zagadki** | fallback to redundancja triggera, nie obejście bramki | level-designer |
| BAL-47 | Oczekiwane śmierci | 2–4 na pierwsze przejście | balans świec i amunicji | game-designer |
| BAL-48 | Wydajność | 60 FPS @1080p, 40 FPS Steam Deck | target sprzętowy | programmer |
| BAL-49 | Budżet renderu | ≤250 draw calls, ≤350k tri | PS2-style, ale Godot 4.7 | programmer |
| BAL-50 | Czas ładowania | ≤8 s SSD / ≤15 s HDD | jedna scena levelu, brak strumieniowania | programmer |
| BAL-51 | Budżet świateł | ≤12 omni, ≤2 cienie | noc bez lawiny draw calls | programmer |
| BAL-52 | Tekstury | świat 256², drobne propsy 128², postacie/portrety 512² | estetyka PS2 (640×480) + pamięć; zgodne z `docs/art-bible.md` §4 i §8 | artist |
| BAL-53 | Lokalizacja | PL + EN, ~9 000 słów, ≤400 stringów UI | 105 min, 4 NPC | writer |
| BAL-54 | Napisy | 42 znaki/linia, maks. 2 linie | czytelność 640×480 | programmer |
| BAL-55 | Rozdzielczość wewn. | 640×480 upscale, UI natywne | look PS2, UI czytelne | programmer |
| BAL-56 | Ópi (B) — ruch tylko niewidziany | „widziany” = w kadrze + LOS + w zasięgu widzenia (60/35/12 m, +8 m latarka) + oczy otwarte (`blink_alpha` < 0,5) | mruganie jako narzędzie unikania; nowy stan AI, nie nowy typ wroga | programmer |

---

## 11. Vertical slice

**VS-1 „Pierwsza ulica”** to 20–25-minutowy wycinek obejmujący ulicę V1, plac
SQ, jedno wnętrze (I-1) i wejście do korytarza leśnego F1, rozgrywany w fazie
Dnia z przejściem Dzień→Zmierzch na końcu. Zawiera **wszystkie systemy
produkcyjne**: kamerę OTS, celowanie, pistolet i strzelbę (obie dostępne od
razu, żeby przetestować ekonomię), warianty A i B wroga, zagadkę P1 (łańcuch
3 przedmiotów), 2 świece (zapis + leczenie), 1 NPC z dialogiem, plecak 6
slotów, PL/EN i pełne sterowanie pad + klawiatura. Slice nie zawiera zagadek
P2/P3, wariantu C, Aktu III ani zakończeń — ale **każdy system, który w nich
wystąpi, jest tu obecny w wersji finalnej**, więc dalsza praca to układanie
treści, nie pisanie systemów. Kryteria odbioru: `docs/acceptance.md` §A.

---

## 12. Ryzyka

| # | Ryzyko | Wpływ | Mitygacja | Właściciel |
|---|---|---|---|---|
| R1 | 105 min treści nie powstanie w 10 h/tydz. | wysoki | VS-1 najpierw; akty II–III budowane z klocków VS-1; cięcie zagadek zabronione, cięcie dokumentów dozwolone | game-designer |
| R2 | Jedna geometria w 3 fazach = „za mało nowych miejsc” | średni | 3 nowe drogi na fazę + nowy wariant wroga + nowe światło; test „czy gracz rozpoznaje miejsce, ale się boi” | level-designer |
| R3 | AI wroga w Godot 4.7 (NavigationAgent3D) niestabilne w ciasnych wnętrzach | wysoki | 2 korytarze leśne i wnętrza projektowane jako ≥1,5 m szerokości; bake navmesh per strefa | programmer |
| R4 | Audio: 7 cue'ów + 3 ambienty to koszt | średni | licencja pakietów + 2 autorskie; audio wcześniej niż level Artu III | artist |
| R5 | Ekonomia amunicji za ciasna (gracz utyka) | wysoki | playtest po VS-1: cel 70% trafień; fallback +4 naboje w Akcie III | game-designer |
| R6 | Look PS2 (640×480) nieczytelny na 1440p | średni | UI natywne, upscale nearest + opcja „sharp” | programmer |
| R7 | Nazwy folkloru spóźnione → blokują dialogi | średni | bestiariusz w tej samej fali; do czasu gotowy placeholder `wariant A/B/C` | writer |
| R8 | Scope creep z backlogu wchodzi do v1 | wysoki | zasada zmiany zakresu w `docs/scope.md` §4, zatwierdza Mariusz | game-designer |

---

## 13. Zależności i otwarte pytania

1. **`docs/bestiary.md`** — v0.1 istnieje: warianty **A — Głodny**,
   **B — Ópi**, **C — Stary**; imiona NPC i terminologia ludowa.
   Pozostają wpisy **DO WERYFIKACJI** (strony źródeł, wymowy) — blokują
   produkcyjne dialogi, nie GDD. Właściciel: `writer`.
2. **`docs/level-bible.md`** — konkretne rozmieszczenie 6 świec, 14 wrogów i
   3 zagadek w strefach V1–V3/SQ/I-1…I-4/F1–F2/L1. Właściciel: `level-designer`.
   GDD ustala **liczby**, level-bible ustala **współrzędne**.
3. **`docs/anim-list.md`** — lista animacji wynikająca z BAL-34 (quick-turn),
   windupów wroga i 3 wariantów. Właściciel: `animator`.
4. **`docs/art-bible.md`** — paleta 3 faz, look PS2 (dither, affine). Właściciel:
   `artist`.
5. Otwarte: docelowa rozdzielczość wewnętrzna 640×480 vs 640×360 — decyzja po
   VS-1 na podstawie czytelności napisów (BAL-55).
6. Otwarte: czy demo przenosi save do pełnej wersji — domyślnie **nie**
   (koszt), kandydat do backlogu P1.
7. **`docs/art-bible.md`** — zsynchronizowany 2026-10-29 (Noc 12/20 m,
   tekstury 256²/128²/512²); brak otwartego konfliktu liczbowego.
8. **Bestiariusz a fazy:** Mòra opisana jako „efekt nocny w I-3, L1 i I-4”.
   I-3 jest dostępne w Zmierzchu, nie w Nocy — efekt w I-3 musi być
   zmierzchowy albo przenieść go do I-4/L1. Jeśli efekt ma zależeć od
   „wiedzy gracza”, musi używać istniejących flag (dokumenty/P1–P3); nowy
   system wiedzy → backlog. Decyzja: `writer` + `level-designer`.
9. **Bestiariusz a NPC/zagadki:** Bòrowô Cotka i Krôsniãta muszą zmieścić się w
   4 NPC i 3 zagadkach; test Bòrowô Cotki nie może być czwartą zagadką ani
   ustawiać `ending_flag`. Skrót Bòrowô Cotki nie może pomijać zagadki/fazy
   ani skracać 90–120 min — może tylko skrócić traversal w tej samej strefie.
   Decyzja: `writer` + `game-designer` przy review.
