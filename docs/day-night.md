# Empty Night — Dzień / Zmierzch / Noc

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Właściciel | `game-designer` (spec) / `level-designer` (rozmieszczenie) / `programmer` (implementacja) |
| Dotyczy | `docs/GDD.md` §5, §6.7, §10; `docs/acceptance.md` VS-F13, FG-F02 |

---

## 0. Zasada nadrzędna

**Jedna geometria. Trzy profile.**

Wszystkie trzy fazy rozgrywają się w **jednej scenie** `levels/village.tscn`
(11 stref: V1–V3, SQ, I-1…I-4, F1–F2, L1). Faza zmienia wyłącznie:

1. parametry `WorldEnvironment` (światło kierunkowe, ambient, mgła, sky),
2. energie/kolory istniejących świateł omni (nie tworzymy nowych węzłów),
3. stany `AudioStreamPlayer3D` (włącz/wyłącz + snapshot głośności),
4. stany kolizji istniejących drzwi/bram (open/closed),
5. zestaw aktywnych wrogów (despawn/spawn w istniejących punktach),
6. materiały/emittery oznaczonych obiektów (widoczne tylko w jednej fazie).

**Zakazane:** duplikowanie levelu, instancjonowanie nowych meshy przy przejściu,
streaming, osobne sceny per faza. Naruszenie = błąd review (`docs/scope.md` §5).

Uzasadnienie: przy 1 deweloperze duplikacja levelu oznacza 3× bugi nawigacji,
3× art pass i 3× QA. Jedna scena to także jedyny sposób, by gracz **rozpoznał**
miejsce i bał się go bardziej — a to jest cały sens projektu.

---

## 1. Macierz porównawcza

| Parametr | Dzień | Zmierzch | Noc |
|---|---|---|---|
| Czas w grze | 14:00–17:00 | 18:30–20:00 | 22:00–03:00 |
| Światło kierunkowe | Słońce | Słońce nisko | Księżyc |
| Energia kierunkowego | 1,15 | 0,55 | 0,12 |
| Ambient energy | 0,90 | 0,45 | 0,10 |
| Gęstość mgły | 0,016 | 0,045 | 0,085 |
| Widoczność | **60 m** | **35 m** | **12 m** (20 m z latarką) |
| Światła omni | 0 | 6 | 12 |
| Cienie (casters) | 1 | 1 | 2 |
| Warianty wroga | A | A, B | B, C |
| Leash pościgu | 20 m | 35 m | 60 m |
| Zasięg wzroku wroga | 18 m | 14 m | 10 m |
| Czas search | 20 s | 20 s | 25 s |
| Muzyka | ambient „dzień” | ambient „zmierzch” | ambient „noc” + drone |
| Świece zapalone | widoczne, nie pełnią roli latarni | widoczne | **główne latarnie nawigacyjne** |

---

## 2. Faza I — Dzień

**Nastrój:** wieś, która jeszcze udaje, że wszystko jest w porządku. Najdłuższe
widzenie w grze, najmniej wrogów, najwięcej NPC. To faza nauki i eksploracji.

### 2.1 Światło

| Element | Wartość |
|---|---|
| `DirectionalLight3D` kolor | `#FFF1DC` (ciepła biel) |
| Energia | 1,15 |
| Elewacja / azymut | 38° / 210° |
| Cień | 1 caster, mapa 1024², zasięg 40 m |
| Ambient (sky) | `#9FB8CC`, energia 0,90 |
| Sky top / horizon | `#7FA6C4` / `#D8DCD4` |
| Mgła — kolor | `#C6D0D4` |
| Mgła — gęstość | 0,016 (exponential) |
| Mgła — start | 12 m |
| **Widoczność** | **60 m** (dalej obiekty znikają w mgle) |
| Tonemap | Linear, exposure 1,0 (płaski look PS2) |
| Światła omni | **0** |

### 2.2 Dźwięk

| Warstwa | Zawartość | Głośność | Uwagi |
|---|---|---|---|
| Ambient bazowy | wiatr, ptaki | −18 LUFS | pętla 75 s |
| Ambient lokalny | F1: las; I-1/I-2: cisza wnętrza | −20 LUFS | max 4 emitery |
| Diegetyczne | kroki, otwieranie drzwi, świeca | −12 LUFS | |
| Sygnały wroga | kroki A z 20 m, oddech | −9 LUFS | celowo głośne |
| Muzyka | `amb_day` | −18 LUFS | spokojna, bez perkusji |

Brak sygnałów „niebezpieczeństwo” — gracz uczy się dźwięków wroga w dzień,
żeby rozpoznać je w nocy.

### 2.3 Drogi

| Strefa / przejście | Stan | Powód (diegetyczny, bez nowej geometrii) |
|---|---|---|
| V1, V2, V3, SQ | otwarte | — |
| I-1, I-2 | otwarte | — |
| F1 (wejście) | otwarte do bramy F1/F2 | brama zamknięta na zasuwę |
| F2 | **zamknięte** | zwalone drzewo blokuje przejście (mesh istnieje, collision on) |
| I-3 | **zamknięte** | drzwi zamknięte na klucz, który pojawia się w P1 |
| I-4 | **zamknięte** | wejście od jeziora, otwiera się dopiero po zmierzchu |
| L1 (brzeg) | **zamknięte** | furta nad jeziorem zamknięta (P1 ją otwiera w Akcie II) |
| Kościół (wnętrze SQ) | **zamknięte** | otwiera się dopiero w Nocy |

### 2.4 Wróg

- **Aktywne warianty:** tylko **A**. Instancje: **2**.
- Patrol: 2 punkty na strefę, prędkość 1,2 m/s (patrol), 2,8 m/s (pościg).
- Percepcja: wzrok 18 m / 100°, słuch wg BAL-24 (strzał 45 m, sprint 12 m,
  chód 4 m, crouch 0 m). Latarka: **+6 m**.
- Agresja: **niska**. Wróg nie wchodzi do wnętrz. Leash **20 m** — po 20 m
  porzuca pościg i wraca do patrolu. Search 20 s.
- Rola: nauczenie gracza, że wariant A jest szybki, ale kruchy (50 HP =
  2 strzały z pistoletu).
- Brak wariantów B i C w tej fazie — gracz nie może ich jeszcze zobaczyć.

---

## 3. Faza II — Zmierzch

**Nastrój:** światło ucieka, dźwięki gęstnieją, wioska pustoszeje. Gracz po raz
pierwszy musi **wybrać drogę** zamiast iść prosto.

### 3.1 Światło

| Element | Wartość |
|---|---|
| `DirectionalLight3D` kolor | `#FF8A3C` (pomarańcz) |
| Energia | 0,55 |
| Elewacja / azymut | 7° / 250° |
| Cień | 1 caster, mapa 1024², zasięg 30 m |
| Ambient (sky) | `#6A4E5E`, energia 0,45 |
| Sky top / horizon | `#4A3A55` / `#C4713F` |
| Mgła — kolor | `#8A6250` |
| Mgła — gęstość | 0,045 |
| Mgła — start | 7 m |
| **Widoczność** | **35 m** |
| Światła omni | **6** (4 latarnie uliczne + 2 przeswity z wnętrz) |
| Cienie omni | 1 caster (najbliższa latarnia) |

### 3.2 Dźwięk

| Warstwa | Zawartość | Głośność | Uwagi |
|---|---|---|---|
| Ambient bazowy | wiatr mocniejszy, owady | −18 LUFS | pętla 70 s |
| Ambient lokalny | F1/F2: las, L1: woda | −20 LUFS | max 6 emitterów |
| Diegetyczne | kroki, świeca, dzwon (P2) | −12 LUFS | dzwon jest elementem zagadki P2 |
| Sygnały wroga | kroki A i B z 25 m | −9 LUFS | |
| Muzyka | `amb_dusk` | −18 LUFS | smyczki, narastające |

Dzwon jest **jedynym** dźwiękiem, który gracz musi zlokalizować kierunkowo —
dlatego w Zmierzchu ambient jest o 2 LUFS głośniejszy niż w Dniu (maskowanie
przestrzenne).

### 3.3 Drogi

| Strefa / przejście | Stan | Powód |
|---|---|---|
| V1, V2, V3, SQ | otwarte | — |
| I-1, I-2 | otwarte (puste) | — |
| F1 | otwarte w całości | — |
| F2 | **otwarte** | drzewo usunięte w ramach P1 (mesh przesuwa się, collision off) |
| I-3 | **otwarte** | klucz z P1 |
| L1 | **otwarte** | furta otwarta kluczem z P1 |
| I-4 | **zamknięte** | wejście od jeziora zaryglowane od środka |
| Kościół (wnętrze) | **zamknięte** | otwiera się w Nocy |

### 3.4 Wróg

- **Aktywne warianty:** **A (2)** i **B (4)**.
- Warianty A z Dnia **despawnują** przy przejściu (fade 2 s, poza kadrem).
- Patrol: 3 punkty na strefę; B patroluje 1,0 m/s, pościg 1,9 m/s.
- Percepcja: wzrok **14 m** / 100°, latarka +6 m. Słuch bez zmian.
- Agresja: **średnia**. Leash **35 m**. Search 20 s. Wróg wchodzi do I-3
  i na L1, ale **nie** do I-1/I-2 (strefy „bezpieczne” z Dnia zostają
  bezpieczne — gracz ma gdzie odetchnąć).
- Rola B: blokuje korytarze F1/F2, zmusza do strzelby lub obejścia.

---

## 4. Faza III — Noc

**Nastrój:** ta sama wioska, nie do przejścia. Widoczność 12 m, 12 świateł,
wariant C. Gracz nawiguje po świecach, nie po mapie.

### 4.1 Światło

| Element | Wartość |
|---|---|
| `DirectionalLight3D` kolor | `#7C90C0` (księżyc) |
| Energia | 0,25 |
| Elewacja / azymut | 50° / 130° |
| Cień | 1 caster, mapa 512², zasięg 15 m |
| Ambient (sky) | `#291F30`, energia 0,45 |
| Sky top / horizon | `#17121E` / `#382838` |
| Mgła — kolor | `#29303B` |
| Mgła — gęstość | 0,085 |
| Mgła — start | 2,5 m |
| **Widoczność** | **12 m bez latarki / 20 m z latarką** |
| Światła omni | **12** (6 świec + 4 latarnie + 2 przeswity) |
| Cienie omni | **2** casters (2 najbliższe świece) |

**Latarka:** `SpotLight3D` pod kamerą, klawisz **F**. W Nocy włącza się
automatycznie przy przejściu fazy; gracz może ją zgasić. Mały `OmniLight3D`
(range 5 m, energia 0,6) doświetla najbliższy grunt, żeby postać nie stała
w absolutnej czerni. Stożek ma 32°, zasięg 28 m i energię 8,0.

**Dlaczego latarka wydłuża widoczność do 20 m, a nie do 60 m:** stożek latarki
oświetla cząstki mgły wokół gracza, więc widoczność rośnie tylko lokalnie.
To jednocześnie uzasadnia mechanikę percepcji wroga (+6 m) — światło zdradza.

### 4.2 Dźwięk

| Warstwa | Zawartość | Głośność | Uwagi |
|---|---|---|---|
| Ambient bazowy | niski drone, wiatr | −18 LUFS | pętla 90 s |
| Ambient lokalny | woda L1, las F2, wnętrza | −20 LUFS | max 8 emitterów |
| Diegetyczne | kroki, świeca (trzask), drzwi | −12 LUFS | |
| Sygnały wroga | kroki B i C z 25 m, oddech C z 15 m | −9 LUFS | |
| Muzyka | `amb_night` + stinger przy starcie pościgu | −18 LUFS | stinger −15 LUFS |

**Poza zakresem v1:** adaptacyjna warstwa heartbeat przy niskim HP to dynamiczny
miks (scope §3) → `docs/backlog.md` BL-24.

### 4.3 Drogi

| Strefa / przejście | Stan | Powód |
|---|---|---|
| V1, V2, V3, SQ | otwarte | — |
| I-1, I-2 | **zamknięte** | NPC-3 zabarykadował drzwi od środka (mesh drzwi, collision on) |
| I-3 | otwarte | — |
| I-4 | **otwarte** | rygiel otwarty w ramach P2 |
| F1, F2 | otwarte | — |
| L1 | otwarte | — |
| Kościół (wnętrze SQ) | **otwarte** | otwiera się po P2 — strefa finału (P3) |

Zamknięcie I-1/I-2 jest **jedynym** zamknięciem w Nocy i jest celowe: gracz
traci dwie bezpieczne strefy dokładnie wtedy, gdy najbardziej ich potrzebuje.

### 4.4 Wróg

- **Aktywne warianty:** **B (2)** i **C (4)**.
- Warianty A i nadmiarowe B despawnują przy przejściu; nowe C to instancje
  z sumy 14, nie respawn zabitych.
- Patrol: 3 punkty; C patroluje 0,8 m/s, pościg 1,4 m/s.
- Percepcja: wzrok **10 m** / 100°, latarka +6 m. Słuch bez zmian, ale
  w Nocy **każdy** strzał ściąga wrogów z 45 m (nie tylko z tej strefy).
- Agresja: **wysoka**. Leash **60 m** — w praktyce pościg trwa do końca strefy.
  Search **25 s**. Wróg wchodzi wszędzie poza I-1/I-2 (zamknięte).
- Rola C: 150 HP wymusza strzelbę (3 strzały) albo obejście; nigdy nie jest
  „szybki” — jest nieunikniony, jeśli gracz stoi w miejscu.
- Brak respawnu — 4 warianty C to twardy limit Nocy.

---

## 5. Przejścia faz

| Przejście | Trigger główny | Fallback | Czas | Kontrola gracza |
|---|---|---|---|---:|---|
| Dzień → Zmierzch | rozwiązanie **P1** | 28 min od startu Aktu I, **tylko po P1** | **30 s** | pełna (bez cutscenki) |
| Zmierzch → Noc | rozwiązanie **P2** | 66 min od startu Aktu I, **tylko po P2** | **45 s** | pełna |

**Fallback jest redundancją triggera, nie obejściem zagadki.** Odpala się
wyłącznie po rozwiązaniu P1/P2 — chroni przed zbugowanym triggerem, ale nie
pozwala przeskoczyć bramki. Anty-softlockiem jest system 3 podpowiedzi: po
10 min bez rozwiązania poziom 2 (dokument), po 20 min poziom 3 (NPC).

**Krzywa przejścia (t = 0…1, ease-in-out):**
1. `t = 0,00` — start; gracz może się ruszać.
2. `t = 0,00–0,35` — lerp energii i koloru światła kierunkowego + ambientu.
3. `t = 0,35–0,70` — lerp koloru i gęstości mgły; crossfade audio 3 s.
4. `t = 0,70–0,95` — włączanie/wyłączanie świateł omni (próg 0,5 energii).
5. `t = 0,95–1,00` — despawn starych wrogów (fade 2 s) + spawn nowych poza
   kadrem; przełączenie stanów drzwi.

**Czas trwania uzasadniony:** 30 s to ok. 60 m marszu — gracz zdąży zobaczyć
zmianę światła na tej samej ulicy, którą właśnie przeszedł. 45 s jest dłuższe,
bo Noc zmienia więcej (12 świateł, nowe warianty) i gracz musi mieć czas
zauważyć, że zrobiło się naprawdę ciemno, zanim zobaczy pierwszego C.

**Brak przejść powrotnych.** Gra jest linearna; powrót do Dnia wymagałby
cofania stanu wrogów i drzwi — koszt bez zysku.

---

## 6. Wpływ na zagadki i świece

### 6.1 Zagadki

| Zagadka | Faza | Bramkuje | Wpływ fazy na zagadkę |
|---|---|---|---|
| P1 | Dzień | przejście do Zmierzchu | przedmioty nie znikają; w Dzień są podświetlone (emitter), w późniejszych fazach nadal interaktywne — brak softlocka |
| P2 | Zmierzch | przejście do Nocy | dzwon słyszalny tylko w Zmierzchu (ambient −2 LUFS maskuje kierunek); sekwencja wymaga 4 dźwięków |
| P3 | Noc | zakończenie | wybór w kościele; oświetlenie tylko świecami — gracz dosłownie widzi tylko to, co wybrał |

**Zasada:** żadna zagadka nie wymaga przedmiotu z innej fazy. P1 kończy się
w Dniu, P2 w Zmierzchu, P3 w Nocy — brak zależności wstecznych, brak softlocka.

### 6.2 Świece

- **6 świec**: Akt I 2, Akt II 2, Akt III 2 (BAL-35).
- Świeca po zapaleniu **pali się we wszystkich kolejnych fazach** — stan jest
  zapisany jako 6 booli.
- Rola świecy zależy od fazy:
  - **Dzień:** punkt zapisu i leczenia; światło ledwo widoczne (2 m).
  - **Zmierzch:** punkt zapisu; światło 4 m, zaczyna być landmarkiem.
  - **Noc:** punkt zapisu + **główna latarnia nawigacyjna** (6 m) + jedno
    z 12 świateł omni. Gracz porusza się „od świecy do świecy”.
- Zapis i leczenie działają identycznie w każdej fazie (BAL-07, BAL-36).
- Świeca nigdy nie gaśnie — brak zarządzania olejem/woskiem (poza zakresem).
- Odległość między świecami: **90–180 s** marszu (≈ 145–290 m przy 1,6 m/s).

---

## 7. Wymagania techniczne

### 7.1 Struktura

```
levels/village.tscn              # JEDYNA scena levelu
  PhaseController (autoload)     # apply_phase(phase_id, duration)
  WorldEnvironment               # 1 węzeł, lerpowane parametry
  DirectionalLight3D             # 1 węzeł, lerpowany kolor/energia/rotacja
  OmniLights/                    # 12 węzłów istnieje ZAWSZE, energia 0 gdy nieaktywne
  AudioEmitters/                 # wszystkie emitery istnieją, enable/disable
  Doors/                         # mesh + collision, stany open/closed
  EnemySpawns/                   # punkty spawnu, nie wrogowie
  Candles/                       # 6 węzłów, stan zapalony/nie
src/phase/
  phase_day.tres                 # PhaseProfile
  phase_dusk.tres
  phase_night.tres
```

### 7.2 `PhaseProfile` — pola

| Pole | Typ | Uwaga |
|---|---|---|
| `sun_color`, `sun_energy`, `sun_rotation` | Color, float, Vector3 | lerpowane |
| `ambient_color`, `ambient_energy` | Color, float | lerpowane |
| `sky_top`, `sky_horizon` | Color | lerpowane |
| `fog_color`, `fog_density`, `fog_start` | Color, float, float | lerpowane |
| `shadow_distance`, `shadow_map_size` | float, int | przełączane na końcu |
| `omni_budget` | int | 0 / 6 / 12 — walidowane testem |
| `shadow_casters` | int | 1 / 1 / 2 — walidowane testem |
| `enemy_set` | Array[String] | np. `["A","A"]` |
| `door_states` | Dictionary | `{ "I-3": "open", … }` |
| `audio_snapshot` | StringName | bus snapshot |
| `visible_objects` | Array[NodePath] | obiekty tylko dla tej fazy |

### 7.3 Wydajność i pamięć

- Wszystkie 12 świateł omni **istnieje od startu** z energią 0 — brak
  instancjonowania przy przejściu (unikamy hitchy).
- Podmiana profilu: **≤ 200 ms**, 0 klatek > 50 ms (VS-P06, VS-P08, FG-P09).
- Budżet: **≤ 12 omni, ≤ 2 cienie** (BAL-51). Test headless zlicza aktywne
  światła i failuje przy przekroczeniu.
- Culling: `OccluderInstance3D` na budynkach + mgła jako główny cull.
  Brak `VisibilityRange` na całych strefach (powoduje „wyskakujące” budynki
  w Nocy, gdy widoczność spada do 12 m).
- Wnętrza: `Portal`/`Room` **nie** w v1 — 4 wnętrza są małe, a portale to
  dodatkowa złożoność. Zamiast tego drzwi + fade 0,3 s przy wejściu.

### 7.4 Zapis stanu fazy

Save musi zawierać: `phase_id`, 6 booli świec, pozycję gracza, HP, amunicję,
flagi P1/P2/P3, `ending_flag`, `witness_flag`, stany drzwi, stan przedmiotów
zagadek, stan NPC oraz stany 14 wrogów (żywy/martwy/pozycja). Wczytanie musi
odtworzyć **dokładnie** ten sam profil fazy i te same drzwi — test: 10 cykli
save→load na każdej fazie (VS-F08, FG-F06).

### 7.5 Czego nie wolno zmieniać między fazami

| Element | Dlaczego |
|---|---|
| Meshe i ich transformacje | rozpoznawalność miejsca jest celem designu |
| Navmesh | ta sama siatka dla 3 faz; inaczej AI się psuje przy przejściu |
| Collision statyczna (poza drzwiami) | gracz nie może „odblokować” skrótu przez fazę |
| Pozycje 6 świec | landmark musi być w tym samym miejscu w każdej fazie |
| Pozycje punktów spawnu wroga | przewidywalność dla QA i dla gracza (drugie przejście) |

### 7.6 Testy akceptacyjne dla tego dokumentu

| Test | Metoda | Próg |
|---|---|---|
| Liczba świateł omni per faza | TH (zliczanie węzłów) | 0 / 6 / 12 |
| Gęstość mgły per faza | TH (odczyt `WorldEnvironment`) | 0,016 / 0,045 / 0,085 |
| Widoczność | PT (pomiar odległości do zniknięcia obiektu testowego) | 60 / 35 / 12 m (±10%) |
| Stany drzwi per faza | TH (kolizja) | zgodne z §2.3, §3.3, §4.3 |
| Zestaw wrogów per faza | TH (liczba i warianty) | 2A / 2A+4B / 2B+4C |
| Brak duplikacji levelu | IN (1 scena, 3 `.tres`) | 1 plik `village.tscn` |
| Czas przejścia | TH (timer) | 30 s / 45 s ± 3 s |
| Klatki podczas przejścia | PR | 0 klatek > 50 ms |

---

## 8. Synchronizacja z `docs/art-bible.md`

`docs/art-bible.md` (właściciel: `artist`) został zsynchronizowany z tym
dokumentem 2026-10-29: Noc ma widoczność **12 m** (**20 m** w stożku latarki),
a tekstury świata są w zakresie **128–256 px** (BAL-52). Nie ma otwartych
konfliktów liczbowych.

Otwarte pytanie do Pucka: czy przy 12 m widoczności w Nocy art-bible nie
powinien dostać własnej sekcji „paleta nocy” z jaśniejszymi wartościami
emisyjnymi dla świec — inaczej świece będą jedynym czytelnym elementem
i mogą wyglądać jak plamy światła bez kontekstu.
