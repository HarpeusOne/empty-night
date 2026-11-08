# Notatki z sesji 2026-11-07 / 11-08 (do wznowienia pracy)

## Czwarta sesja 2026-11-08: okna, drzwi i elewacja budynków
- Autor potwierdził, że wszystko z trzeciej sesji działa (także myszą).
- **Zakładka Budynki:** **E** = elewacja (6 wykończeń ścian), **O** = tryb okien i drzwi: klik w ścianę zaznacza otwór, przeciąganie
  go przesuwa (także na inną ścianę), nowy otwór z 10 rodzajów, rozmiar, wysokość, kopia, usuwanie, powrót do automatycznych.
  Dane: `facade` i `openings` w `data/blockout/overrides.json`. Opis: `docs/map-editor.md`.
- Automatyczne okna liczy teraz `BuildingKit._plan_openings` (lista), a rysuje `_draw_openings`; kolejność losowania jest ta sama,
  więc budynki bez zmian wyglądają jak wcześniej.
- Testy zielone (building_editor ma 16 nowych sprawdzeń, w tym zapis i odczyt). Zrzuty: `docs/look/building_openings*.png`.
- **NIE sprawdzone myszą w oknie:** klikanie i przeciąganie okien. Kościół nadal nie ma edycji okien (model ręczny).

## Trzecia sesja 2026-11-08: nowe obiekty, place z kostki, kościół ze zdjęć tyłu
- **Nowe obiekty** (F2, Obiekty): krzew kulisty, drzewko kuliste, głaz (pomnik z tabliczką), nagrobek, nagrobek podwójny,
  znicz, znicze, ławka bez oparcia, kosz, tablica ogłoszeń; żywopłot strzyżony (linia). Krzyż drewniany przerobiony wg zdjęcia.
  Tekstury `tools/art/gen_props_textures.py` (p_*, wpisy w manifeście). Znicze świecą nocą i same stają na płycie nagrobka.
- **Kostka:** nowe kolory (czerwona, grafitowa) i **place** = dowolne wielokąty (Enter zamyka). Ta sama nawierzchnia leży na
  jednej wysokości z wzorem w układzie świata, więc nachodzące ścieżki i place łączą się bez szwów; czerwona leży na wierzchu.
  Dotyczy też już zapisanych ścieżek autora (wcześniej każda leżała na innej wysokości).
- **Kościół** wg nowych zdjęć (opis: `docs/key-buildings/church.md`, runda 3): wysoki tył z dwoma stromymi ciemnymi dachami,
  duże okna narożne, brązowy krzyż 3D, zielone dachy nawy i przybudówek, wyższe przybudówki z drzwiami po obu stronach.
- **Testy zielone**; map_editor_test ma nowe sprawdzenia (wszystkie 31 typów, place, warstwy, znicz na płycie).
- **NIE sprawdzone myszą w oknie:** rysowanie placów, przeciąganie rogów, panel w dwóch kolumnach (widać go na `docs/look/editor.png`).
- **Do potwierdzenia przez autora:** miejsce drzwi dla ministrantów (lewy bok ściany z krzyżem), odcień zielonego dachu.

## Druga sesja 2026-11-08: edytor budynków
- **Poprawka zaznaczania obiektów** (zgłoszenie autora: „klikam inny obiekt, a dalej edytuje poprzedni”). Przyczyna:
  duże pole klikania korony drzewa (i pasy kostki pod spodem) wygrywało z obiektem, w który się celowało. Teraz wygrywa
  dokładne trafienie, potem najmniejsze pole klikania, a ścieżki na końcu; **Tab** = następny obiekt pod kursorem.
  Test: na starym kodzie 3 nowe sprawdzenia zawodzą, na nowym przechodzą. Myszą w oknie NIE sprawdzone.
- **Zakładka „Budynki” w F2 (F3 przełącza):** typ, piętra, kierunek kalenicy, obrys → prostokąt, kolor, przesuwanie,
  obrót, rozmiar, ukrywanie budynków OSM, dodawanie nowych, kopiowanie, powrót do oryginału. Zapis F5 do
  `data/blockout/overrides.json`. Instrukcja: `docs/map-editor.md`.
- **13 typów budynków** (`data/buildings/archetypes.json`, plansza `docs/look/archetypes.png`), nowe tekstury: pustaki,
  blacha, brama garażowa, witryna (`tools/art/gen_building_textures.py`, wpisy w `art/manifest.json`).
  Budynki bez zmian autora dostają typ z OSM: mały → garaż, 2 kondygnacje → kostka, 3+ → blok, parterowe → mieszanka
  domów z poddaszem, parterowych, nowych, ceglanych i gospodarczych. Domy są wyższe niż wcześniej (poddasze, kalenica
  do ok. 8 m), co odpowiada na uwagę „budynki wydają się małe”.
- **Testy** (wszystkie zielone): blockout_collision 10, map_editor (z nowymi sprawdzeniami zaznaczania),
  building_editor 30, fly, walker_motion 4, look_gate_collision 7, ink_check. Wydajność: budowa poziomu 0,13 s,
  51–68 wywołań rysowania (limit 250), ok. 58 tys. trójkątów.
- **NIE sprawdzone:** edytor budynków myszą w prawdziwym oknie (przeciąganie, kółko, klikanie przycisków typu).
  Zrzut `docs/look/building_editor.png` pokazuje panel, zaznaczenie i ukryty budynek.
- **Znane ograniczenia:** budynki w kształcie L mają dach płaski, dopóki nie wciśniesz B; drzwi stoją na ścianie
  najbliższej drogi (nie da się ich jeszcze przestawić); nowy budynek ma zawsze 10 × 8 m na start (potem [ ] i obrót);
  zmiana rozmiaru skaluje oba wymiary naraz.
- **Następny krok do ustalenia z autorem:** przejść wieś w edytorze i poprawić typy; potem landmarki wiernie ze zdjęć
  (urząd, szkoła, OSP, ruina stacji). Możliwe dodatki do edytora: osobno szerokość i długość, przestawianie drzwi.


## Co jest zrobione i działa
- **Świat:** centrum Linii z OSM w wyglądzie PS2 (scena główna `scenes/linia_ps2.tscn`), fazy dzień/zmierzch/noc, mgła w każdej fazie.
- **Latanie i narzędzia widoku:** F = latanie (Spacja/E góra, Ctrl/Q dół), G = mgła wł/wył, 1/2/3 pory dnia, P = efekt PS2, F2 = edytor mapy.
- **Kościół** (`src/world/church_model.gd`): model z zdjęć, dopasowany do obrysu OSM (tylny pokój szeroki ±9,4 m, przybudówki s −8,2…−3,4, wystająca ściana z krzyżem, wieża z zegarami, drewniany ganek, niskie skrzydła z dachami jednospadowymi). Autor: „wygląda dobrze, najwyżej kiedyś się zmieni”. Opis: `docs/key-buildings/church.md`.
- **Edytor mapy w grze** (`src/world/map_editor.gd`, `map_props.gd`): ustawianie, obrót, rozmiar, wysokość (PgUp/PgDn), kopiowanie, cofanie; rysowanie ścieżek (kostka, żwir, asfalt), płotów, murów, żywopłotów, z opcją gładkiej krzywej (K). Dane: `data/map/props.json` (kopia `.bak` przy zapisie). Instrukcja: `docs/map-editor.md`.
- **Otoczenie kościoła:** startowy układ z `src/world/church_grounds.gd` (27 obiektów), autor ma go poprawić w edytorze i zapisać (F5).
- **Bestiariusz:** Mòra = akt I (dzień, ukrywa się we wsi), Pólnica = akt II (zmierzch, lasy i pola), Nëczk = akt III. Lista duchów dla grafika została podana w rozmowie.
- **Testy zielone** (ostatni bieg): blockout_collision 10, look_gate_collision 7, walker_motion 4, fly 5, map_editor 32; ground_sweep 0 magenta; ink_check PASS.

## Co NIE było sprawdzone
- Edytor myszą w prawdziwym oknie (test sprawdza logikę, nie kliknięcia). Kursor po puszczeniu PPM może wracać w nieoczekiwane miejsce.
- Noc przy kościele jest prawie czarna (widoczność 12 m) — nie dodano poświaty okien.
- Wysokości kościoła (wieża 22–25 m) to szacunki.

## Do ustalenia z autorem
- Czy front kościoła ma być dopasowany do obrysu OSM (według OSM jest nie szerszy od nawy; model ma ±9,1 m).
- Czy edytor ma obejmować też budynki (zmiana archetypu domu, przesuwanie, obrót) — **to był kolejny planowany etap**: ok. 10–15 typów domów, landmarki wiernie (urząd, szkoła, OSP, ruina stacji, cmentarz), domy prywatne jako typy.
- Poprawianie istniejących ulic OSM w edytorze (teraz nie da się; nowy asfalt jako „Ścieżka: asfalt”).
- Zakres: „1 scena” w `docs/scope.md` §5 vs wnętrza jako osobne sceny — wymaga sformułowania przez Mariusza. GDD pkt 8: Mòra opisana jako „efekt nocny” — wymaga przepisania pod akt I.
- Prawa do zdjęć: autor potwierdził, że ma zgodę (większość jego własnych). V-09 (realne miejsca): autor: maksymalny realizm, zgoda urzędu później.

## Propozycje na kolejną sesję
1. Autor ustawia otoczenie kościoła w edytorze (F2) i zapisuje; zgłasza braki w edytorze (np. przyciąganie do siatki, nowe typy obiektów: latarnie, słupy, ogrodzenia z siatki, cmentarz).
2. Edytor budynków i archetypy domów (`data/buildings/*.json`, nadpisania `data/blockout/overrides.json`, narzędzie zdjęcie → tekstura fasady).
3. Kolejne landmarki ze zdjęć (urząd gminy, szkoła, OSP, ruina stacji), potem teren i las.
4. Poświata okien nocą, mikropoprawki kościoła.
5. Przenoszenie systemów gry ze starego projektu dopiero, gdy świat jest gotowy.

## Reguły pracy (przypomnienie)
Nie commitować; po każdej zmianie wizualnej zrzut ekranu i test; po dodaniu `class_name` uruchom `--headless --import`; własne pliki tymczasowe tylko w projekcie (flatpak nie widzi /tmp).
