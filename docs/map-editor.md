# Edytor mapy (F2)

Narzędzie dla autora: ustawianie obiektów w grze zamiast opisywania ich słowami. Nie jest częścią gry.

Uruchomienie: `flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village-v2`, potem **F2**.
Edytor sam włącza latanie. Ma dwie zakładki: **Obiekty** i **Budynki** (przełącza **F3** albo przyciski u góry panelu).
Zapis: **F5** lub przycisk „Zapisz”. Zapisuje obie zakładki: obiekty do `data/map/props.json`, budynki do
`data/blockout/overrides.json` (kopie poprzednich wersji: `.bak`). Cofanie (**U**) obejmuje obie.

## Sterowanie
| Co | Jak |
|---|---|
| Rozglądanie | trzymaj **prawy przycisk myszy** |
| Lot | WASD, **Spacja/E** w górę, **Ctrl/Q** w dół, **Shift** szybciej |
| Zaznacz | lewy klik na obiekcie (płot, ścieżka, drzewo, ławka…) |
| Przesuń | przeciągnij zaznaczony obiekt lewym; punkt linii przeciągasz za jego krzyżyk |
| Obrót | **kółko myszy** (5°, z Shift 45°) albo **R / T** (15°) |
| W górę / w dół | **Page Up / Page Down** (10 cm, z Shift 50 cm); **Home** = z powrotem na ziemię. Działa też na całych liniach (płot, ścieżka) |
| Krzywa / proste | **K**: zaznaczona linia (albo rysowana właśnie) zmienia się z odcinków prostych w gładką krzywą przechodzącą przez punkty, i z powrotem. Krzywa wymaga 3+ punktów; łuki o różnych kształtach robisz ustawieniem punktów |
| Rozmiar | **[** i **]**; dla ścieżki: węższa / szersza |
| Postaw obiekt | wybierz z listy po lewej, klikaj na ziemi (Esc kończy) |
| Rysuj linię | wybierz ścieżkę / płot / mur / żywopłot, klikaj kolejne punkty, **Enter** kończy, **Backspace** cofa ostatni punkt |
| Rysuj plac | wybierz „Plac: …”, klikaj kolejne rogi (dowolny wielokąt: trapez, L, pięciokąt…), **Enter** zamyka wielokąt (min. 3 rogi). **K** = zaokrąglone brzegi. Zaznaczony plac: rogi przeciągasz za krzyżyki, **I** dodaje róg, **X** usuwa zaznaczony róg, **[ ]** zmniejsza / powiększa cały plac |
| Wstaw punkt do linii | zaznacz linię, najedź kursorem, **I** |
| Usuń | **X** lub **Delete** (zaznaczony punkt linii, a gdy żaden, cały obiekt) |
| Kopiuj | **C** (kopia obok, +2 m) |
| Następny obiekt pod kursorem | **Tab** (gdy obiekty na siebie nachodzą, np. ławka pod koroną drzewa na ścieżce) |
| Cofnij | **U** lub Ctrl+Z (do 60 kroków) |

Fazy dnia (1/2/3) i mgła (G) działają w edytorze, więc można sprawdzić układ w każdej porze. Warto wyłączyć mgłę (G).

## Budynki (zakładka „Budynki”, F3)
| Co | Jak |
|---|---|
| Zaznacz | lewy klik na ścianie albo dachu. Ukryty budynek: klik w jego **czerwony obrys** na ziemi |
| Przesuń | przeciągnij lewym |
| Obrót | **kółko** (5°, z Shift 45°) albo **R / T** (15°), wokół środka budynku |
| Rozmiar | **[** i **]** (o 5%) |
| Typ budynku | klik na typ z listy (zmienia zaznaczony) albo **,** i **.** (poprzedni / następny) |
| Piętra | **Page Up / Page Down** (1–6) |
| Kierunek kalenicy | **V** (obrót dachu o 90°) |
| Obrys → prostokąt | **B**. Budynki w kształcie litery L i krzywe obrysy z OSM mają dach płaski, bo dach spadzisty do nich nie pasuje; B upraszcza obrys do prostokąta i daje normalny dach. Drugie B wraca do obrysu z OSM |
| Kolor ścian | **N** (kolejny z palety danego typu) |
| Ukryj / usuń | **X** lub Delete. Budynek z OSM tylko się chowa (czerwony obrys, X przywraca); dodany przez Ciebie znika |
| Nowy budynek | **Esc** (nic nie zaznaczone), klik na typ z listy, klik na ziemi (10 × 8 m), potem przesuwasz, obracasz, zmieniasz rozmiar |
| Kopiuj | **C** (kopia obok, +4 m, ten sam kształt i typ) |
| Przywróć oryginał | **Home** (cofa wszystkie zmiany tego budynku) |
| Elewacja | **E** (tynk jasny, tynk szary, cegła, deski, pustaki, tynk biały; po pełnym kółku wraca elewacja z typu) |
| Okna i drzwi | **O** (tryb okien i drzwi, opis niżej) |

### Okna i drzwi (zaznacz budynek, potem O)
Panel pokazuje wtedy rodzaje otworów: okno, okno świecące nocą, okienko, okno szerokie, witryna, otwór bez szyby, drzwi,
wejście ciemne, brama garażowa, wrota. Niebieskie ramki to otwory budynku, żółta to zaznaczony.

| Co | Jak |
|---|---|
| Zaznacz otwór | klik w okno albo drzwi na ścianie |
| Przesuń | przeciągnij (także na inną ścianę tego budynku); drzwi i bramy zawsze stoją na ziemi |
| Nowy | klik rodzaju w panelu (bez zaznaczonego otworu), potem klik w ścianę; zielona ramka pokazuje, gdzie stanie. Rodzaj zostaje wybrany, więc można stawiać kolejne; Esc = tylko wybór |
| Zmień rodzaj | zaznacz otwór i kliknij rodzaj w panelu albo **,** / **.** |
| Szerokość / wysokość | **[ ]** szerokość, **-** / **=** wysokość (Shift = drobniej) |
| W górę / w dół | **Page Up / Page Down** (co 10 cm, Shift co 5 cm) |
| Kopia obok | **C** (np. rząd okien) |
| Usuń | **X** lub Delete |
| Wróć do automatycznych | **Home** |
| Wyjście | **O** albo **Esc** (Esc najpierw odznacza otwór) |

Dopóki niczego nie zmienisz, budynek ma okna i drzwi rozstawione automatycznie. Pierwsza zmiana zamienia ten układ na
własną listę budynku (`openings` w `data/blockout/overrides.json`) i od tej pory okna nie przesuwają się same, także po
zmianie typu albo pięter. Otwór, który po zmianie rozmiaru budynku nie mieści się na ścianie, jest dosuwany do jej
krawędzi; numery ścian zmieniają się po **B** (prostokąt), więc okna ustawiaj po uproszczeniu obrysu.

Typy (13) są w `data/buildings/archetypes.json`: dom parterowy, dom z poddaszem, nowy dom z dachem kopertowym, kostka PRL,
stary dom z cegły, stary dom drewniany, blok, sklep, garaż, stodoła, budynek gospodarczy, dom niedokończony (pustaki,
bez dachu), budynek publiczny. Podgląd wszystkich: `docs/look/archetypes.png`. Każdy budynek bez Twojej zmiany ma typ
dobrany automatycznie z danych OSM (wielkość, liczba kondygnacji) i w panelu ma dopisek „(domyślny)”.
Parametry typu (wysokość piętra, nachylenie dachu, kolory, okna) można zmieniać w tym pliku; zmiana działa od razu
dla wszystkich budynków tego typu.

Kościół jest modelem ręcznym i w zakładce Budynki się go nie edytuje (ani bryły, ani okien).

## Obiekty
Punktowe: iglak, drzewo liściaste, krzew kulisty, drzewko kuliste (na pniu), krzyż drewniany (wg zdjęcia: wysoki słup,
promienie wokół skrzyżowania, ząbkowana krawędź), krzyż żelazny, kapliczka, głaz (pomnik z tabliczką), nagrobek,
nagrobek podwójny, znicz, znicze (kilka), ławka z oparciem, ławka bez oparcia, kosz na śmieci, tablica ogłoszeń (metalowa).
Linie: ścieżka z kostki (szara, czerwona, grafitowa), żwirowa, asfaltowa, płot ceglany, płot kamienny, mur kamienny,
żywopłot z tui, żywopłot strzyżony (blok 1 m, z kolizją).
Place (wielokąty): kostka szara, czerwona, grafitowa, żwir, asfalt.

**Kostka jako jedna powierzchnia:** wszystkie ścieżki i place z tej samej nawierzchni leżą na tej samej wysokości i mają
wzór w układzie świata, więc nachodzące na siebie kawałki kostki szarej łączą się bez szwów (tak samo żwir, asfalt).
Nawierzchnie leżą warstwami: asfalt najniżej, potem żwir, kostka szara, grafitowa, a czerwona na samej górze, więc
czerwony pas narysowany przez szary plac jest na nim widoczny. Duże plamy kostki rysuj jako plac, a nie z wielu ścieżek.

**Znicze** stawiane na nagrobku same stają na płycie (także po przeciągnięciu); na ziemi stoją na ziemi. Świecą lekko
w dzień, mocno o zmierzchu i w nocy.

Zrzuty nowych obiektów: `tools/props_shot.gd` -> `docs/look/props_*.png`.
Dodawanie nowych typów: `src/world/map_props.gd` (`TYPES` i `_point_mesh` / `_build_*`); tekstury
`tools/art/gen_props_textures.py` (wpisy w `art/manifest.json`).

## Uwagi
- Drogi z OpenStreetMap (asfalt istniejących ulic) są częścią mapy bazowej i edytor ich nie zmienia; nowy lub poprawiony asfalt rysujesz jako „Ścieżka: asfalt”, a kostkę jako „Ścieżka: kostka”.
- Zmiany nie wchodzą do gry, dopóki ich nie zapiszesz; po zapisie plik `data/map/props.json` jest prawdą (nie `church_grounds.gd`).
- Ścieżki nie mają kolizji (da się po nich chodzić), płoty, pnie, krzyże, ławki i kapliczki blokują.
- Test: `tests/map_editor_test.gd`, `tests/building_editor_test.gd`; zrzuty interfejsu: `tools/editor_shot.gd` -> `docs/look/editor.png`,
  `tools/building_editor_shot.gd` -> `docs/look/building_editor.png`, `building_openings.png` (okna i drzwi ustawione ręcznie,
  cegła), `building_openings_auto.png` (ten sam dom przed zmianą); typy budynków: `tools/archetypes_shot.gd` + `python3 tools/art/arch_sheet.py` -> `docs/look/archetypes.png`.
