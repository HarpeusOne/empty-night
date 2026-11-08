# Szkoła w Linii — budynek kluczowy nr 2

Model: `src/world/school_model.gd` (`SchoolModel`), wpięty w `blockout_level.gd` (`SCHOOL_IDS`, `_school_part`).
Zdjęcia referencyjne: `src/key buildings/school/` (14 szt.: zdjęcia z zewnątrz, zrzuty Street View, dwa ujęcia
hali od środka). Służą tylko jako wzór kształtu, proporcji i kolorów; tekstury są proceduralne
(`tools/art/gen_school_textures.py`, wpisy `s_*` w `art/manifest.json`). Street View tylko jako referencja.

## Co jest czym (z planu OSM i zdjęć)
Dwa budynki OSM: „school” (stara szkoła, 1121 m²) i „gym” (1486 m², w tym nowe skrzydło). Oba są teraz jednym
modelem ręcznym i nie ma ich w zakładce Budynki edytora (jak kościoła).

Układ lokalny: s wzdłuż hali w stronę przeszklonego szczytu (na północ), t w poprzek w stronę ulicy Szkolnej.
- **Stara szkoła** (zachód): biało-szara, płaskie dachy z brązowym gzymsem, rzędy okien. Długie skrzydło zachodnie
  i skrzydło północne: 2 kondygnacje (7,4 m). Kuchnia od podwórka i niski łącznik obok niej: parter (szczegóły
  w poprawkach niżej). Wejście (łącznik do nowego skrzydła, kolory hali): parter, szklane drzwi i daszek
  z łukowym dachem na czterech pomarańczowych słupach.
- **Nowe skrzydło** (południowy koniec obrysu „gym”, 18,7 × 14 m): 3 kondygnacje pod łukowym dachem (szczyt 14,4 m),
  szczyt od południa z pomarańczowym pasem i trzema oknami z kratkami, komin na szczycie, świetliki w dachu.
- **Ganek** (wcięcie obrysu od ulicy): słupy, balkon na 1. piętrze z balustradą, schody zewnętrzne wzdłuż ulicy,
  za nim klatka schodowa z płaskim dachem.
- **Hala sportowa** (47 m): łukowy brązowy dach z blachy (szczyt 13,2 m), ściany 4,6 m z pomarańczowymi pilastrami,
  dużymi oknami i łososiowym cokołem, drzwi z daszkiem po stronie ulicy, świetliki. Szczyt północny (od boiska):
  beżowa blacha i przeszklenie schodkowe.

## Poprawki po uwagach autora (2026-11-08, runda 1)
- Wejście: drzwi na wprost ścieżki, słupy daszka rozstawione tak, że środkowe przęsło jest wolne (wcześniej słup stał
  przed drzwiami).
- Stara szkoła biało-szara (szary cokół, szary pas na wysokości okien parteru); łącznik między starą szkołą a nowym
  skrzydłem w kolorach hali (beż, pomarańcz, łososiowy cokół).
- Kuchnia (parterowe skrzydło od podwórka): dwa okna po bokach, na środku drzwi do kuchni z czerwonymi schodkami,
  drabina na dach, dach jednospadowy rosnący do tyłu (4,2 → 6,0 m), za nią część piętrowa.
- Niski łącznik między skrzydłem zachodnim a kuchnią: cały parterowy, 4 okna od podwórka.
- Szczyt skrzydła zachodniego od strony biblioteki: bez okien, szeroki szary pas z góry na dół.

## Poprawki po uwagach autora (2026-11-08, runda 2)

- **Brakujące pomieszczenie przy wejściu:** OSM zostawia wcięcie między kuchnią a wiatrołapem; autor mówi, że stoi
  tam pomieszczenie. Wiatrołap jest teraz jednym prostokątem (s -0,9..5,5, t -11,6..-6,1). Obrys do kolizji też ma
  ten narożnik (`SchoolModel.footprint_en`), dane OSM w `centrum.json` zostają bez zmian.
- **Daszek wejścia** opiera się tylnym brzegiem o ścianę, biegnie od bocznej ściany kuchni do narożnika nowego
  skrzydła, przód zaokrąglony schodzi na belkę na czterech filarach. Środkowe przęsło (t -8,4..-3,8) jest wolne na
  wprost ścieżki, a pod daszkiem jest nawierzchnia jak na ścieżce, więc ścieżka dochodzi do drzwi (t -7,0).
- **Ganek:** schody zaczynają się na ziemi przy otwartym, południowym końcu ganku i wchodzą na podest przy górnych
  drzwiach klatki (wcześniej kończyły się na ścianie). Balustrady są grubsze, z poręczą, przeczką i szczeblami.
- **Okna nad niskimi dachami:** ściany piętra stojące nad niższym dachem (np. nad łącznikiem) mają okna piętra.

## Poprawki po uwagach autora (2026-11-08, runda 3: wejście wg zdjęcia autora)

- Front wiatrołapu jest płaski od kuchni do t -3,8. OSM cofa go dwa razy, zdjęcie pokazuje jedną ścianę. Obrys do
  kolizji ma ten sam kształt (`RING_DROP`, `RING_MOVE` w `school_model.gd`).
- Daszek wejścia stoi **prostopadle do ściany**, nad końcem ścieżki: łukowy szczyt od strony ścieżki, dwa filary z
  przodu i dwa przy ścianie, pod nim drzwi (t -6,1, na osi ścieżki) i jedno okno. Na lewo od daszku jest ściana z jednym
  oknem, na prawo, we wnęce przy nowym skrzydle, niski daszek jednospadowy nad oknem.
- Runda 4: środkowy filar daszku celowo pominięty (decyzja autora, licencja artystyczna). Z przodu są dwa filary.
- Zrzut porównawczy: `docs/look/school_entrance.png`.

## SZACUNKI (do poprawy przez Mariusza)
- Wysokości (skrzydło 14,4 m, hala 13,2 m, stara szkoła 7,4 / 4,2 m) i podział starej szkoły na części
  dwu- i jednokondygnacyjne są odczytane ze zdjęć; który kawałek starej szkoły jest parterowy, to zgadywanie.
- Długość skrzydła (14 m) i to, gdzie zaczyna się hala, nie wynika z OSM.
- Okna starej szkoły są rozstawione automatycznie (rzędy co 2,7 m), nie według zdjęć.
- Zachodnia ściana hali (od podwórka) jest jak wschodnia; jej nie widać na zdjęciach.

## Czego nie ma
Biblioteki (osobny budynek przy parkingu; zwykły dom w edytorze budynków, można mu zmienić typ i okna),
budynku przy boisku, boisk, ogrodzenia, drabin pożarowych na ścianach starej szkoły, masztu z flagą, wnętrz.
Otoczenie (siatka, chodniki, krzewy) można dorysować w edytorze mapy (F2).

## Zrzuty
`docs/look/school_*.png` (`tools/school_shots.gd`; każdy widok ma w komentarzu zdjęcie, któremu odpowiada).
