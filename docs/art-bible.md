# Empty Night — Art Bible v0.1

Współczesna wieś kaszubska, Linia 2026. Survival horror w estetyce PS2. Dokument źródłowy dla
wszystkich assetów graficznych. Obowiązuje `artist`, `level-designer` i
`programmer` przy shaderach.

## 1. Kierunek

- Realizm pamięciowy, nie fotorealizm: wszystko wygląda jak z taniej płyty PS2
  z 2003 roku, nie jak współczesny render.
- Brud, wilgoć, zmęczenie materiału. Wieś nie jest idylliczna ani turystyczna.
- Kolory zgaszone, jakby na kliszy leżakowanej w piwnicy. Czerń nigdy nie jest
  czysta, biel nigdy nie jest białą.
- Horror wynika z ciszy, mgły i pustki, nie z gore. Krew i przemoc oszczędnie.
- Folklor kaszubski: drewno, kamień, mech, kapliczki, tkaniny, narzędzia rolnicze.
  Bez fantasy, bez rogów i ognia z oczu.

## 2. Paleta

Wspólna baza ~32 kolorów na scenę. Każdy asset mieści się w swojej kolumnie;
przejścia tonalne budujemy ditheringiem, nie gradientem.

### Dzień (overcast, flat)

| Rola | HEX | Uwaga |
|---|---|---|
| Niebo | `#A8B0A4` | szaro-zielone, bez błękitu |
| Mgła / dalszy plan | `#C6C9BE` | najjaśniejsza wartość sceny |
| Drewno suche | `#5B4A38` | ściany, płoty |
| Drewno mokre | `#3E332A` | narożniki, podcień |
| Mech / las | `#4A5334` | nasycenie maks. 25% |
| Piasek / droga | `#8C8066` | ubity grunt |
| Dach / papa | `#4E4A42` | neutralny grafit |
| Rdza / akcent | `#7A4A32` | tylko plamy, nie płaszczyzny |

### Zmierzch (ciepły horyzont, zimne cienie)

| Rola | HEX | Uwaga |
|---|---|---|
| Niebo góra | `#6E5A58` | brudny fiolet |
| Niebo horyzont | `#B08A6A` | ostatnie światło |
| Cień | `#3A3330` | wszystko w cieniu wpada w brąz |
| Okno zapalone | `#C9A15E` | jedyne ciepłe światło |
| Mgła | `#7D7268` | między ciepłem a zimnem |

### Noc (księżyc + latarka)

| Rola | HEX | Uwaga |
|---|---|---|
| Niebo | `#141A20` | granatowo-zielony |
| Cień | `#0C1014` | nie czysta czerń |
| Księżyc / rim | `#6F7F8C` | zimny, miękki |
| Latarka | `#C8B27A` | ciepły stożek, szybki falloff |
| Ostrzeżenie | `#5A1E1E` | krew, tylko punktowo |

### Zasady koloru

- Nasycenie sceny: max 35% (HSV S). Wyjątek: latarka i okna.
- Kontrast: dzień niski, zmierzch średni, noc wysoki tylko lokalnie.
- Zakaz czystych `#FF0000`, `#00FF00`, `#0000FF` i neonów.
- Postacie czytelne sylwetkowo: bohater jaśniejszy od tła, wróg ciemniejszy.

## 3. Światło

| Faza | Źródło | Cechy |
|---|---|---|
| Dzień | zachmurzone niebo | miękkie, kierunkowość ledwo widoczna, cienie krótkie i rozmyte, brak odbić lustrzanych |
| Zmierzch | słońce pod horyzontem | długie cienie, ciepły horyzont, zimne wnętrza, okna zapalane punktowo |
| Noc | księżyc + latarka | dominuje ciemność, stożek latarki 25–35°, falloff ~8 m, mgła ogranicza widoczność do 12 m (20 m w stożku latarki) |

Zasady:

- Zero HDR, bloomu, lens flare, chromatic aberration i ambient occlusion z
  nowoczesnego pipeline'u. Poświata tylko ręcznie malowana lub przez fog.
- Cienie twarde tylko w promieniu latarki; reszta miękka lub wypalona w teksturze.
- Wnętrza oświetlane punktowo (świeca, żarówka 40 W, piec). Światło nie może
  być równomierne — zostawiamy czarne kąty.
- Mgła jest narzędziem kompozycji: zasłania horyzont i tnie draw distance.

## 4. Materiały

Wszystkie matowe, wysoki roughness (0.75–0.95), specular minimalny.

| Materiał | Cechy | Rozdzielczość |
|---|---|---|
| Drewno (deski, bal) | słoje wzdłuż, pęknięcia, gwoździe, miejsca przetarte | 256 → 128 |
| Tynek / glina | łaty, rysy, odpadające płaty, odcisk palca | 256 → 128 |
| Dach (papa, strzecha) | pasy, zacieki, mech w szczelinach | 256 → 128 |
| Kamień / beton | ziarno, porost, wilgotne plamy | 256 → 128 |
| Ziemia / błoto | koleiny, kałuże, liście, kamienie | 256 → 128 |
| Ściółka leśna | igliwie, szyszki, butwiejące liście | 256 → 128 |
| Woda / jezioro | płaska, ciemna, delikatna fala, odbicie księżyca | 128, animowana |
| Tkanina | len, wełna, wyblakłe wzory, cerowanie | 128 |
| Metal | rdza, matowy, bez chromu i lustra | 128 |
| Skóra / twarz | matowa, niedoskonała, worki pod oczami, brud | 512 portret |

## 5. Zasady PS2

- **Rozdzielczość wewnętrzna:** 640×480 (4:3), skalowanie całkowite, opcjonalny
  letterbox. Finalne tekstury 128–256 px, portrety 512 px.
- **Paleta:** 16-bitowy feel, maks. ~32 kolory na scenę, dithering uporządkowany
  4×4 przy przejściach tonalnych.
- **Geometria:** niska liczba trójkątów, płaskie ściany, widoczne krawędzie.
  Zakaz subsurface scattering, displacement i high-poly.
- **Tekstury:** affine warping delikatny (shader), filtrowanie bilinear,
  brak ostrych mipmap zjazdów. Powtarzalne wzory bez widocznego szwu.
- **Efekty:** mgła liniowa, ziarno filmowe 3–6%, vignette subtelna, lekki
  vertex snap/wobble. Brak motion blur, DOF i fizycznego szkła.
- **Czytelność:** każdy asset testowany w 256 px. Jeśli po zmniejszeniu nie
  wiadomo, co to jest — do poprawy.
- **Interfejs:** UI rysuje silnik. W grafice zero liter, cyfr, strzałek, ramek.

## 6. Kompozycja

- Tła 4:3-safe: ważna treść w centralnych 80%; margines 10% może zostać
  przycięty przez UI lub letterbox.
- Horyzont: dzień 55–60% wysokości, zmierzch 45–50%, noc 40% (więcej nieba).
- Punkt zainteresowania poza środkiem (trójpodział). Środek zostawiamy na
  postać gracza lub wydarzenie.
- Portrety: popiersie, oczy na górnej linii trójpodziału, tło ciemne i płaskie,
  sylwetka oddzielona od tła wartością, nie kolorem.
- Wróg: czytelna, nieludzka sylwetka; twarz nieczytelna, bez konkretnych cech.

## 7. Lista assetów v1

### Tła (5)

| ID | Opis | Źródło | Runtime |
|---|---|---|---|
| `bg_village_day` | wieś za dnia, droga, chałupy, mgła | 768×576 | 640×480 |
| `bg_village_dusk` | ta sama wieś, zmierzch, zapalone okna | 768×576 | 640×480 |
| `bg_village_night` | ta sama wieś, noc, księżyc, latarka | 768×576 | 640×480 |
| `bg_cottage_interior` | wnętrze chałupy, piec, stół, świeca | 768×576 | 640×480 |
| `bg_forest_lake` | korytarz leśny i jezioro, mgła | 768×576 | 640×480 |

### Portrety (6)

| ID | Opis | Źródło | Runtime |
|---|---|---|---|
| `portrait_hero` | bohater, 30–40 lat, zmęczony, kurtka | 512×512 | 512 / 256 |
| `portrait_npc_elder` | starsza kobieta, chusta, surowe rysy | 512×512 | 512 / 256 |
| `portrait_npc_priest` | ksiądz, czarny płaszcz, zmęczone oczy | 512×512 | 512 / 256 |
| `portrait_npc_neighbor` | sąsiad, wiatrówka, nieufny | 512×512 | 512 / 256 |
| `portrait_npc_child` | dziecko, 10 lat, współczesne ubranie | 512×512 | 512 / 256 |
| `portrait_enemy_silhouette` | sylwetka wroga, wysoka, chuda, bez twarzy | 512×512 | 512 / 256 |

### Tekstury i propsy (v1, następne partie)

- Ściany: `tex_wood_plank`, `tex_plaster`, `tex_stone`.
- Dachy: `tex_roof_tar`, `tex_thatch`.
- Grunt: `tex_ground_mud`, `tex_forest_floor`, `tex_gravel`.
- Woda: `tex_water_lake` (animowana).
- Propsy: płot, studnia, kapliczka, latarnia, drzwi, okno, piec, stół, krzesło,
  narzędzia (kosa, siekiera, wiadro), opona, plakat wyborczy bez tekstu.
- Bronie: pistolet, strzelba (model + tekstura).
- UI: ikony amunicji, zdrowia, ekwipunku (rysowane w silniku, nie w AI).

## 8. Wymiary i format

| Klasa | Źródło AI | Finalne | Format |
|---|---|---|---|
| Tło | 768×576 | 640×480 | PNG bez alfa |
| Portret | 512×512 | 512×512, LOD 256 | PNG, opcjonalnie alfa |
| Tekstura | 512×512 | 256×256 lub 128×128 | PNG, tiling |
| Ikona UI | — | 64×64 / 32×32 | PNG z alfa |
| Woda | 512×512 | 128×128 | PNG, animacja 8 klatek |

## 9. Zakazy

- Tekst, litery, cyfry, napisy, plakaty z treścią, znaki drogowe z tekstem.
- NSFW, nagość, gore eksponowane, wizerunki realnych osób.
- Logotypy, marki, znaki towarowe, cudze postacie i modele.
- Nowoczesne przedmioty „z salonu” i sterylne wnętrza: wieś w 2026 jest biedna,
  ale nie retro. Smartfon Marty jest dozwolony jako rekwizyt (ekran, latarka,
  brak zasięgu), byle nie dominował kadru.
- Fotorealizm, HDR, bloom, lens flare, chromatic aberration, ray tracing.
- Nasycone kolory, neon, czysta czerń i biel, tęcza.
- Fantasy: rogi, skrzydła, ogień z oczu, zmyślone imiona demonów.
- Modele niekomercyjne (Flux dev) i checkpointy NSFW.
- Asset bez wpisu w `art/manifest.json`.

## 10. Pipeline i akceptacja

1. Prompt po angielsku, styl opisany rzeczownikami, powtarzaj seed przy iteracji.
2. Generacja wyłącznie `python3 tools/gen.py` (checkpoint `sd_xl_base_1.0.safetensors`,
   licencja OpenRAIL++-M).
3. Ocena: kompozycja, spójność z paletą, czytelność w 256 px, artefakty
   (dłonie, twarze, perspektywa, powielone elementy), brak tekstu.
4. Zaakceptowane → `art/final/`, odrzucone zostają w `art/raw/`.
5. Manifest: `status: final`, `category`, `notes` z uzasadnieniem.

## 11. Stan produkcji (partia 2)

Finalne tekstury 256×256 w `art/final/textures/` (wszystkie `--seamless`,
`category: texture`, wpis w manifeście):

| Plik | Materiał | Uwaga |
|---|---|---|
| `tex_ground_grass.png` | trawa + błoto | baza z partii 1 |
| `tex_road_asphalt.png` | asfalt | droga, drobne kruszywo |
| `tex_cobblestone.png` | kamienna kostka | nieregularne fugi |
| `tex_plaster.png` | biało-kremowy tynk | rysy, zacieki, płaty |
| `tex_brick.png` | stara czerwona cegła | gruba zaprawa |
| `tex_wood_planks.png` | pionowe deski | słoje, pęknięcia |
| `tex_roof_tile.png` | ciemna dachówka | rzędy od góry |

Nazwy w tabeli są wiążące (`tex_wood_planks`, nie `tex_wood_plank`;
`tex_roof_tile` pokrywa dachówkę ceramiczną, `tex_roof_tar`/`tex_thatch`
pozostają do zrobienia).

## 12. Stan produkcji (partia 3)

Pięć nowych tekstur 256×256 w `art/final/textures/`, źródło 512×512, wszystkie
`--seamless`, `category: texture`, `status: final`, wpis w manifeście
(`sd_xl_base_1.0.safetensors`, OpenRAIL++-M). `--verify` zielony: 12 plików =
12 wpisów finalnych.

| Plik | Seed | Materiał | Mapowanie w grze |
|---|---|---|---|
| `tex_forest_floor.png` | 7011 | igliwie, mech, butwiejące liście; drobna skala | ściółka leśna, pobocza, runo pod drzewami |
| `tex_stone_wall.png` | 7002 | surowy kamień, nieregularne bloki, zaprawa wapienna | mur cmentarny, fundamenty, kapliczka (pokrywa `tex_stone` z listy v1) |
| `tex_bark.png` | 7003 | kora sosny, pionowe bruzdy | pnie drzew, belki, słupy |
| `tex_foliage.png` | 7024 | gęste, ciemne igliwie sosny | maski koron, krzaki, warstwa "listowie" na billboardach |
| `tex_water.png` | 7025 | ciemna, spokojna woda, drobne fale | tafla jeziora; baza klatki 0 dla `tex_water_lake` (animacja 8 kl.) |

Uwagi:

- `tex_forest_floor` — odrzucone 2 próby z partii 2 i 1 z partii 3 (zbyt duże,
  nasycone liście / ilustracja botaniczna). Przyjęta wersja jest drobnoziarnista,
  desaturowana, czytelna przy 256 px.
- `tex_foliage` — dwie odrzucone próby (biała krata, potem plaid). Przyjęta
  wersja to skupiska igieł bez struktury siatki; nadal lekko dekoracyjna, do
  ewentualnej korekty shaderem (`vertex color`/tint).
- `tex_water` — dwie odrzucone próby (regularne prążki, potem kafelki z fugą).
  Przyjęta wersja jest bardzo płaska i ciemna; kontrast fal robi animacja
  shadera, nie tekstura.
- Słowo „seamless tileable” w prompcie SDXL prowokowało wzory siatkowe —
  w powtórkach usunięte, brzegi zmiękcza dopiero `--seamless` w `gen.py`.
- Nazwy docelowe z listy v1 (`tex_stone`, `tex_water_lake`) realizowane jako
  `tex_stone_wall` i `tex_water`; aliasy do ustalenia w shaderach.
- Wciąż brakuje: `tex_ground_mud`, `tex_gravel`, `tex_roof_tar`, `tex_thatch`,
  `tex_cloth`, `tex_metal`, warianty nocne i animacja wody.

## 13. Warianty tekstur (partia 4)

Cel partii: rozbić powtarzalność kafli. Shader dostaje dwa obrazy tego samego
materiału (A = wersja bazowa, B = wariant) i miesza je maską szumu oraz
drugim, przesuniętym UV. Wszystkie warianty: źródło 512×512, finalne 256×256,
`--seamless`, `category: texture`, `status: final`, wpis w manifeście
(`sd_xl_base_1.0.safetensors`, OpenRAIL++-M). `--verify --final-size 256`:
**19 plików = 19 wpisów finalnych, 0 problemów**.

| Plik | Seed | Materiał bazowy | Użycie (shader blend A/B) |
|---|---|---|---|
| `tex_ground_grass_b.png` | 8191 | trawa + błoto (`tex_ground_grass`) | para A/B do gruntu; gęstsza i zieleńsza od A, inny rozkład źdźbeł — przyciemnić tintem (S > 35% miejscami) |
| `tex_road_asphalt_b.png` | 8112 | asfalt (`tex_road_asphalt`) | para A/B do drogi; drobne kruszywo, łaty i cienkie pęknięcia, bez dużych fal |
| `tex_cobblestone_b.png` | 8113 | kamienna kostka (`tex_cobblestone`) | para A/B do kostki; kamienie o różnych rozmiarach, nieregularne fugi, inny układ niż A |
| `tex_plaster_b.png` | 8134 | tynk (`tex_plaster`) | para A/B do ścian; ciemniejszy, zacieki i odparzenia, do narożników i podstaw |
| `tex_brick_b.png` | 8105 | cegła (`tex_brick`) | para A/B do cegły; ciemniejsza, wytarta, jaśniejsza fuga |
| `tex_wood_planks_b.png` | 8106 | deski (`tex_wood_planks`) | para A/B do drewna; szare, ciemniejsze deski, inny słoje |
| `tex_metal.png` | 8107 | metal (pierwsza tekstura) | dzwon, latarnia, okucia; matowe żelazo/brąz z rdzą, bez odbić; brak pary A/B |

Uwagi z partii:

- Trawa jest najtrudniejsza: SDXL przy „short/worn grass” rysuje kępki i scenki,
  a słowo „seamless tileable” w prompcie potrafi wywołać pasy lub kratkę.
  Działa powtórzenie promptu bazy z innym seedem (8191) — ten sam materiał,
  inny rozkład. Odrzucono 9 prób trawy (bagno, kępki, warstwy, pasy, wzór).
- Tynk: odrzucone 3 próby (kafelki z czarnymi pasami, czarna rama, zbyt jasny
  wariant). Przyjęty 8134 spełnia „ciemniejszy, więcej zacieków”.
- Asfalt: odrzucona 1 próba (gładka, tekstylna). Kostka: odrzucona 1 próba
  (regularna siatka płytek). Razem **14 odrzuconych**, pliki zostały w
  `art/raw/` i mają `status: rejected` z powodem w `notes`.
- Rekomendacja dla shadera: maska blendu o niskiej częstotliwości (szum 2–3
  oktawy), skala UV B przesunięta o 0.37 i obrócona, żeby nawet para A/B nie
  tworzyła widocznej siatki; na trawie mieszać B mocniej przy ścieżkach.
- Wciąż brakuje: `tex_ground_mud`, `tex_gravel`, `tex_roof_tar`, `tex_thatch`,
  `tex_cloth`, warianty `_b` dla `tex_roof_tile`, `tex_stone_wall`, `tex_bark`,
  `tex_forest_floor`, `tex_water` oraz animacja wody.

## 14. Tekstury postaci (Fala 6)

| Plik | Materiał | Użycie |
|---|---|---|
| `tex_hoodie_fabric.png` | ciemny jersey | tors, rękawy, kaptur, kieszeń bluzy |
| `tex_denim.png` | niebieski denim | szerokie jeansy, biodra |
| `tex_sneaker_mesh.png` | czarna siatka sportowa | cholewka butów |
| `tex_skin.png` | neutralna skóra | głowa, dłonie, szyja |
| brak `tex_hair` / `tex_sole_rubber` | fallback kolorem | włosy ciemne, podeszwa kość słoniowa |

Postać nie używa logotypów ani znaków firmowych. Buty są czarne, masywne,
z jasną podeszwą, bez logo.
