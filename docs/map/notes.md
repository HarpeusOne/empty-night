# Linia — notatki o mapie

| Pole | Wartość |
|---|---|
| Data | 2026-11-07 |
| Źródło wiedzy lokalnej | Mariusz (pochodzi z Kaszub, zna Linię) |
| Dane | OpenStreetMap, `data/osm/linia_raw.json` (© OpenStreetMap contributors, ODbL) |
| Plany | `docs/map/plan_village.png`, `plan_overview.png`, `plan_station.png` |
| Skrypty | `tools/osm/` (`fetch_linia.py`, `render_plan.py`, `route_to_lake.py`, `plan_station.py`) |

Nazwy prawdziwych instytucji i ulic na planach są **robocze**; w grze używamy układu, nie nazw (bestiariusz V-09).

## Potwierdzone przez Mariusza

- OSM zawiera wszystkie prawdziwe lokacje, a plany są poprawne.
- **Szkoła** to kompleks: niebieski budynek oraz duży budynek obok (z małym wcięciem), który jest **salą gimnastyczną**. Kościół jest trafiony.
- W wsi **nie ma zniszczonych domów**, są tylko **niedokończone**. Ruiny trzeba **zmyślić**. Jedyna pewna prawdziwa ruina to **budynek stacji kolejowej**.
- **Droga na jezioro:** przy torach jest mała uliczka jak krzywy kwadrat. Od niej idzie ścieżka przez pola, potem las, i idąc cały czas prosto dochodzi się do Jeziora Morzyc.
- **„Krzywy kwadrat” to pętla Okrężna** (Długa + Okrężna, obwód 599 m, środek (−1627, 276)). Trasa do jeziora zaczyna się z jej północno-zachodniego rogu.
- **Budynek stacji to S1** (OSM way 939993183, 483 m², w OSM „building=yes”, 106 m od przystanku). Dziś jest ruiną.
- **Tory w grze:** zarośnięte i opuszczone (decyzja Mariusza, 2026-11-07), mimo że w rzeczywistości są teraz odbudowywane.
- **Nad jeziorem w grze jeden domek** (ten najbliższy końca trasy). Pozostałe domki letniskowe z północnej strony jeziora **wypadają**.
- **Droga na jezioro, kolejność terenu:** najpierw zwykła droga żwirowo-gruntowa przez pola, potem lasy, potem trochę znowu pól, potem lasy, w których leży jezioro, i jeden budynek.

## Co mówi OSM

- Kościół jest początkiem układu współrzędnych (0, 0); +x na wschód, +y na północ, w metrach.
- Odległości od kościoła: urząd 112 m, OSP 126 m, szkoła 224 m, cmentarz 329 m, żwirownia #1 1,1 km (NE), żwirownia #2 2,5 km (SW, przy torach), Jezioro Morzyc 3,85 km (W, w lesie).
- **Nieczynny przystanek „Linia Zakrzewo”** (węzeł `disused:railway=halt`) leży ok. 1,55 km na zachód od kościoła. Przystanek autobusowy „Linia, Dworzec Kolejowy” ok. 220 m od niego. **OSM nie ma budynku stacji.**
- Linia kolejowa nr 229 jest w OSM częściowo oznaczona jako `construction` (PKP PLK), trzy odcinki jako `disused`. Rzeczywisty stan torów może się różnić; w grze przyjmujemy fikcyjny.
- Trasa po drogach OSM od „Dworca Kolejowego” do jeziora: **2377 m** (w linii prostej 2290 m, krętość 1,04), kończy się 15 m od brzegu. Odcinki: Kaszubska → Długa → Okrężna → droga leśna „Leśna” (902 m) → trzy odcinki dróg gruntowych (1065 + 30 + 58 m).

## Profil trasy stacja → jezioro (2377 m)

Teren wg OSM (`tools/osm/route_profile.py`). **„Brak danych”** oznacza, że OSM nie ma tam żadnego wielokąta; interpretacja „pola” w tych miejscach to **wniosek z opisu Mariusza, nie dane**.

| Odcinek (m od początku) | Długość | OSM | Wg Mariusza |
|---|---:|---|---|
| 0 – 450 | 450 | zabudowa i brak danych (skraj wsi) | droga żwirowo-gruntowa, pola |
| 450 – 710 | 260 | brak danych | pola |
| 710 – 1010 | 300 | **pole** | pola |
| 1010 – 1620 | 605 | **las** | las |
| 1620 – 2160 | 535 | brak danych | „trochę znowu pól” |
| 2160 – 2377 | 217 | **las**, potem jezioro | las z jeziorem |

**Domek nad jeziorem:** trasa kończy się **55 m od jednego bungalowu** (OSM: `building=bungalow`, 64 m², 1 kondygnacja, ok. (−3631, 397), 64 m od brzegu). Kolejne domki są dopiero 280–400 m dalej po północnej stronie jeziora (ok. 20 budynków w promieniu 400 m, prawie wszystkie `bungalow` i `outbuilding`).

Plan: `docs/map/plan_station.png`.

## Obserwacja o geografii

Realny układ to **linia na zachód**: centrum (0) → stacja i tory (ok. 1,5 km) → pola → las → jezioro (3,85 km). To naturalny przebieg aktów (Dzień w centrum, Zmierzch przy torach i w polach, Noc w lesie i nad jeziorem). **To tylko obserwacja, nie decyzja;** kompresja odległości jest parametrem (patrz pamięć projektu i GDD §4).

## Uwagi z pierwszego przejścia blockoutu (Mariusz, 2026-11-07)

- **Układ budynków w centrum jest dobry:** przy urzędzie gminy i OSP „czuć, że to to miejsce”. Budynki stoją w dobrych miejscach.
- Budynki **wydają się trochę małe**. Dane: obrysy są realistyczne (mediana domu 90 m², ok. 11 × 8,5 m, 85% domów ma 1 kondygnację), więc winne są raczej **wysokości**: blockout daje płaskie 3 m, a prawdziwy dom z dachem dwuspadowym ma do kalenicy 5–7 m. Do poprawy: dachy dwuspadowe / wyższa kalenica.
- **Brak chodników i poboczy** (OSM ma tylko osie dróg). Do dodania później.
- **Wnętrza to osobne sceny o normalnych proporcjach:** wejście do budynku zmienia mapę na wnętrze z realnymi przestrzeniami pokoi; blockout zewnętrzny służy tylko do chodzenia po wsi. (GDD/scope mówią „1 scena”; sformułowanie wymaga potwierdzenia.)

## Otwarte

- Gdzie umieścić zmyślone, niedokończone i zrujnowane domy (prawdziwa wieś ich nie ma; jedyna pewna ruina to dworzec).
- Skala kompresji odcinka stacja – jezioro (2,4 km) i centrum – stacja (1,5 km).
