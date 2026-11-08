# Bramka wyglądu PS2 — notatki

| Pole | Wartość |
|---|---|
| Data | 2026-11-07 |
| Status | **kierunek zatwierdzony przez Mariusza (2026-11-07), do dalszego szlifowania** |
| Scena | `scenes/look_gate.tscn` (główna scena projektu) |
| Zrzuty | `docs/look/look_<widok>_<faza>.png` (widoki: house, street, porch; fazy: day, dusk, night) |
| Narzędzie zrzutów | `tools/look_shots.gd` |

Makieta to **jedna ulica i jeden typowy dom Linii** (jedna kondygnacja + poddasze, dach dwuspadowy, tynk, płot, sosny, słup z przewodami, latarnia). Dom ma wymiar mediany z danych OSM (ok. 11 × 8,5 m). To dekoracja do oceny wyglądu, nie prawdziwe miejsce.

## Z czego składa się wygląd PS2

| Element | Gdzie | Wartość |
|---|---|---|
| Niska rozdzielczość | `look_gate_view.gd` | świat 3D w SubViewport o połowie okna (640×480 przy oknie 1280×960), powiększenie filtrem nearest |
| Oświetlenie na wierzchołkach | `ps2_surface.gdshader` | słońce + ambient + do 4 świateł punktowych, liczone w wierzchołkach; kolor wierzchołka = wypieczony AO |
| Mgła | `ps2_surface.gdshader` | liniowa po głębokości, kolor = horyzont nieba |
| Drżenie wierzchołków | `ps2_surface.gdshader` | przyciąganie do siatki 640×480 (`snap_grid`) |
| Banding + dithering | `ps2_post.gdshader` | 32 poziomy koloru na kanał, macierz Bayera 4×4 |
| Kolor, ziarno, winieta | `ps2_post.gdshader` | odbarwienie, odcień per faza, ziarno animowane 24 Hz |
| Tekstury | `tools/art/gen_textures.py` | 128 px (okna, drzwi 64 px), generowane procedurą, wpis w `art/manifest.json` |

## Kierunek (decyzja Mariusza, 2026-11-07)

- **Tak, to ten kierunek**, ale **brudniej**: chłodno, szaro, ponuro, jak polska wieś w pochmurny dzień. „Chłodno, szarawo, chujowo.”
- **Gładsze PS2**, nie PS1: bez afinicznego wykrzywiania tekstur.
- **Mgła we wszystkich fazach**, mocniejsza niż w pierwszej wersji. Zmienia się tylko zasięg widzenia zależnie od pory dnia.
- **Mniej słonecznie**: pochmurne niebo, słabe światło kierunkowe.
- **Światła żółte**, bo stare (latarnie, żarówki w oknach).

## Fazy (jeden zestaw liczb: `PS2Look.phase()`)

Zasięgi widzenia pochodzą z GDD §5 (dzień 60 m, zmierzch 35 m, noc 12 m, 20 m z latarką, której jeszcze nie ma). `fog_end` jest 15% dalej niż nominalny zasięg, żeby przedmiot dokładnie na granicy był jeszcze słabo widoczny.

| | Dzień | Zmierzch | Noc |
|---|---|---|---|
| Zasięg widzenia (GDD) | 60 m | 35 m | 12 m |
| Mgła (początek – koniec) | 6 – 69 m | 3,5 – 40 m | 1,2 – 14 m |
| Światło | pochmurno, prawie bez słońca | niskie, przygaszone | księżycowy błękit |
| Latarnia / okno | wyłączone | żółte, słabe | żółte, mocne |
| Nasycenie | 0,58 | 0,55 | 0,50 |
| Ziarno | 0,05 | 0,06 | 0,085 |

W zrzutach nocnych kamera jest bliżej obiektu (połowa dystansu), bo przy 12 m widoczności dom stojący 15 m dalej byłby po prostu zamglony.

## Wygląd PS2 na mapie z OSM (centrum Linii)

Scena `scenes/linia_ps2.tscn` (teraz główna scena projektu) pokazuje blockout z OSM w tym samym wyglądzie. Zrzuty: `docs/look/linia_<miejsce>_<faza>.png` (kościół, urząd, OSP, szkoła, start).

- **Budynki:** 368; **dach dwuspadowy** na 335 (dom z obrysem zbliżonym do prostokąta, kalenica wzdłuż dłuższego boku, nachylenie jak w makiecie), płaski na 33. Ściany po 2,8 m na kondygnację. Kościół ma stromy dach i wysokie wąskie okna w jednym rzędzie, sala gimnastyczna pas wysokich okien.
- **Okna i drzwi:** 4216 okien; drzwi od strony najbliższej drogi; ok. 22% okien oświetlonych (żółte) o zmierzchu i w nocy.
- **Wariacje:** 7 odcieni tynku, 2 tekstury tynku, dachówka czerwona lub brązowa, komin na większości domów.
- **Drogi:** asfalt dla dróg utwardzonych, żwir dla gruntowych i ścieżek.
- **Mgła na piksel** (zamiast na wierzchołek): gładsza i bez artefaktów na wielkich płaszczyznach.
- **Wydajność** (`tools/linia_perf.gd`): 14 wywołań rysowania i ok. 55 tys. trójkątów na klatkę (limity GDD: 250 i 350 tys.), czas budowy poziomu ok. 0,14 s (limit 8 s). Pomiar czasu klatki jest po stronie CPU na RTX 5080, **więc nie mówi nic o docelowym sprzęcie** (GTX 1050, Steam Deck); do sprawdzenia, gdy będzie sprzęt.

## Czego celowo nie zrobiono

- **Afiniczne mapowanie tekstur** (PS1): shader ma `affine_amount`, ale jest 0. Przy dużych ścianach z kilkoma wierzchołkami wyglądałoby źle bez gęstszej siatki.
- **Cienie.** Oświetlenie na wierzchołkach nie rzuca cieni.
- **Latarka gracza** i więcej niż 4 światła punktowe.
- Chodniki, pobocza z detalami, trawa jako osobne obiekty, tekstury zależne od miejsca.

## Lekcje techniczne (żeby nie powtarzać)

- **Kontrolka tworzona z kodu** i dodana do okna miała rozmiar 0×0, więc nic się nie rysowało (a logi były czyste). Trzeba `set_anchors_and_offsets_preset()`, samo `set_anchors_preset()` nie wystarcza; ręczne `size` razem z kotwicami psuje rozmiar.
- **Tablice uniformów** w shaderze nie przyjęły wartości, więc światła punktowe są czterema osobnymi uniformami.
- **Z-fighting** płaskich warstw (ziemia, żwir, droga) znikał dopiero po `near = 0.2` kamery i odstępach 4–8 cm między warstwami. Przy `near = 0.05` plamy pojawiały się na dystansie.
- **Szczeliny (T-junction)** między siatkami o różnej gęstości przepuszczały niebo; naprawione wielką podstawą ziemi 30 cm niżej.
- **Trawa znikała przy niektórych kątach kamery** (zgłoszone przez Mariusza ze zrzutem, 2026-11-07): w 197 z 1500 klatek
  pomiarowych, w najgorszym razie na pół ekranu, w miejsce gęstej siatki ziemi wskakiwała wielka podstawa (800 m).
  Przyczyna: **drżenie wierzchołków na wielkich trójkątach**. Przesunięcie wierzchołka o ułamek piksela przechyla
  całą płaszczyznę głębi o dziesiątki centymetrów, więc daleka ziemia wygrywa test głębi z gęstą siatką. To nie
  był z-fighting (byłby zaszumiony). Poprawka: drżenie tylko dla wierzchołków bliższych niż `snap_max_depth` (60 m).
  Po poprawce 0 z 1500 klatek. Narzędzie regresyjne: `tools/ground_sweep.gd`.
- **Droga i kamera „trzęsły się” przy chodzeniu** (zgłoszone przez Mariusza, 2026-11-07). Pomiar (`tools/walk_smoothness.gd`,
  okna 7 ms jak na monitorze 144 Hz): chodzik poruszał się tylko w tyku fizyki (60 Hz), więc przy szybszym wyświetlaniu
  **57% klatek monitora nie pokazywało żadnego ruchu kamery** (zmienność prędkości 1,16). Teraz chodzik rusza się w `_process`:
  0% klatek bez ruchu, zmienność 0,05, prędkość 1,98 m/s. Przy okazji: wierzchołki nie drżą domyślnie (`snap_grid` = 0,
  „gładsze PS2”), tekstury mają mipmapy i filtrowanie anizotropowe 16× (asfalt z pęknięciami migotał), warstwy dróg
  leżą dalej od siebie. Test regresyjny: `tests/walker_motion_test.gd`. Docelowa gra potrzebuje właściwej interpolacji
  fizyki, a nie ruchu w `_process`; to rozwiązanie dotyczy chodzika deweloperskiego.
- **Pierwsze dwie wersje detektora tego błędu były ślepe** (kontrola pozytywna wykryła 2 z 19 200 próbek, potem
  liczył też legalną daleką ziemię). Zawsze sprawdzaj, czy detektor w ogóle widzi to, czego szuka.
- Zielone testy nie wykryły żadnego z tych błędów. Wykryło je dopiero oglądanie zrzutów (a ten ostatni zgłosił Mariusz).

## Sterowanie (F5)

1 / 2 / 3 faza (dzień / zmierzch / noc), P efekt PS2 wł./wył., WASD + mysz, Shift szybciej, Esc zwalnia mysz, H ukrywa podpowiedź.
Sterowania **nie sprawdzałem ręcznie**; sprawdzone są tylko kolizje (`tests/look_gate_collision_test.gd`) i zrzuty.

## Do dalszego szlifowania

Pokrętła, które można zmienić bez przebudowy: rozdzielczość wewnętrzna, siła ditheringu i banding, ziarno, odbarwienie, mgła, tekstury, ilość brudu, drżenie wierzchołków. Brakuje jeszcze cieni, chodników, detalu terenu (trawa, błoto, kałuże jako obiekty), latarki gracza.
