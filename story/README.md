# Trauma Village — konwencje narracji (Ink)

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Właściciel | `writer` |
| Status | draft do review Pucka / Mariusza |
| Powiązane | `docs/GDD.md`, `docs/scope.md`, `docs/bestiary.md`, `story/outline.md` |

Ten plik jest **kontraktem** między narracją a kodem. Jeśli Ink i Godot mają się
nie kłócić, obie strony czytają ten dokument przed zmianą.

---

## 1. Zasada nadrzędna

**Ink opowiada. Godot gra.**

Ink nie wie, czy drzwi są otwarte, ile jest amunicji, gdzie stoi wróg i czy
gracz rozwiązał zagadkę. Ink dostaje **fakty narracyjne** (co Marta wie, komu
ufa, co zobaczyła), a zwraca **tekst, wybory i tagi**. Wszystko, co jest
mechaniką — ruch, walka, drzwi, AI, amunicja, save — należy do Godota.

Zakazane w `.ink`:

- warunki na amunicję, HP, ekwipunek, pozycję, stan drzwi, stan AI;
- wywołania funkcji zewnętrznych (`EXTERNAL`) w v1;
- `-> END` i `-> DONE` — walidator `tools/ink_check.py` traktuje je jako
  nieznane knoty; scena kończy się przez wyczerpanie treści;
- znaczniki `TODO`, `FIXME`, `XXX` — walidator failuje;
- polskie znaki w nazwach knotów (walidator dopuszcza tylko ASCII).

---

## 2. Pliki i kolejność aktów

```
story/
  main.ink       # INCLUDE + VAR + wejście do Aktu I
  act1.ink       # Dzień   — V1, V2, V3, SQ, I-1, I-2
  act2.ink       # Zmierzch — F1, F2, I-3, L1, SQ
  act3.ink       # Noc     — SQ, I-4, L1, F2, kościół
  endings.ink    # 2 zakończenia (ENDING_1 / ENDING_2)
  README.md      # ten plik
  outline.md     # outline fabuły
```

**Kolejność aktów jest sztywna:** Akt I → Akt II → Akt III → finał. Brak
powrotu do poprzedniej fazy (`docs/GDD.md` §5). Godot ładuje kolejny akt, gdy
spełniony jest trigger fazy (P1/P2); Ink tylko przełącza entry knot.

**Mapowanie stref GDD → scena Ink:**

| Strefa | Akt | Entry knot |
|---|---|---|
| V1, V2, V3, SQ, I-1, I-2 | I | `act1_arrival`, `act1_square`, `act1_house`, `act1_mill` |
| F1, F2, I-3, L1, SQ | II | `act2_open` i pod-sceny |
| SQ, I-4, L1, F2, kościół | III | `act3_open` i pod-sceny |
| finał | III | `act3_final_choice` |

---

## 3. Konwencje ID knotów

- **Format:** `actN_<scena>[_<beat>]`, małe litery, cyfry, podkreślenia, ASCII.
- **N:** `1`, `2`, `3` — numer aktu. Finał: `ending_<nazwa>`.
- **Scena:** rzeczownik w mianowniku, bez polskich znaków, np. `hanna`, `mill`,
  `church`, `forest`, `tower`.
- **Beat:** opcjonalny podknot, np. `act1_hanna_father`.
- **Hub:** scena z wyborami i wyjściem, np. `act1_hanna_hub`. Hub może mieć
  pętlę, ale **musi** mieć wybór wyjścia.
- **Stitch:** tylko gdy scena ma wiele wariantów wejścia; nazwa jak knot,
  unikalna w całym projekcie (walidator traktuje stitch jak knot).
- **Zakaz:** `start`, `end`, `done`, `main` jako nazwy knotów — kolidują z
  konwencjami runtime i walidatora.

**Reachability.** Każdy knot musi być osiągalny z `act1_arrival` przez ciąg
divertów. Każdy wybór musi prowadzić do tekstu i divertu (albo do końca sceny
finałowej). Nie zostawiamy „martwych” wyborów, które tylko ustawiają zmienną.
Mapa osiągalności: `story/outline.md` §8.

---

## 4. Zmienne narracyjne

Wszystkie deklaracje w `main.ink`. Typy: `0/1` (liczba), `true/false` (bool),
`""` (string). Ink nie zna typów — to konwencja.

| Zmienna | Typ | Start | Znaczenie | Kto ustawia |
|---|---|---|---|---|
| `trust_hanna` | int | 0 | zaufanie Hanny; wpływa na info o pakcie | Ink |
| `trust_priest` | int | 0 | zaufanie księdza; wpływa na dostęp do rejestru | Ink |
| `trust_wiktor` | int | 0 | zaufanie Wiktora; wpływa na broń i finał | Ink |
| `knows_pact` | bool | false | Marta wie o pakcie co siedem lat | Ink |
| `knows_mother` | bool | false | Marta zna prawdę o Zofii (2019) | Ink |
| `knows_offering` | bool | false | Marta wie, że Ewa jest tegoroczną ofiarą | Ink |
| `knows_birthright` | bool | false | Marta wie, że urodziła się w czepku | Ink |
| `knows_head` | bool | false | Marta wie, gdzie jest „głowa dzwonu” | Ink |
| `knows_rite` | bool | false | Marta zna pełny rytuał (3 zwrotki) | Ink |
| `cotka_help` | bool | false | Bòrowô Cotka pomaga | Ink |
| `father_found` | bool | false | Marta znalazła Antoniego | Ink |
| `mercy` | int | 0 | miłosierdzie vs. pragmatyzm; wpływa na epilog | Ink |
| `bell_count` | int | 0 | liczba usłyszanych uderzeń o zmierzchu | Ink |
| `found_key` | bool | false | Marta znalazła klucz organisty (P1) | Ink |
| `found_pin` | bool | false | Marta ma sworzeń dzwonu (P1) | Ink |
| `found_hymn` | bool | false | Marta otworzyła szafę na chórze (P1) | Ink |
| `witness_flag` | bool | false | Jadwiga przeżyła i spisała świadectwo | Ink |

**Zmienne Godota (nie deklarujemy ich w Ink):**

`has_bell_key`, `has_shotgun`, `ammo_pistol`, `ammo_shotgun`, `candle_lit_1..6`,
`door_*`, `puzzle_p1_solved`, `puzzle_p2_solved`, `enemy_variant`,
`player_hp`, `phase`, `ending_flag`.

Jeśli Ink potrzebuje jednej z tych wartości do dialogu, Godot **przepisuje** ją
do zmiennej narracyjnej przed wejściem w knot (np. `knows_rite`). Ink nigdy nie
czyta `ammo_pistol`.

---

## 5. Tagi (Ink → Godot)

Tagi są jednokierunkowym sygnałem. Godot może je ignorować; Ink nie może na nich
polegać. Format: `# namespace:value`.

| Tag | Znaczenie | Przykład |
|---|---|---|
| `# chapter:act1` | akt | `# chapter:act1` |
| `# location:v1` | strefa GDD | `# location:SQ` |
| `# portrait:hanna` | portret NPC | `# portrait:priest` |
| `# speaker:hanna` | kto mówi (jeśli nie da się z kontekstu) | `# speaker:cotka` |
| `# event:bell_dusk` | zdarzenie świata | `# event:first_death` |
| `# event:road_blocked` | zdarzenie świata | |
| `# event:enemy_variant` | podpowiedź wariantu wroga | `# event:enemy_variant_glodny` |
| `# sfx:bell_once` | dźwięk diegetyczny | `# sfx:bell_once` |
| `# music:night_drone` | muzyka | |
| `# ending:bell` | zakończenie | `# ending:bell` |

**Zasada:** tag nie zawiera logiki. `# event:enemy_variant_glodny` mówi
„pokaż wariant A”, a nie „spawnuj 4 wrogów”. Liczby i pozycje są w Godocie.

---

## 6. Kontrakt podłączenia Ink → Godot

### 6.1 Runtime

- Silnik: Godot 4.7 + runtime Ink (inklecate/inkgd albo port). Wersja runtime
  jest **spike'em** do zamknięcia przed VS-1; do tego czasu traktujemy kontrakt
  jako docelowy.
- Plik źródłowy: `story/main.ink` kompilowany do `story/main.ink.json`
  (artefakt buildowy, nie commitowany — dopisać do `.gitignore`).
- Jedna instancja `InkStory` na scenę narracji. Nie tworzymy osobnej instancji
  per NPC.

### 6.2 Wejście w scenę

Godot wybiera **entry knot** na podstawie stanu świata:

```gdscript
# pseudo-kod kontraktu, nie implementacja
story.ChoosePathString("act2_open")
_apply_narrative_variables()   # trust_*, knows_*, mercy
_advance_until_choices_or_tag()
```

Dozwolone entry knoty:

| Akt | Entry knot | Kiedy |
|---|---|---|
| I | `act1_arrival` | start gry / po intro |
| I | `act1_square` | powrót na plac po scenie |
| I | `act1_house` | wejście do I-1 |
| I | `act1_mill` | wejście do I-2 |
| II | `act2_open` | trigger P1 / przejście fazy |
| II | `act2_church` | wejście do SQ/kościoła |
| II | `act2_school` | wejście do I-3 |
| II | `act2_forest` | wejście do F1 |
| II | `act2_lake` | wejście do L1 |
| II | `act2_cemetery` | wejście do F2 |
| II | `act2_father` | drzwi dzwonnicy po `knows_pact` |
| III | `act3_open` | trigger P2 / przejście fazy |
| III | `act3_cemetery` | wejście do F2 |
| III | `act3_tower` | wejście do I-4 |
| finał | `act3_final_choice` | po scenie wariantu wroga |

### 6.3 Wyjście ze sceny

Ink zwraca:

- **tekst** — do UI napisów (42 znaki/linia, maks. 2 linie; `docs/GDD.md` §8);
- **wybory** — do UI wyboru (maks. 4 widoczne; jeśli więcej, Godot paginuje);
- **tagi** — do eventów świata;
- **stan** — `story.state.ToJson()` do save'a.

Godot **nie parsuje** tekstu w poszukiwaniu komend. Jeśli coś ma się stać,
robisz to tagiem, nie słowem „otwórz drzwi” w dialogu.

### 6.4 Zapis i wczytanie

- Save zapisuje: `phase`, `player_hp`, amunicję, pozycję, 6 booli świec,
  flagi zagadek, `ending_flag` oraz `ink_state_json`.
- Wczytanie: Godot odtwarza stan świata, potem `story.state.LoadJson(...)`,
  potem `ChoosePathString(<entry knot aktualnej sceny>)`.
- **Nie zapisujemy** stanu w środku wyboru. Zapis tylko przy świecy
  (`docs/GDD.md` §6.7), więc Ink zawsze wznawia się na entry knot.

### 6.5 Lokalizacja

- PL jest źródłem. Tekst w Ink jest polski.
- EN: docelowo osobny plik `story/en/main.ink` albo string table; decyzja
  przed VS-1. **Nie** wstawiamy tłumaczeń w komentarzach Ink.
- Nazwy własne i terminy kaszubskie zostają w PL; w EN dostają przypis
  (np. *wieszczy — Kashubian revenant*).
- UI: ≤400 stringów (`docs/scope.md` §6). Dialogi nie są UI.

### 6.6 Testy

- `python3 tools/ink_check.py` — statyczna walidacja: nawiasy, diverty,
  duplikaty knotów, znaczniki. **Musi być zielone przed review.**
- Docelowo: kompilacja `inklecate` i test „każdy entry knot się otwiera”.
  Do czasu runtime'u — test ręczny w Godocie.
- Test reachability: przejść `story/outline.md` §8 i sprawdzić, że każdy knot
  ma wejście.

---

## 7. Konwencje tekstu

- **Język:** polski, współczesny, 2026. Kaszubski jako wstawka, nie
  „gwara dla ozdoby”.
- **Kaszubski:** maks. 1–2 krótkie wstawki na scenę, zawsze z kontekstem.
  Nie odmieniamy na siłę; jeśli nie masz pewności — użyj polskiego.
- **Słownik wstawke:** `bòk` (Bóg), `dzëk` (dziękuję), `dobré` (dobrze),
  `mëma` (mama), `tatk` (tata), `jô` (ja), `wòda` (woda), `las` (las),
  `zwón` (dzwon). Każda wstawka ma odpowiednik w przypisie/notatce.
- **Długość sceny:** 6–12 linii narracji + 2–4 kwestie. Skeleton, nie powieść.
- **Dialog:** każda kwestia ma mówcę; narrator bez prefiksu. Nie piszemy
  „Marta: (myśli)” — myśli jako narracja.
- **Horror:** sugerujemy, nie opisujemy wnętrzności. Jedna konkretna rzecz
  (dźwięk, zapach, cień) działa lepiej niż lista.
- **Brak współczesnego slangu** („spoko”, „ogarnąć”) — to 2026, ale wieś;
  używamy języka neutralnego, nie archaizujemy.
- **Brak przecinków zamiast kropek** w tagach i nazwach.

---

## 8. Mapa osiągalności knotów (skrót)

```
act1_arrival
├── act1_hanna_intro → act1_hanna_hub
│   ├── act1_hanna_father → hub
│   ├── act1_hanna_bell → hub
│   ├── act1_hanna_mother → hub
│   └── act1_square
├── act1_square
│   ├── act1_priest
│   │   ├── act1_priest_bell → priest
│   │   └── act1_priest_father → priest
│   ├── act1_wiktor
│   │   ├── act1_wiktor_ewa → wiktor
│   │   └── act1_wiktor_father → wiktor
│   ├── act1_jadwiga
│   │   ├── act1_jadwiga_verse → jadwiga
│   │   └── act1_jadwiga_mother → jadwiga
│   ├── act1_house → act1_study / act1_letter → house
│   ├── act1_mill → act1_mill_canal / act1_mill_verse → mill
│   └── act1_porch (gdy found_key && found_pin) → act1_dusk
├── act1_house
│   ├── act1_study → house
│   └── act1_letter → house
└── act1_dusk → act2_open

act2_open
├── act2_church → act2_church_register / act2_church_priest → church
├── act2_school → act2_school_photo / act2_school_ledger → school
├── act2_forest → act2_forest_test / act2_forest_verse → forest
├── act2_lake → act2_lake_wiktor / act2_lake_zofia → lake
├── act2_cemetery → act2_cemetery_grave / act2_cemetery_verse → cemetery
├── act2_father → act2_father_truth / act2_father_mercy → father / turning
└── act2_turning → act3_open

act3_open
├── act3_survivors → act3_survivors_hanna / _wiktor / _jadwiga → survivors
├── act3_cemetery → act3_cemetery_grave → cemetery
└── act3_tower
    ├── act3_wieszczy_glodny → act3_final_choice
    ├── act3_wieszczy_dzwonnik → act3_final_choice
    └── act3_wieszczy_stary → act3_final_choice
        ├── ending_bell
        └── ending_silence
```

---

## 9. Checklist przed dodaniem sceny

- [ ] Knot ma nazwę zgodną z §3 i jest unikalny w całym projekcie.
- [ ] Każdy wybór prowadzi do tekstu i divertu (albo do końca finału).
- [ ] Scena ma wyjście (hub nie jest pułapką).
- [ ] Nie ma logiki gry (drzwi/AI/amunicja/HP).
- [ ] Tagi są z §5, bez liczb i pozycji.
- [ ] Tekst PL, wstawki kaszubskie z kontekstem.
- [ ] Brak `TODO`, `FIXME`, `XXX`, `-> END`.
- [ ] `python3 tools/ink_check.py` zielony.
- [ ] Jeśli scena zmienia fabułę — aktualizacja `story/outline.md`.

---

## 10. Historia zmian

| Wersja | Data | Zmiana | Autor |
|---|---|---|---|
| 0.1 | 2026-10-29 | Pierwszy kontrakt Ink ↔ Godot, konwencje ID, zmienne, tagi | `writer` |

---

## 11. Dokumenty VS-1

Czytelne notatki slice'a leżą w `story/documents_vs.json` (schema:
`documents[]` z polami `id`, `title_pl`, `body_pl`, `title_en`, `body_en`,
`source`). PL jest źródłem, EN wiernym tłumaczeniem. Pola tekstowe nie mogą
być puste; w treści nie ma placeholderów ani logiki gry.

| ID | Tytuł PL | Strefa | Źródło |
|---|---|---|---|
| `note_father_I1` | List Antoniego | I-1 | `act1.ink` `act1_letter` (wierny tekst + opis odwrotu); `outline.md` §7.1, §11 |
| `note_ledger_SQ` | Rachunek remontu dzwonu 1898 | SQ | `outline.md` §7.1, §11; `docs/level-bible.md` §7.4; kwoty fikcją gry |
| `note_well_SQ` | Lista imion Hanny (fragment) | SQ | `outline.md` §7.1, §11; `act1.ink` `act1_hanna_intro`; tylko 1998/2005/2019/2026, bez 2012 |
| `note_first_verse` | Pierwsza zwrotka | SQ | `act1.ink` `act1_porch`; `outline.md` §7.1 P1; bez nowych nazw folkloru |

**Uwaga o lokalizacji:** `note_ledger_SQ` leży w SQ zgodnie z markerem
`item_note_ledger_SQ` (`docs/level-bible.md` §7.4). `outline.md` §11 wymienia
rachunek przy I-1 — decyzja level-bible jest wiążąca dla slice'a.

**Decyzje redakcyjne (rewizja VS-1):**

- `note_father_I1` jest wierny `act1_letter`: bez dopisku o zaufaniu do
  „porządku”. Opis odwrotu (dzwon i trzy kreski, jedna przekreślona) pochodzi
  z tego samego knota.
- `note_well_SQ` zawiera wyłącznie lata z kanonu P2: 1998, 2005, 2019, 2026.
  Bez 2012. Starsze imiona pozostają wyblakłe; nie dodajemy imion ofiar spoza
  kanonu.
- Kwoty i daty w `note_ledger_SQ` są fikcją gry, nie danymi historycznymi.
- Dokumenty nie wprowadzają nowych nazw folkloru; imiona postaci są zgodne
  z `outline.md`.

---

## 12. Dialogi VS-1

`story/dialogues_vs.json` jest **deterministycznym bridge'em** dla VS-1:
eksportuje dialog Hanny Rekòwskô z knotów `story/act1.ink` do formatu JSON
przeznaczonego dla Godota, dopóki repo nie ma runtime Ink (§6.1). To nie jest
nowy kanon — źródłem pozostaje Ink.

| Węzeł JSON | Knot Ink | Rola |
|---|---|---|
| `intro` | `act1_hanna_intro` | wejście, przedstawienie Hanny i zeszytu z listą |
| `hub` | `act1_hanna_hub` | wybór tematów: ojciec, dzwon, matka, wyjście |
| `father` | `act1_hanna_father` | informacja o Antonim; `trust_hanna += 1` |
| `bell` | `act1_hanna_bell` | „dzwon bije, bo ktoś go prosi”; kieruje do księdza |
| `mother` | `act1_hanna_mother` | Zofia i „wieś jej nie zapomniała”; `knows_mother = true` |

**Zasady bridge'a:**

- PL jest źródłem; EN jest tłumaczeniem wiernym, bez skrótów.
- `next` wskazuje wyłącznie istniejące węzły albo `""` (wyjście z dialogu).
- `set` przenosi tylko flagi z Inka: `trust_hanna` (1) przy wyborze ojca,
  `knows_mother` (true) przy wyborze matki. Bridge nie dodaje logiki gry.
- Zmiana tekstu w `act1.ink` wymaga ponownego eksportu JSON; JSON nie jest
  źródłem.

**OPEN QUESTION / dependency:** runtime Ink pozostaje docelowy (§6.1). Bridge
JSON jest tymczasowy dla VS-1 i powinien zniknąć, gdy Godot dostanie działający
runtime Ink. Do tego czasu nie rozszerzamy schematu o mechanikę (drzwi,
amunicja, AI).
