# Empty Night — kontekst dla Claude Code

**Nazwa: Empty Night** (tytuł kaszubski „Pùstô noc”, od zwyczaju czuwania przy zmarłym; pisownię kaszubską
potwierdzić u osoby mówiącej po kaszubsku). Dawna robocza nazwa: Trauma Village. Repo: `git@github.com:HarpeusOne/empty-night.git`
(gałąź `main`, push przez SSH). Folder lokalny nadal nazywa się `trauma-village-v2`, stąd ścieżki w komendach.

Gra: linearny survival horror w stylu PS2, Kaszuby, Linia 2026.
Dzień → zmierzch → noc na tej samej przestrzeni. Kamera z oczu (FPP), pistolet +
strzelba, zagadki środowiskowe, 1 typ wroga, 2 zakończenia, mruganie jako mechanika.
Silnik: Godot **4.7.2** (flatpak `org.godotengine.Godot`), GDScript, renderer
**Compatibility** (`gl_compatibility`).

## Stan na koniec sesji 2026-11-08 (piąta sesja: szkoła i obiekty terenu szkoły)

Szczegóły i plan na kolejną sesję: `docs/session-notes.md`.

## Stan projektu (2026-11-07)

- **Projekt założony od nowa.** Poprzednia próba (OpenCode) leży w `../trauma-village`
  (kopia: `../trauma-village-opencode-archive`). **Nie używaj jej poziomu, grafiki
  ani shaderów** — po pierwszym teście była nie do grania (chaos, chodzenie przez
  ściany, zepsuty look). Kod systemów (balans, zapis, mruganie, logika wroga) wolno
  podglądać i przenosić selektywnie, dopiero gdy świat będzie gotowy.
- **Zachowane:** `story/`, `docs/`, `tools/`, dane `data/osm/`.
- **Mapa:** skompresowana, ale rozpoznawalna prawdziwa Linia z danych OpenStreetMap.
  Plany: `docs/map/`. Wiedza lokalna i potwierdzone fakty: `docs/map/notes.md`.
  Mariusz zna Linię i **nie zna Blendera** — jest reżyserem układu, AI buduje bryły.
  Prawdziwe współrzędne zostają w danych, a odległości między strefami skraca
  regulowany parametr kompresji (do dostrojenia po playteście).
- **Decyzje treściowe:** Pùrtk wycofany; wariant B wroga to **Ópi** (porusza się
  tylko, gdy gracz go nie widzi, BAL-56); demony-spotkania bez HP i duchy
  opiekuńcze są zawartością istniejących zagadek; tory zarośnięte i opuszczone;
  nad jeziorem jeden domek; niedokończone i zrujnowane domy w wsi trzeba zmyślić
  (jedyna prawdziwa ruina to budynek stacji kolejowej).
- **Kolejność prac:** (1) blockout 3D centrum z OSM + test kolizji ścian — **zrobione**
  (368 budynków, `scenes/linia_centrum.tscn`; to szary blockout, nie docelowy wygląd),
  (2) bramka wyglądu PS2 — **makieta gotowa, czeka na akceptację Mariusza**
  (makieta `scenes/look_gate.tscn`; **centrum Linii w wyglądzie PS2 to scena główna `scenes/linia_ps2.tscn`**; zrzuty w `docs/look/`, notatki w `docs/look/notes.md`), (3) reszta mapy, (4) przenoszenie systemów.
- **Wnętrza:** osobne sceny o normalnych proporcjach pokoi; wejście do budynku zmienia
  mapę na wnętrze (decyzja Mariusza 2026-11-07). `docs/scope.md` §5 i GDD mówią „1 scena”
  — wymaga to potwierdzenia i poprawienia sformułowania przez Mariusza.
- **Informacja zwrotna z pierwszego przejścia:** układ centrum jest trafiony; budynki wydają się
  małe, prawdopodobnie przez płaskie 3 m wysokości (obrysy są realistyczne, mediana 90 m²).
- **Kierunek wyglądu (Mariusz, 2026-11-07):** PS2, ale **gładsze** (bez afinicznego wykrzywiania), **chłodno, szaro,
  brudno** jak polska wieś w pochmurny dzień, **mgła w każdej fazie** (zmienia się tylko zasięg widzenia: dzień 60 m,
  zmierzch 35 m, noc 12 m wg GDD §5), **mało słońca**, **światła żółte** (stare). Szczegóły: `docs/look/notes.md`.
- **Znane uproszczenia blockoutu:** teren płaski (brak danych wysokościowych), wysokości
  budynków to założenia (OSM ma tylko kondygnacje: kondygnacje × 3 m, kościół 14 m itd.),
  budynki bez wejść (wnętrza dopiero po zaprojektowaniu), dachy płaskie.

## Twarde zasady

- **Nie commituj i nie pushuj.** Commit tylko na wyraźne polecenie Mariusza
  (w tym środowisku commit i push są i tak zablokowane).
- **Nie ogłaszaj, że coś „działa”, na podstawie samych testów headless.** Pokaż zrzut
  ekranu (godot-ai `editor_screenshot`, blender `look`), uruchom grę, sprawdź kolizje.
  Powiedz wprost, co zweryfikowałeś, a czego nie. (Lekcja z 2026-11-07: 43 zielone
  testy, a gra była niegrywalna.)
- **Niczego nie usuwaj bez kopii i zgody.** Duże zmiany w plikach, których nie
  napisałeś w tej sesji, najpierw omów.
- **Zero runtime LLM w grze.** AI tworzy treść offline; build jest deterministyczny.
- **Zakres v1 jest zamknięty:** 1 wieś, 4 wnętrza, 2 korytarze leśne,
  3 zagadki, 1 typ wroga (3 warianty), 2 bronie, 2 zakończenia, 90–120 min.
  Nowy pomysł spoza zakresu → `docs/backlog.md`, nie implementacja. Zakres zmienia
  tylko Mariusz (`docs/scope.md` §8). Prawdziwa mapa (cmentarz, tory, żwirownia)
  jest w trakcie przeglądu: liczby stref zmienia wyłącznie Mariusz.
- **Licencje:** tylko modele i assety dopuszczone komercyjnie. Każdy wygenerowany
  obraz ma wpis w `art/manifest.json`. Flux dev (niekomercyjny) jest zakazany.
  **Dane OSM (ODbL):** atrybucja „© OpenStreetMap contributors” w napisach końcowych.
  Google Maps i Street View tylko jako referencja, nigdy jako tekstury ani assety.
- **Folklor:** żadnych zmyślonych nazw demonów; każde imię ma źródło w
  `docs/bestiary.md` (dowody i oceny w `docs/bestiary-sources.md`). Wynalazki gry
  oznaczamy jako INVENTION.
- **Realne miejsca:** używamy prawdziwego układu Linii, ale nazwy instytucji,
  ulic i budynków w grze są fikcyjne (bestiariusz V-09).
- **Język:** kod i nazwy po angielsku, treść gry PL, tłumaczenie EN.

## Dokumenty projektu

- `docs/GDD.md`, `docs/scope.md`, `docs/acceptance.md`, `docs/backlog.md`
- `docs/art-bible.md`, `docs/day-night.md`, `docs/anim-list.md`
- `docs/bestiary.md`, `docs/bestiary-sources.md`, `docs/linia.md`
- `docs/map/` — plany OSM i `notes.md` (potwierdzone fakty o Linii)
- `docs/level-bible.md` — **przestarzały** (opisuje stary poziom), do przepisania
  na podstawie mapy z OSM
- `story/` — Ink i outline; `data/osm/` — surowe dane i trasy

## Komendy

```bash
# uruchomienie gry
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2

# sprawdzenie projektu bez okna (import, ładowanie wtyczki)
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --import

# narracja
python3 tools/ink_check.py

# dane i plany OSM (odtworzenie)
python3 tools/osm/fetch_linia.py      # pobranie danych do data/osm/linia_raw.json
python3 tools/osm/render_plan.py      # docs/map/plan_overview.png, plan_village.png
python3 tools/osm/route_to_lake.py    # pętla przy stacji i trasa do jeziora
python3 tools/osm/route_profile.py    # teren wzdłuż trasy
python3 tools/osm/plan_station.py     # docs/map/plan_station.png
```

```bash
# test kolizji ścian blockoutu (kapsuła gracza pchana w każdą ścianę każdego budynku)
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/blockout_collision_test.gd

# zrzuty ekranu z prawdziwego silnika (wymaga okna) -> docs/map/blockout_*.png
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/shots.gd

# eksport centrum z OSM do blockoutu -> data/blockout/centrum.json
python3 tools/osm/export_blockout.py

# makieta wyglądu PS2 (ulica + dom, dzień/zmierzch/noc): zrzuty i test kolizji
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/look_shots.gd
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/look_gate_collision_test.gd

# regresja: czy daleka ziemia nie wygrywa z gęstą siatką przy żadnym kącie kamery (okno, ok. 100 s, kod wyjścia 0 = OK)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/ground_sweep.gd

# centrum Linii w wyglądzie PS2: zrzuty (kościół, urząd, OSP, szkoła, start) i wydajność (okno)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/linia_shots.gd
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/linia_perf.gd

# płynność ruchu kamery podczas marszu (okno): stary tryb (tyk fizyki) kontra nowy (każda klatka)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/walk_smoothness.gd
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/walker_motion_test.gd

# tekstury proceduralne (art/textures + art/manifest.json)
python3 tools/art/gen_textures.py
python3 tools/art/gen_church_textures.py
python3 tools/art/gen_grounds_textures.py

# edytor mapy, latanie, kościół
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/map_editor_test.gd
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/fly_test.gd
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/church_shots.gd   # docs/look/church_*.png
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/school_shots.gd   # docs/look/school_*.png
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/editor_shot.gd    # docs/look/editor.png
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/props_shot.gd     # docs/look/props_*.png (nowe obiekty, place z kostki, znicze nocą)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/yard_props_shot.gd   # docs/look/yard_*.png (obiekty terenu szkoły)
# edytor budynków (zakładka Budynki w F2): test, zrzut, plansza typów
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village-v2 --script res://tests/building_editor_test.gd
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/building_editor_shot.gd   # docs/look/building_editor.png, building_openings*.png (okna/drzwi/elewacja)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2 --script res://tools/archetypes_shot.gd && python3 tools/art/arch_sheet.py   # docs/look/archetypes.png
python3 tools/art/gen_building_textures.py   # pustaki, blacha, brama garażowa, witryna
python3 tools/art/gen_yard_textures.py       # teren szkoły: zielona farba, siatka, kwiaty, gałązki, sztuczna trawa
# po dodaniu nowej klasy (class_name) odśwież import: ... --headless --import
```

Test kolizji sprawdziłem kontrolą negatywną: po wyłączeniu kolizji budynków zawodzi
dla każdej ściany. Test **nie** wykrywa odwróconych normalnych ścian (kolizja jest
dwustronna); ich poprawność potwierdza tylko to, że kapsuła zatrzymuje się także bez
kolizji od tyłu.

## MCP

- **godot-ai** — inspekcja scen, node'ów, skryptów, sygnałów; uruchamianie gry
  i odczyt błędów; zrzuty ekranu. Używaj zamiast zgadywania ścieżek node'ów.
  Wtyczka w `addons/godot_ai` musi być włączona w projekcie.
- **blender** — modelowanie, materiały, import assetów, podgląd viewportu.
  Działa w safe mode; jeśli import assetu wymaga dostępu do plików, poproś
  Mariusza o chwilowe wyłączenie safe mode.

## Model routing

- Domyślnie **Sonnet 5.5**; **Opus 5.5** tylko do architektury, trudnych bugów,
  pracy z MCP i weryfikacji wizualnej.
- Nie odpalaj równolegle opencode i Claude Code na tych samych plikach.

## Definicja ukończenia

- Zmiana działa w Godocie i **jest potwierdzona zrzutem ekranu** (zmiany wizualne i
  poziomu) albo jawnym testem; brak testu opisz wprost.
- Dla poziomu: automatyczny test kolizji ścian (brak przechodzenia przez budynki).
- Brak plików poza własnym zakresem, brak sekretów, brak commitów.

## Budynki kluczowe
- Kościół (pilot, z otoczeniem): `docs/key-buildings/church.md`, zrzuty `tools/church_shots.gd`.
- Szkoła (stara szkoła, nowe skrzydło, hala): `docs/key-buildings/school.md`, model `src/world/school_model.gd`,
  zrzuty `tools/school_shots.gd`, tekstury `python3 tools/art/gen_school_textures.py`.
- Edytor mapy w grze (F2): `docs/map-editor.md`; dane `data/map/props.json`; test `tests/map_editor_test.gd`.
- Budynki: `src/world/building_set.gd` (wszystkie domy, scalona siatka, zmiany autora), `building_kit.gd` (bryła z typu),
  `building_editor.gd` (zakładka Budynki, F3). Typy: `data/buildings/archetypes.json`; zmiany autora:
  `data/blockout/overrides.json` (ten plik jest prawdą, nie obliczony typ domyślny).
