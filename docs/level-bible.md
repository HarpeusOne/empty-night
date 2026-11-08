# Trauma Village: level bible

Wersja: blockout v1 (VS-1 + pełny szkielet wsi)
Scena: `levels/village.tscn` (jedyna scena levelu)
Generator: `levels/build_village.gd`
Walidator: `levels/validate_village.gd`
Silnik: Godot 4.7, prymitywy, materiał PS2 z `src/shaders/ps2_material.tres`

Zasady tego dokumentu:
- Wszystkie wymiary w metrach, oś X wschód, oś Z południe, Y w górę.
- Footprint: 240 x 178 m (X od -120 do 120, Z od -89 do 89).
- Cel czasu: 105 min pierwszego przejścia, zakres 90-120 min.
- Blockout nie zawiera wrogów, NPC ani finalnych assetów. Są tylko punkty i bryły.

---

## 1. Mapa ASCII

```
                         N (Z = -89)
   -120        -60          0          60         120
 -89 +-----------+-----------+-----------+-----------+
     |  F1: las     |         |   F2: cmentarz        |
     |  chata       |         |   kaplica, groby      |
 -60 |  (-96,-76)   |         |   (86,-72)            |
     |       \      |         |      /                |
 -40 |        \     |  SQ     |     /                 |
     |         \    |  plac   |    /                  |
 -20 |          \   |  kosciol|   /     L1: jezioro   |
     |           \  |  I-4    |  /      brzeg, molo   |
   0 |  V3: ul.   \ |  studnia| /       (108, 0)      |
     |  mlynska    \|  Retnik |/                      |
  20 |  I-2 mill    |  I-1    |      V2: glowna ulica |
     |  (-92,22)    | (44,26) |      sklep, domy       |
  40 |              |         |                       |
     |              |  V1     |                       |
  60 |              |  przyjazd|                      |
     |              |  autobus |                      |
  89 +-----------+-----------+-----------+-----------+
                         S (Z = +89)
```

Legenda:
- SQ to hub. Z SQ wychodzą cztery kierunki: V1 na południe, V2 na wschód,
  V3 na zachód, F1/F2 przez dwie bramy na północy.
- L1 leży za wschodnim końcem V2, nie bezpośrednio przy SQ.
- I-4 (kościół i dzwonnica) leży w obrysie SQ, ale jest osobną strefą.

---

## 2. Tabela 11 stref

| ID | Strefa | Footprint | Wys. | Czas 1. przejścia | Rola | Wejścia |
|---|---|---:|---:|---:|---|---|
| V1 | Droga wjazdowa | 44 x 60 | 3 m | 3 min | start, przystanek, znak wsi, blokada drogi | od południa start, na północ SQ |
| V2 | Główna ulica | 76 x 30 | 4 m | 4 min | domy, kapliczki, dojście do I-3 i I-1 | z SQ na zachodzie, do L1 na wschodzie |
| V3 | Ulica młyńska | 76 x 30 | 6 m | 4 min | kanał, tor, młyn z zewnątrz, dojście do I-2 | z SQ na wschodzie |
| SQ | Plac i hub | 64 x 64 | 9 m | 7 min | kościół, dzwonnica, urząd, sklep, studnia, Rétnik | V1, V2, V3, brama F1, brama F2 |
| I-1 | Dom Kreftów | 16 x 14 | 3,6 m | 5 min | list ojca, klucz P1, świeca 1 | drzwi od północy, od V2 |
| I-2 | Stary młyn | 16 x 16 | 6 m | 5 min | kanał, sworzeń P1, świeca 2 | drzwi od północy, od V3 |
| I-3 | Szkoła / izba pamięci | 20 x 16 | 4,5 m | 7 min | tabliczka 1898, świeca 4 | drzwi od południa, od V2 |
| I-4 | Kościół i dzwonnica | 24 x 20 + 6 x 6 | 15 m | 12 min | P3, dzwon, finał, świeca 6 | nawa od południa, dzwonnica od wschodu |
| F1 | Ścieżka do Jadwigi | 74 x 48 | 3,4 m | 8 min | las, chata, tabliczka 2005, świeca 3 | brama z SQ na północnym zachodzie |
| F2 | Stary cmentarz | 74 x 48 | 3,6 m | 7 min | grób Szymona, kaplica, świeca 5 | brama z SQ na północnym wschodzie |
| L1 | Brzeg jeziora | 22 x 56 | 3 m | 7 min | strzelba, tabliczka 2019, cisza | furta z V2 na wschodzie |

Czas sumaryczny samego zwiedzania: 69 min. Reszta budżetu to powroty do SQ,
dialogi, czytanie, walka i trzy zagadki. Cel 105 min, dopuszczalne 90-120.

---

## 3. Przepływ aktów

### Akt I, Dzień, 28 min

```
V1 (3) -> SQ (4) -> I-1 (5) -> V2 (4) -> SQ (2) -> V3 (4) -> I-2 (5) -> SQ (P1)
```

- Beat 1: V1, autobus odjeżdża, pierwszy dzwon o złej porze.
- Beat 2: SQ, Hanna i lista imion.
- Beat 3: I-1, splądrowany dom, list Antoniego, klucz w futerale skrzypiec.
- Beat 4: V2 i SQ, ksiądz unika tematu, Wiktor mówi o ojcu.
- Beat 5: V3 i I-2, sworzeń dzwonu, napis na kamieniu młyńskim.
- Beat 6: SQ, szafa organisty, P1, dzwon bije sam, droga zasypana.

### Akt II, Zmierzch, 38 min

```
SQ -> F1 (8) -> I-3 (7) -> L1 (7) -> SQ/kosciol (7) -> F2 (5) -> SQ/dzwonnica (2)
```

- F1: Bòrowô Cotka, czepiec, tabliczka 2005.
- I-3: rejestr 1898, zdjęcie klasy 2012, tabliczka 1898.
- L1: Wiktor, strzelba, Zofia, tabliczka 2019.
- SQ: ksiądz oddaje tabliczkę 2026, jeśli `trust_priest >= 1`.
- F2: grób Szymona bez głowy, tabliczka i trzecia zwrotka.
- SQ: koło dzwonu, P2, Ewa zamknięta w kościele, dzwon bije siedem razy.

### Akt III, Noc, 33 min

```
SQ -> L1/F2 (opcjonalnie) -> I-4 (P3) -> ENDING_1 / ENDING_2
```

- SQ: Dzwónnicy na ulicach, ocalali w sklepie.
- F2: rytuał, głowa Szymona, `knows_rite`.
- I-4: dzwon, fundament, wybór zakończenia.
- Finał: cutscene <= 120 s, epilog, credits.

Zasada linearności: każda strefa wychodzi z SQ i wraca do SQ. P1 i P2 są
bramkami faz i nie da się ich pominąć. F2 jest opcjonalne dla P2, ale wymagane
do pełnego rytuału.

---

## 4. Drzwi i drogi w trzech fazach

### 4.1 Drzwi

Wszystkie drzwi to instancje `scenes/door.tscn` pod `Doors/`. Nazwa koduje stan
bazowy. Stan docelowy ustawia `PhaseController` przez `is_open` i rotację.

| Node | Położenie | Dzień | Zmierzch | Noc |
|---|---|---|---|---|
| `door_F1_gate_open_day` | SQ -> F1, (-25,7, -31) | otwarte | otwarte | otwarte |
| `door_F2_gate_closed_day_open_dusk_night` | SQ -> F2, (22,3, -31) | zamknięte (zwalone drzewo) | otwarte | otwarte |
| `door_L1_furta_closed_day_open_dusk_night` | V2 -> L1, (99,6, 0,6) | zamknięte | otwarte | otwarte |
| `door_I1_front_closed_night_open_daydusk` | I-1, (42,3, 19) | otwarte | otwarte | zamknięte (barykada NPC-3) |
| `door_I2_front_closed_night_open_daydusk` | I-2, (-93,7, 14) | otwarte | otwarte | zamknięte (barykada NPC-3) |
| `door_I3_school_closed_day_open_dusk_night` | I-3, (70,3, -14) | zamknięte (klucz z P1) | otwarte | otwarte |
| `door_I4_belfry_closed_daydusk_open_night` | dzwonnica, (13,0, -25,7) | zamknięte | zamknięte (P2) | otwarte |
| `door_I4_nave_closed_daydusk_open_night` | nawa, (0,0, -10) | zamknięte | zamknięte | otwarte |
| `door_F1_hut_open_day` | chata Jadwigi, (-91,0, -76) | otwarte | otwarte | otwarte |
| `door_F2_chapel_open_day` | kaplica, (86,0, -68) | otwarte | otwarte | otwarte |
| `door_L1_shrine_open_day` | kapliczka, (107,0, -13) | otwarte | otwarte | otwarte |
| `door_townhall_open_day` | urząd, (-21,0, -2) | otwarte | otwarte | otwarte |
| `door_shop_open_day` | sklep Hanny, (21,5, 2) | otwarte | otwarte | otwarte |

Stany startowe w `village.tscn` odpowiadają Dniu: 8 drzwi otwartych, 5
zamkniętych. Dzwonnica jest zamknięta w Dzień i Zmierzchu, a otwiera ją P2 na
Noc. To zgadza się z `docs/day-night.md` §2.3 i §4.3. Kolejne fazy ustawia
`PhaseController` przez `is_open`/`apply_phase`, nie przez ręczną rotację.

### 4.2 Drogi

| Strefa | Dzień | Zmierzch | Noc |
|---|---|---|---|
| V1, V2, V3, SQ | otwarte | otwarte | otwarte |
| I-1, I-2 | otwarte | otwarte, puste | zamknięte |
| I-3 | zamknięte | otwarte | otwarte |
| I-4 nawa | zamknięte | zamknięte | otwarte |
| I-4 dzwonnica | zamknięte | zamknięte (P2) | otwarte |
| F1 | otwarte do bramy | otwarte | otwarte |
| F2 | zamknięte | otwarte | otwarte |
| L1 | zamknięte | otwarte | otwarte |

Noc zamyka I-1, I-2 i dzwonnicę. Meshe, kolizje i navmesh się nie zmieniają.
Zamykają się wyłącznie drzwi i stan `visible_objects` dla zwalonego drzewa w F2.

---

## 5. Wrogowie, spawny i patrole

W scenie nie ma żywych wrogów. Jest 14 markerów `enemy_spawn_*` pod
`EnemySpawns/`, każdy z meta `variant` = A, B lub C.

| Faza | Aktywne warianty | Spawny |
|---|---|---|
| Dzień | 2 x A | `enemy_spawn_V2_A1`, `enemy_spawn_V3_A2` |
| Zmierzch | 2 x A + 4 x B | A1, A2, `F1_B1`, `L1_B2`, `I3_B3`, `SQ_B4` |
| Noc | 2 x B + 4 x C | `F2_B5`, `SQ_B6`, `SQ_C1`, `F2_C2`, `L1_C3`, `I4_C4` |

`F2_C5` i `SQ_C6` są zapasowe, na drugie przejście i testy. Nie są aktywne
w pierwszym przejściu.

Patrole: 44 markery `waypoint_*` w grupie `enemy_waypoint`. Po 3-4 punkty na
strefę. Trasa wrogów zawsze mieści się w jednej strefie, co pozwala użyć
leasha 20/35/60 m bez przecinania granic.

| Strefa | Waypointy |
|---|---|
| V1 | `waypoint_V1_1..4` |
| V2 | `waypoint_V2_1..5` |
| V3 | `waypoint_V3_1..5` |
| SQ | `waypoint_SQ_1..6` |
| I-1 | `waypoint_I1_1..3` |
| I-2 | `waypoint_I2_1..3` |
| I-3 | `waypoint_I3_1..3` |
| I-4 | `waypoint_I4_1..3` |
| F1 | `waypoint_F1_1..4` |
| F2 | `waypoint_F2_1..4` |
| L1 | `waypoint_L1_1..4` |

Docelowe parametry wroga są w `docs/day-night.md` §2.4, §3.4, §4.4. Level nie
nadpisuje percepcji ani prędkości.

---

## 6. Światła

Jedno `WorldEnvironment`, jedno `DirectionalLight3D`, 12 `OmniLight3D` pod
`OmniLights/`. Wszystkie 12 istnieje od startu, wszystkie mają `light_energy = 0`
w scenie. Energię ustawia dopiero profil fazy.

Każde z 12 świateł ma przypięty `anim/procedural/light_flicker.gd`:
`base_energy = 1.0`, `use_scene_energy = false`, `start_lit = false`,
`rng_seed = 100 + indeks`, `update_hz` 12 (świece) / 10 (latarnie i przeswity),
`variation` 0.22 (świece) / 0.15 (latarnie i przeswity). Pozycja, zasięg i kolor
pozostają bez zmian. `PhaseController` nie ustawia już energii na stałe, tylko
woła `set_lit(true)` / `set_lit(false)` na każdym świetle; flicker sam prowadzi
`light_energy` wokół `base_energy`. Do zbudowania sceny wszystkie światła są
ciemne, więc walidator nadal widzi 12 węzłów z energią 0.

| Node | Pozycja | Rola | Dzień | Zmierzch | Noc |
|---|---|---:|---:|---:|---:|
| `Omni_Candle_I1` | (38, 1.4, 21) | świeca 1 | 0 | 0 | 1 |
| `Omni_Candle_I2` | (-86, 1.4, 25) | świeca 2 | 0 | 0 | 1 |
| `Omni_Candle_F1` | (-98, 1.4, -77) | świeca 3 | 0 | 0 | 1 |
| `Omni_Candle_I3` | (76, 1.4, -22) | świeca 4 | 0 | 0 | 1 |
| `Omni_Candle_F2` | (86, 1.4, -72) | świeca 5 | 0 | 0 | 1 |
| `Omni_Candle_I4` | (6, 1.4, -24) | świeca 6 | 0 | 0 | 1 |
| `Omni_Lantern_V1` | (2, 4, 70) | latarnia | 0 | 1 | 1 |
| `Omni_Lantern_V2` | (60, 4, 6) | latarnia | 0 | 1 | 1 |
| `Omni_Lantern_V3` | (-60, 4, 6) | latarnia | 0 | 1 | 1 |
| `Omni_Lantern_SQ` | (0, 4, 10) | latarnia | 0 | 1 | 1 |
| `Omni_Glow_Church` | (0, 3, -18) | przeswit kosciola | 0 | 1 | 1 |
| `Omni_Glow_Lake` | (110, 2, 10) | przeswit jeziora | 0 | 1 | 1 |

Budżet: 0 / 6 / 12 świateł omni. Cienie omni tylko 2, na dwóch najbliższych
świecach, ustawiane przez profil. Walidator wymaga dokładnie 12 węzłów i energii 0.

### 6.1 Wartości docelowe środowiska

| Parametr | Dzień | Zmierzch | Noc |
|---|---|---|---|
| Słońce kolor | `#FFF1DC` | `#FF8A3C` | `#7C90C0` |
| Słońce energia | 1,15 | 0,55 | 0,25 |
| Słońce elewacja/azymut | 38 / 210 | 7 / 250 | 50 / 130 |
| Ambient kolor | `#9FB8CC` | `#6A4E5E` | `#291F30` |
| Ambient energia | 0,90 | 0,45 | 0,45 |
| Sky top | `#7FA6C4` | `#4A3A55` | `#17121E` |
| Sky horizon | `#D8DCD4` | `#C4713F` | `#382838` |
| Mgła kolor | `#C6D0D4` | `#8A6250` | `#1A1517` |
| Mgła gęstość | 0,016 | 0,045 | 0,085 |
| Mgła start | 12 m | 7 m | 2,5 m |
| Widoczność | 60 m | 35 m | 12 m / 20 m z latarką |
| Cień słońca | mapa 1024, 40 m | mapa 1024, 30 m | mapa 512, 15 m |

Wartości bazowe w scenie odpowiadają Dniu. Reszta należy do `PhaseProfile`.
Tonemap: Linear, exposure 1,0.

Kamera jest **first-person z oczu**: `camera_height = 1.78`, brak odsunięcia
barku i zerowy SpringArm. Głowa, włosy, okulary i kaptur są ukrywane, żeby nie
przecinały widoku; tors i nogi widać przy patrzeniu w dół.

Latarka gracza (`Flashlight`, `SpotLight3D` pod kamerą, klawisz F) ma zasięg
28 m, kąt 32°, energię 8,0 i mały `FlashlightFill` (`OmniLight3D`, range 5 m,
energia 0,6). W Nocy włącza się automatycznie; gracz może ją zgasić.

### 6.2 Materiały i mgła

Shader `src/shaders/ps2_surface.gdshader` jest oświetlany i teksturowany,
z triplanarnym mapowaniem world-space. Mgła pochodzi z `WorldEnvironment`
(`PhaseController`), nie z shadera.

| Kolor funkcji | Tekstura A | Wariant B | `texture_scale` |
|---|---|---|---:|
| `COL_GROUND` | `tex_ground_grass` | `tex_ground_grass_b`, mix 0.7 | 4,0 |
| `COL_FOREST` | `tex_forest_floor` | — | 4,0 |
| `COL_ROAD` | `tex_road_asphalt` | `tex_road_asphalt_b`, mix 0.6 | 4,0 |
| `COL_COBBLE` | `tex_cobblestone` | `tex_cobblestone_b`, mix 0.7 | 3,0 |
| `COL_WOOD`, `COL_FENCE`, `COL_DOOR`, `COL_INTERIOR` | `tex_wood_planks` | `tex_wood_planks_b`, mix 0.5 | 2,0 / 1,5 |
| `COL_PLASTER` | `tex_plaster` | `tex_plaster_b`, mix 0.6 | 3,0 |
| `COL_BRICK` | `tex_brick` | `tex_brick_b`, mix 0.6 | 2,0 |
| `COL_ROOF` | `tex_roof_tile` | — | 2,0 |
| `COL_STONE` | `tex_stone_wall` | — | 2,5 |
| `COL_TREE`, `COL_FOREST_WALL` | `tex_foliage` | — | 3,0 / 3,5 |
| `COL_TRUNK` | `tex_bark` | — | 2,0 |
| `COL_WATER` | `tex_water` | — | 8,0 |
| `COL_SNOW` | `tex_ground_grass` (jaśniejszy tint) | `tex_ground_grass_b`, mix 0.35 | 4,0 |
| `COL_BELL`, `COL_GOLD` | `tex_metal` | — | 1,5 / 1,0 |
| `COL_WAX` | bez tekstury | — | — |

Shader `ps2_surface.gdshader` próbkuje A i B w dwóch skalach i miesza je
world-space noise, więc nawet materiał bez B nie powtarza jednego kafla w
oczywisty sposób. `macro_variation = 0.12`, `macro_scale = 0.08`.

Tint tekstur to `kolor.lerp(Color.WHITE, 0.45)`. Hałas PS2: `jitter_strength =
0.35`, `dither_strength = 0.25`, `color_levels = 32`. Scena ma 42 materiały
(42 teksturowane), 13 unikalnych tekstur bazowych i 6 wariantów B.

Mgła: 6 miękkich kart `FogCard_*` (F1 ×2, F2 ×2, L1 ×2) jako billboardy
`QuadMesh` z teksturą `fog_soft.png` i alpha 0.16, bez kolizji. V1 używa tylko
mgły objętościowej z `WorldEnvironment`, żeby nie przecinała kadru intro.
W Nocy karty są ukrywane przez `PhaseController`.

Roślinność i obrzeża: 36 animowanych koron, 51 kęp trawy/trzciny, 11 żywopłotów,
8 kałuż, 42 stożki ściany lasu poza playable. Propy: 6 słupów energetycznych
z poprzeczkami, izolatorami i przewodami, ławki, kosze, tablice, skrzynki,
stosy drewna.

---

## 7. Zagadki, świece, zapisy, itemy

### 7.1 Trzy zagadki

| ID | Nazwa | Faza | Elementy | Nagroda |
|---|---|---|---|---|
| P1 | Szafa organisty | Dzień | klucz w I-1 (`puzzle_P1_key_I1`), sworzeń w I-2 (`puzzle_P1_pin_I2`), śpiewnik w SQ (`puzzle_P1_safe_SQ`) | pierwsza zwrotka, rejestr 1898, przejście do Zmierzchu |
| P2 | Rejestr dzwonu | Zmierzch | tabliczki 1898 (I-3), 2005 (F1), 2019 (L1), 2026 (próg kościoła), koło dzwonu w SQ (`puzzle_P2_wheel_SQ`) | pełna zwrotka, przejście do Nocy, otwarcie I-4 |
| P3 | Dzwon bez serca | Noc | dzwon (`puzzle_P3_bell_I4`), fundament i głowa (`puzzle_P3_head_I4`) | ENDING_1 albo ENDING_2 |

Każda zagadka ma czytelną podpowiedź w świecie: list, etykieta, rachunek,
tabliczka lub notatka. Żadna nie wymaga przedmiotu z późniejszej fazy.

### 7.2 Sześć świec

| Świeca | Strefa | Pozycja | Akt | Światło | Zapis |
|---|---|---|---:|---:|---|
| `candle_01_I1` | I-1 | (38, 0, 21) | I | 2 / 4 / 6 m | `save_03_I1` |
| `candle_02_I2` | I-2 | (-86, 0, 25) | I | 2 / 4 / 6 m | `save_04_I2` |
| `candle_03_F1` | F1 | (-98, 0, -77) | II | 2 / 4 / 6 m | `save_06_F1` |
| `candle_04_I3` | I-3 | (76, 0, -22) | II | 2 / 4 / 6 m | `save_07_I3` |
| `candle_05_F2` | F2 | (86, 0, -72) | III | 2 / 4 / 6 m | `save_09_F2` |
| `candle_06_I4` | I-4 | (6, 0, -24) | III | 2 / 4 / 6 m | `save_10_I4` |

Świeca pali się do końca gry po zapaleniu. Stan to 6 booli w savie. Pozycje
świec są niezmienne między fazami.

### 7.3 Punkty zapisu

Dziesięć markerów `save_*` pod `SavePoints/`. Sześć pokrywa się ze świecami,
cztery są checkpointami przy wejściach. Każdy zapis leczy.

| Save | Miejsce | Przybliżony czas |
|---|---|---:|
| `save_01_V1` | przystanek | 1 min |
| `save_02_SQ` | studnia | 5 min |
| `save_03_I1` | świeca 1 | 10 min |
| `save_04_I2` | świeca 2 | 21 min |
| `save_05_SQ_P1` | szafa organisty | 26 min |
| `save_06_F1` | świeca 3 | 34 min |
| `save_07_I3` | świeca 4 | 41 min |
| `save_08_L1` | molo | 48 min |
| `save_09_F2` | świeca 5 | 53 min |
| `save_10_I4` | świeca 6 | 65 min |

Odstępy 1-12 min. Po 65 min zostają finał i epilog. Zapis co 8-12 min jest
zachowany poza pierwszym wejściem, które jest celowo szybkie.

### 7.4 Itemy (20 markerów)

- Zagadki: `item_P1_key_violin`, `item_P1_pin_mill`, `item_P1_songbook`,
  `item_key_belfry`.
- Dokumenty: `item_note_father_I1`, `item_note_ledger_SQ`, `item_note_well_SQ`,
  `item_note_mill_I2`, `item_note_grave_F2`, `item_note_chapel_F2`,
  `item_note_lake_L1`.
- Amunicja: 4 x pistolet (V1, V2, I-3, I-4), 2 x strzelba (F2, L1).
  - Pistolet: V1 = 14, V2 = 16, I-3 = 14, I-4 = 0 → rozkład **14/16/14**.
  - Strzelba: F2 = 6, L1 = 4, Akt I = 0 → rozkład **0/6/4**.
- Leczenie: `item_medkit_V3`, `item_medkit_I3`.
- Bron: `item_shotgun_L1` (od Wiktora, Akt II).

Łączny budżet amunicji w świecie: **44/10** (44 pistolet, 10 strzelba;
BAL-18/19, FG-F04 — źródło prawdy). Pistolet 14/16/14, strzelba 0/6/4
(Akt I / II / III). Blockout nie dzieli naboi na fazy, robi to system itemów.

> Uwaga: startowe rezerwy gracza (**40/18** — 40 pistolet, 18 strzelba) są
> **osobne** od budżetu świata i nie wchodzą do 44/10. Po podniesieniu wszystkich
> pickupów rezerwy wynoszą łącznie **84/28**. To istniejąca decyzja startowa,
> nie błąd levelu ani nadmiar naboi do zebrania.

---

## 8. Mapa VS-1 (V1 + SQ + I-1 + wejście F1)

Zakres: X od -30 do 30, Z od -40 do 88. To pierwsze 15-18 min gry.

```
Z=-40  +-------------------+  brama F1
       |  las F1 (wejscie)  |
Z=-33  |     [brama F1]     |
       |                    |
Z=-30  |  +------+ +------+ |  mur kosciola
       |  | I-4  | | I-4  | |
       |  | nawa | |dzwon | |
Z=-10  |  +--[]--+ +--[]--+ |  wejscia
       |     [arcade, szafa organisty]
Z=0    |  [urzad]  SQ   [sklep]  [Retnik]
       |      [studnia]       |
Z=20   |         [I-1]       |  dom Kreftow (44, 26)
       |           |         |
Z=30   +-----------+---------+  granica SQ
       |           |         |
       |        [V1 road]    |  szerokosc 8 m
Z=55   |           |         |
Z=70   |      [save 01]      |
Z=77   |    [przystanek]     |
Z=88   +---------------------+  blokada sniezna
```

Kolejność VS-1:
1. Start `PlayerStart` (1.2, 0.1, 143), rotacja 0 (na północ, w stronę SQ).
2. V1: znak, przystanek, save_01, blokada za plecami; za startem podjazd
   z zaparkowanym autem, szopa, płot i zadrzewienie zamykające drogę.
3. SQ: Hanna w sklepie, studnia, figura Rétnika.
4. I-1: list, klucz, świeca 1, save_03.
5. Powrót do SQ. Wejście F1 widoczne po północno-zachodniej stronie placu.

Korytarze OTS: droga V1 ma 8 m, plac ma 64 m, wejścia do I-1 mają 3,4 m.
Wnętrza I-1 mają 1,5-2,5 m między meblami i ścianami. Brak ciasnych zakrętów
bez kamery.

---

## 9. Integracja z programistą

### 9.1 Ścieżki węzłów

```
Village
  WorldEnvironment
  DirectionalLight3D
  Zone_V1 ... Zone_L1            (11 węzłów, grupa "zone")
  OmniLights/Omni_*              (12, grupa "omni_light")
  AudioEmitters/audio_*          (12, grupa "audio_emitter")
  Candles/candle_01_I1 ...       (6, grupa "candle")
  Doors/door_*                   (13, grupy "door", "phase_door")
  EnemySpawns/enemy_spawn_*      (14, grupa "enemy_spawn", meta "variant")
  SavePoints/save_*              (10, grupa "save_point")
  Items/item_*                   (20, grupa "item")
  Puzzles/puzzle_*               (10, grupa "puzzle")
  Waypoints/waypoint_*           (44, grupa "enemy_waypoint")
  PlayerStart                    (grupa "player_start")
```

`Zone_I1` itd. używają identyfikatorów bez myślnika. W dokumentacji i UI nadal
piszemy I-1, I-2, I-3, I-4. Mapowanie: `Zone_I1` = I-1.

### 9.2 PhaseController

- Oczekiwane API: `apply(profile: PhaseProfile, duration: float)`, bez cutscenki.
- `apply` ustawia: `WorldEnvironment`, `DirectionalLight3D`, 12 energii omni,
  widoczność `F2_FallenTree` i `F2_FallenCrown`, kolizję
  `F2_FallenTreeCollision` (grupa `phase_obstacle`, meta `opens_after = "P1"`),
  stany drzwi, spawn wrogów.
- Po P1: ukryć mesh drzewa, wyłączyć `CollisionShape3D.disabled = true` w
  `F2_FallenTreeCollision` i otworzyć `door_F2_gate_closed_day_open_dusk_night`.
- Przejście Dzień -> Zmierzch: 30 s, trigger P1.
- Przejście Zmierzch -> Noc: 45 s, trigger P2.
- Omni: Dzień 0, Zmierzch 6 (4 latarnie + 2 przeswity), Noc 12.
- Cienie omni: 0 / 0 / 2. Caster cieni tylko na `Omni_Candle_*`.
- Wszystkie 12 węzłów istnieje od startu, brak instancjonowania.

### 9.3 PhaseProfile

Pola wymagane przez `docs/day-night.md` §7.2: `sun_color`, `sun_energy`,
`sun_rotation`, `ambient_color`, `ambient_energy`, `sky_top`, `sky_horizon`,
`fog_color`, `fog_density`, `fog_start`, `shadow_distance`, `shadow_map_size`,
`omni_budget`, `shadow_casters`, `enemy_set`, `door_states`, `audio_snapshot`,
`visible_objects`.

Scena nie zawiera `PhaseController` ani `PhaseProfile`. `PhaseController` jest
autoloadem, a profile leżą w `src/phase/phase_day.tres`, `phase_dusk.tres`,
`phase_night.tres` (ścieżka `src/phase/` wynika z uprawnień programisty).
API: `apply_phase(phase_id, duration)`, `get_state()`, `apply_state(data)`.

### 9.4 Drzwi

- `scenes/door.tscn` ma panel 3 x 2,6 m i hinge w lokalnym x=0.
- Wszystkie otwory mają 3,4 m, więc panel 3 m mieści się z luzem.
- Drzwi na ścianach N/S mają rotację 0. Drzwi na ścianach E/W mają rotację -90.
- `src/interact/door.gd` zapisuje `_base_yaw` w `_ready()` i liczy
  `_open_yaw = _base_yaw - open_angle_deg`. Dzięki temu drzwi E/W obracają się
  względem własnej ściany, a nie do absolutnego -95 stopni.
- `Door` ma `start_open`. Builder ustawia nim stan Dnia (8 otwartych, 5
  zamkniętych). `PhaseController` przełącza stan przez `is_open` i metodę
  ustawiającą rotację względem `_base_yaw`, żeby zgadzały się z savem.
- `get_save_data()`/`apply_save_data()` używają tej samej pary kątów, więc
  wczytanie nie przestawia drzwi E/W.

### 9.5 Navmesh

- Jeden `NavigationRegion3D` na całą scenę, pieczony raz.
- Navmesh obejmuje podłogi wszystkich stref i otwory drzwiowe, nie zawiera
  paneli drzwi.
- Zamknięte drzwi blokują fizycznie, ale nie zmieniają navmeshu. AI musi
  sprawdzać `door_states` przy wejściu do strefy.
- Wnętrza I-1, I-2, I-3, I-4 są małe, bez Portali i Roomów. Zamiast tego fade
  0,3 s przy przekroczeniu progu, zgodnie z §7.1.
- Wszystkie progi i przejścia mają min. 2,5 m szerokości, więc navmesh nie
  wymaga agenta mniejszego niż 0,5 m.

### 9.6 Fade i dźwięk

- Fade 0,3 s przy wejściu do wnętrz i przy drzwiach fazowych.
- `AudioEmitters/audio_*` to markery. `PhaseController` włącza i wyłącza
  emitery przez `audio_snapshot` oraz `visible_objects`.
- Dzwon w SQ ma własny emitter `audio_bell_SQ`; w Zmierzchu ambient jest
  o 2 LUFS głośniejszy, żeby maskować kierunek.
- Efekty proceduralne nie tworzą własnego audio ani nie zmieniają colliderów.
  Dzwon ma `play_audio_on_ring = false`, a `DoorKick` czeka na input od
  programisty. Fade 0,3 s pozostaje po stronie systemu przejść.

### 9.7 Efekty proceduralne w scenie

| Node / grupa | Skrypt | Parametry | Kto uruchamia |
|---|---|---|---|
| `OmniLights/Omni_*` (12) | `anim/procedural/light_flicker.gd` | `base_energy = 1.0`, `use_scene_energy = false`, `start_lit = false`, `variation` 0.22 / 0.15, `update_hz` 12 / 10, `rng_seed = 100 + i` | `PhaseController._apply_omnis` przez `set_lit(true/false)` |
| `Zone_I4/I4_BellPivot` | `anim/procedural/bell_swing.gd` | `max_angle_deg = 18`, `frequency = 1.2`, `damping = 0.55`, `swing_axis = "X"`, `play_audio_on_ring = false` | zagadka P3 / trigger dzwonu przez `ring(intensity)` |
| 24 korony w `Zone_F1` i `Zone_F2` | `anim/procedural/branch_sway.gd` | `amplitude_deg` 2.0-3.5, `speed` 0.45-0.75, `phase_offset` z pozycji, `wind_strength = 1.0`, `enabled = true` | `_process` skryptu; opcjonalnie `set_wind()` przy zmianie fazy |
| `DoorKick` pod 4 drzwiami | `anim/procedural/door_kick.gd` | `door_path = ".."`, `kick_time = 0.18`, `camera_trauma = 0.7`, `cooldown = 0.8` | `kick(actor)` z kodu gracza; brak własnego inputu |

Dzwon: pivot `I4_BellPivot` wisi na szczycie wieży `(-7, 11.4, -26)`, mesh
`I4_Bell` jest dzieckiem pivota z offsetem `y = -1.0`. Marker
`Puzzles/puzzle_P3_bell_I4` zostaje w tej samej okolicy `(-7, 10.4, -26)`.
`DoorKick` dostają tylko: `door_F1_gate_open_day`,
`door_F2_gate_closed_day_open_dusk_night`,
`door_I3_school_closed_day_open_dusk_night`,
`door_I4_nave_closed_daydusk_open_night`.

`Zone_L1` nie ma w blockoucie koron drzew, więc BranchSway ogranicza się do F1
i F2 (po 12 koron na strefę, co trzecia korona, łącznie 24). Nie zmienia to
kolizji pni.

---

## 10. Ryzyka i braki

1. **Door.gd i rotacja bazowa: naprawione.** `_base_yaw` i `_open_yaw` są
   liczone w `_ready()`, a `interact()` i save/load używają ich zamiast
   absolutnego -95 stopni. Test w `tests/smoke_test.gd` sprawdza drzwi E/W.
2. **Stan startowy drzwi.** Builder ustawia Dzień: 8 otwartych, 5 zamkniętych,
   więc playtest V1 -> SQ -> I-1 -> F1 jest przechodni bez `PhaseController`.
   Walidator sprawdza liczbę otwartych drzwi i zamkniętą dzwonnicę.
3. **Dzwonnica w Dzień: naprawione.** `door_I4_belfry_closed_daydusk_open_night`
   jest zamknięta w Dzień i Zmierzchu, otwiera się na Noc po P2.
4. **Zwalone drzewo w F2: naprawione w blockoucie.** `F2_FallenTreeCollision`
   ma kolizję i grupę `phase_obstacle`. `PhaseController` po P1 wyłącza
   `CollisionShape3D.disabled` i ukrywa mesh drzewa oraz koronę.
5. **Navmesh: zbake'owany.** `src/nav/village_navmesh.tres` ma 1331 poligonów
   i 1183 wierzchołki, pokrywa 11/11 stref i 13/13 otworów drzwiowych.
   Wróg używa `NavigationAgent3D`, a w `level_test` robi fallback na ruch
   bezpośredni. Occludery nadal nie są dodane: Noc z 12 światłami wymaga
   sprawdzenia w profilerze.
6. **Płyty podłóg i przejścia: naprawione.** Każda płyta ma offset 0,5 mm,
   a V2 -> I-1, V2 -> I-3, SQ -> F1 i SQ -> F2 mają dodane kolizje podłogi.
   Navmesh pokrywa te przejścia po re-bake'u.
7. **Brak NPC i interakcji.** Scena ma tylko markery. Dialogi, sklep Hanny
   i ksiądz są poza zakresem level designu.
8. **Liczba węzłów i koszt procesu.** 1798 węzłów, 319 statycznych brył
   kolizji i 42 materiały. 12 świateł ma `LightFlicker`, 36 koron
   `BranchSway`, 4 drzwi `DoorKick`, 8 kart mgły. Koszt `_process`,
   podwójnego triplanaru i 42 materiałów do sprawdzenia w profilerze,
   szczególnie w Nocy.
9. **Brak testu czasu przejścia.** Czas 105 min jest wyliczony z tabel, nie
   zmierzony. Pierwszy playtest VS-1 powinien zmierzyć odcinek V1 -> SQ -> I-1.
10. **Scena jest podpięta do `main.tscn`.** `level_test.tscn` zostaje jako
    scena testowa dla smoke testu.
11. **LightFlicker a PhaseController.** `PhaseController` jest jedynym
    właścicielem stanu: woła `set_lit()` i `set_process()` tylko dla aktywnych
    świateł. Nie ustawiaj energii świateł ręcznie poza kontrolerem.
12. **BranchSway na koronach.** Skrypt obraca mesh wokół środka, nie wokół
    podstawy gałęzi. Efekt do oceny na playteście; można przenieść pivot.
13. **DoorKick bez inputu.** `kick()` nie jest jeszcze wołane z gry. Skrypty
    czekają na decyzję o klawiszu/akcji.
14. **Dzwon bez audio.** `ring()` tylko kołysze; `play_audio_on_ring = false`,
    bo w repo nie ma plików audio.
15. **Jeden region navmeshu zamiast per strefa.** Dla obecnego zakresu
    wystarcza; przy ciasnych wnętrzach obserwować agenta (ryzyko R3 w GDD).
16. **Powtarzalność tekstur.** Triplanar world-space i duże płaszczyzny
    (droga 3,0 m, woda 4,0 m) mogą pokazać kafle, zwłaszcza na V1 i SQ.
    Do korekty po playteście.
17. **Karty mgły.** 8 billboardów z alpha 0.10 może się nakładać i „mleć”
    kadr w Dzień/Zmierzch; przy Nocy są prawie niewidoczne. Ocena wizualna.
18. **Ciemne okna i propy.** Okna to unshaded quady i mogą czytać się jak
    dziury; słupy, kable i skrzynki nie mają kolizji. Do decyzji przed VS-1.
19. **Brakujące tekstury.** Wciąż brak `tex_ground_mud`, `tex_gravel`,
    `tex_roof_tar`, `tex_thatch`, `tex_cloth`, `tex_metal` i animacji wody.
    Drzwi używają flat tintu z `door.gd`, nie `tex_wood_planks`.
20. **Stare parametry mgły.** `enemy.gd` i `item_pickup.gd` ustawiają
    `fog_start`, którego shader już nie ma. To no-op; do usunięcia przy
    porządkach, bo mgła idzie wyłącznie z `Environment`.

21. **Nowe budynki i okna.** 5 nowych brył (`V1_Barn`, `V2_HouseF/G`,
    `V3_Utility`, `SQ_Plebania`) i 49 detali okien/ram. Wszystkie bez
    własnych kolizji poza bryłą; navmesh wymaga re-bake po każdej zmianie.
22. **Wariacja koloru ścian** tworzy 42 materiały. To poprawia wygląd, ale
    zwiększa liczbę stanów materiałowych; do sprawdzenia draw calls.
23. **Animacje proceduralne** `ViewBob` (SpringArm3D) i `BodyMotion`
    (`Enemy/Body`) są wpięte; ocenić na playteście, czy nie mdłą i nie
    kolidują z `CameraShake`.

Następny krok: playtest wizualny Dzień/Zmierzch/Noc po 5C, ocena detali,
animacji `ViewBob`/`BodyMotion`, mgły i powtarzalności; potem decyzja o VS-1.
