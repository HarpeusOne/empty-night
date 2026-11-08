# Kościół w Linii — pilot budynku kluczowego

Model: `src/world/church_model.gd`, wpięty w `blockout_level.gd` (`_church`).
Zdjęcia referencyjne: `src/key buildings/church/` (9 szt., `.gdignore`, nie wchodzą do builda).

## Założenia modelu
- Obrys z OSM (kolizja: prosty obrys, wysokość 9 m, więc test ścian nadal go pilnuje). Orientacja `CHURCH_HEADING_DEG = 115`.
- Układ: prezbiterium (tył) → nawa → przedsionek-korpus → wieża zegarowa → drewniany ganek z kamiennymi słupami i zielonymi drzwiami; przybudówki boczne; cokół z kamienia polnego.
- Wieża: 3 zegary, balustrada, dzwonnica z łukami, dach piramidalny, krzyż.
- Zdjęcia służą tylko jako wzór kształtu, proporcji i palety. Tekstury są generowane proceduralnie (`tools/art/gen_church_textures.py`, wpisy `c_*` w `art/manifest.json`).

## Poprawki po uwagach autora (2026-11-07)
- Budynek obrócony o 180°: front z wieżą jest tam, gdzie był tył (rotacja wokół środka korpusu, w `ChurchModel._init`). Rogi modelu nadal leżą w obrębie ~1 m od obrysu OSM (`tools/church_fit_check.gd`).
- Tył: po lewej witraż (łukowy), po prawej zwykłe okno (patrząc od tyłu), krzyż pośrodku.
- Drzwi na obu końcach przybudówek bocznych.
- Naprawione dziury: ściana między prezbiterium a nawą, tylna ściana szerszej części frontowej obok nawy.
- Spody dachów (ganek, przybudówki, okapy), żeby dachy nie znikały widziane od dołu.

## Poprawki, runda 2 (2026-11-07, po lataniu)
- Ganek: kolumny w całości drewniane; kamień tylko na fasadzie wieży za gankiem (cała szerokość wieży, do 5,2 m).
- Przybudówki: drzwi główne na ŚRODKU zewnętrznej ściany (zamiast okna), drzwi dla księdza/ministrantów na bocznej ścianie od strony prezbiterium. Obie strony symetrycznie, do korekty, jeśli strony różnią się.
- Balustrada wieży widoczna z obu stron; górne ścianki gzymsów i podsufitka mają teksturę w skali świata (wcześniej jedna kafelka rozciągnięta na całość = gładki szary).
- Tył: duże przeszklenia po obu stronach, wysunięta ściana z krzyżem z własnym daszkiem i cokołem.
 — SZACUNKI (do poprawy przez Mariusza)
Wysokość wieży ok. 22–25 m, nawa 6 m do okapu, prezbiterium 4,6 m. Brak pomiarów.

## Czego nie ma
Wnętrza (osobna scena, normalne proporcje), detali witraży, otoczenia (cmentarz, ogrodzenie).

## Otwarte
- Prawa do zdjęć / zgoda na odwzorowanie (do potwierdzenia).
- V-09: wrażliwość realnego kościoła i prywatnych domów w horrorze.

## Zrzuty
`docs/look/church_*.png` (`tools/church_shots.gd`).

## Otoczenie kościoła i edytor mapy (2026-11-08)
Pierwszy układ otoczenia (kostka, płoty, krzyże, ławki, drzewa) był zgadnięty i autor uznał go za słaby, więc
otoczenie jest teraz **edytowalne w grze** (F2). Dane: `data/map/props.json` (zapisuje je edytor; przy zapisie
poprzednia wersja trafia do `props.json.bak`). Pierwszy układ startowy to `src/world/church_grounds.gd` (używany
tylko, gdy pliku nie ma). Kod: `src/world/map_props.gd` (budowa obiektów z danych), `src/world/map_editor.gd` (edytor).
Instrukcja: `docs/map-editor.md`.

## Poprawki, runda 3 (2026-11-08, nowe zdjęcia tyłu i boków)
Zdjęcia: `src/key buildings/church/back and left side (2026-11-08).png`, `back and whole right side (2026-11-08).png`,
`tower front and the wooden cross (2026-11-08).png`. Zrzuty z tych samych stron: `docs/look/church_photo_*.png`.
- Tył ma ściany tak wysokie jak nawa (6 m), bez okien i drzwi na bokach, pod stromym ciemnym dachem kopertowym, którego
  szczyt sięga kalenicy nawy. Wysunięta ściana z krzyżem ma własny stromy dach kopertowy, więc od tyłu widać dwa szczyty
  z koszem między nimi.
- Duże okna w drewnianych ramach wypełniają prawie całe narożne ściany (od cokołu pod okap), po obu stronach ściany z krzyżem.
- Krzyż na tylnej ścianie: brązowy, drewniany, 4,1 m, wystaje ze ściany (wcześniej czarny, płaski).
- Drzwi dla księdza i ministrantów: na lewym boku wysuniętej ściany z krzyżem (jedyna ściana, której nie widać na zdjęciach;
  do potwierdzenia).
- Dachy: nawa, skrzydła przy wieży i przybudówki boczne zielone (patyna), tył i hełm wieży ciemnoszare, ganek bez zmian.
- Przybudówki boczne wyższe (4,6 m), dach tuż pod okapem nawy, po obu stronach drzwi z małym oknem łukowym nad nimi.
- Nawa: po dwa okna między tyłem a przybudówką (było jedno).
