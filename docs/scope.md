# Trauma Village — Scope lock

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 1) |
| Data | 2026-10-29 |
| Status | **zamknięty** — zmiana tylko przez Mariusza |
| Właściciel | `game-designer` |
| Źródło prawdy | `AGENTS.md` (Zakres v1) + ten dokument |

Ten dokument jest **kontraktem**. Jeśli funkcja nie ma wiersza „w zakresie”
z uzasadnieniem, nie wchodzi do v1 — trafia do `docs/backlog.md`.

---

## 1. Zasada nadrzędna

**Zakres v1 jest zamknięty.** Nie rozszerzamy go, żeby „dodać jedną rzecz”,
bo przy jednym deweloperze i 10 h/tydz. każda dodana rzecz to odjęty tydzień
szlifu. Horror to tempo i audio, nie liczba mechanik.

---

## 2. Zawartość świata

| Pozycja | W zakresie | Poza zakresem | Uzasadnienie |
|---|---|---|---|
| Wieś | **1 wieś: 3 ulice (V1–V3) + plac z kościołem (SQ)** | druga wieś, miasto, przysiółki | Jedna przestrzeń obsługuje 3 fazy dnia — druga wieś podwaja koszt level artu bez nowej mechaniki |
| Wnętrza | **4 (I-1…I-4)** | 5+, piwnice, katakumby | 4 wnętrza = 4 okazje na inny typ presji; każde kolejne to ~2 tyg. artu |
| Korytarze leśne | **2 (F1, F2)** | otwarty las, proceduralny las | Korytarz = kontrola tempa i wąskie gardło dla wroga; otwarty las = brak kontroli |
| Brzeg jeziora | **1 strefa (L1)** | pływanie, łódź, wyspa | Brzeg domyka horyzont i daje jedną scenę „ciszy” |
| Strefy łącznie | **11** (V1–V3, SQ, I-1…I-4, F1–F2, L1) | — | 11 stref × ~9,5 min = 105 min |
| Rozmiar mapy | **≈240 × 180 m playable, 3,0–3,4 km ścieżki** | open world, sandbox | Większa mapa zjada budżet minut na chodzenie |
| Wnętrza — wejścia | wszystkie 4 dostępne w akcie, w którym występują | wracanie do zamkniętych wnętrz | Brak backtrackingu do zamkniętych wnętrz; powrót przez tę samą strefę w nowej fazie jest zamierzony (jedna geometria, 3 profile) |
| Pogoda | 3 fazy dnia (Dzień/Zmierzch/Noc), bez deszczu | dynamiczna pogoda, pory roku | Pogoda = 4. profil światła + nowe VFX; 3 fazy już dają całą krzywą nastroju |

---

## 3. Systemy

| Pozycja | W zakresie | Poza zakresem | Uzasadnienie |
|---|---|---|---|
| Kamera | OTS, stała strona, kolizja, quick-turn | kamera swobodna, FPP, cinematic camera | OTS = czytelny wróg i plecak gracza w kadrze; FPP zmienia cały design walki |
| Broń | **pistolet + strzelba** | 3. broń, broń biała, granaty, mołotow | 2 bronie = 2 role (precyzja / tłum); 3. broń to nowy balans amunicji i animacje |
| Celowanie | hitscan, rozrzut, headshot ×2 (pistolet) | balistyka, ricochet, aim-assist | Hitscan jest testowalny headless i tani |
| Plecak | **6 slotów**, amunicja jako licznik, dokumenty osobno | waga, grid, crafting z przedmiotów | 6 slotów wystarcza na 3 bronie + 3 przedmioty; więcej = UI i balans |
| Wróg | **1 typ, 3 warianty (A/B/C)**, 14 instancji, bez respawnu | 2. typ, boss, respawn, fale | Jeden typ = jeden rig, jeden zestaw animacji, jedno AI |
| Zagadki | **3** (łańcuch / sekwencja / wybór) | 5+, zagadki logiczne, szyfry | 3 zagadki × ~7 min = 21 min treści; więcej = blokada tempa |
| Save | **6 świec**, zapis nielimitowany, pełne HP | save anywhere, quicksave, autosave co strefę | Świeca = save + heal + latarnia; trzy role w jednym obiekcie |
| Sloty zapisu | **3 manualne + 1 auto** | 10 slotów, chmura | 3 sloty wystarczą na 2 zakończenia + testy |
| HP / leczenie | 100 HP, leczenie tylko przy świecy | apteczki, regeneracja, bandażowanie | Brak systemu apteczek = brak UI, brak balansu dropów |
| Zakończenia | **2**, flaga z P3 | 3+, sekretne, true ending | 2 zakończenia = 2 sceny finałowe; trzecie to +QA bez zysku |
| Trudność | 1 poziom, brak menu difficulty | easy/normal/hard, assist mode | Balans pod jeden profil; trudność robi faza dnia |
| Latarka | toggle, bez baterii, wpływa na percepcję wroga | baterie, ładowanie, UV | Baterie = 4. zasób; wpływ na percepcję daje całą mechanikę za darmo |
| Interakcja | promień 2,5 m, stożek 60°, 0,4 s | pełny system fizyki, podnoszenie ciał | Tanie, czytelne, testowalne |
| UI | HUD minimalny, plecak pauzujący | mapa, kompas, quest log, dziennik celów | Brak UI = gracz czyta światło i dźwięk |
| Audio | 3 ambienty + 7 cue'ów + SFX | dubbing, dynamiczny miks, muzyka adaptacyjna | Muzyka adaptacyjna to middleware; stinger + cisza działa lepiej |
| Lokalizacja | **PL + EN** | DE/FR/ES/RU/PT-BR | 2 języki = 1 dodatkowy QA pass; każdy kolejny to +1 pass |
| Sterowanie | **pad + klawiatura/mysz**, pełny remap | gyro, touch, VR, Steam Input API | Remap pokrywa 95% potrzeb; gyro to nisza |

---

## 4. Zawartość narracyjna

| Pozycja | W zakresie | Poza zakresem | Uzasadnienie |
|---|---|---|---|
| NPC | **4 (NPC-1…NPC-4)**, dialogi tekstowe | 6+, kompani, handel | 4 NPC = 4 funkcje: dawca przedmiotu, dawca informacji, blokada, świadek finału |
| Dialog | tekst + Ink, PL/EN | dubbing, lip-sync, cinematic | Dubbing = casting, studio, 2 języki, ~3–4 tyg. |
| Folklor | wyłącznie źródła z `docs/bestiary.md` | wymyślone demony, „lore” bez źródła | Zasada z `AGENTS.md`; wiarygodność kaszubska jest wartością produktu |
| Dokumenty w świecie | ~20–25 notatek, 1 dokument = 1 slot w zakładce | audiologgi, nagrania, filmiki | Notatki są tanie i budują świat bez cutscenek |
| Cutscenki | 2 (intro ≤60 s, finał ≤120 s) | 6+, motion capture | 2 cutscenki = 3 min budżetu; resztę opowiada świat |
| Zakończenia | 2 × 2–3 min | 3+ | Patrz wyżej |

---

## 5. Ograniczenia techniczne

| Pozycja | W zakresie | Poza zakresem | Uzasadnienie |
|---|---|---|---|
| Silnik | **Godot 4.7** | Unity/UE, własny silnik | Wybór projektu; 4.7 wspiera potrzebne 3D |
| Rendering | PS2-style: 640×480 wewn., dither, affine, vertex jitter, brak GI | PBR AAA, ray tracing, Lumen | Look jest decyzją artystyczną, nie ograniczeniem |
| Oświetlenie | dynamiczne, ≤12 omni, ≤2 cienie, bez bake'owania GI | lightmapy, SDFGI, VoxelGI | Jedna scena × 3 profile = brak miejsca na pieczenie 3 razy |
| Fazy dnia | **1 plik levelu, 3 `PhaseProfile`** | 3 osobne sceny, duplikacja levelu | Duplikacja = 3× bugi i 3× nawigacja |
| Nawigacja | `NavigationAgent3D`, navmesh per strefa | A*, crowd simulation | Prosty patrol + chase wystarcza dla 14 wrogów |
| Zapis | JSON/`ConfigFile` w `user://`, 1 slot = 1 plik | baza danych, chmura, szyfrowanie | 3+1 sloty, ~50 pól stanu (w tym 14 wrogów i 6 świec) |
| Runtime AI | **brak LLM w grze** | generatywne dialogi, TTS | Zasada z `AGENTS.md`; build musi być deterministyczny |
| Zależności | brak zewnętrznych pluginów poza Ink runtime | middleware audio, Wwise, FMOD | Jeden deweloper = minimalna liczba integracji |
| Wydajność | 60 FPS @1080p, 40 FPS Steam Deck | 4K/120, ray tracing | Target: średni PC i Deck |
| Ładowanie | 1 scena, ≤8 s SSD | strumieniowanie, open world | Linearność = brak strumieniowania |

---

## 6. Język i treść

| Pozycja | W zakresie | Poza zakresem | Uzasadnienie |
|---|---|---|---|
| Języki | **PL (źródłowy) + EN** | DE/FR/ES/RU/PT-BR/UA | 2 języki = 2 passy QA; każdy kolejny +1 pass |
| Kod i nazwy | angielskie | polskie identyfikatory | Zasada z `AGENTS.md` |
| Treść gry | polska, tłumaczona na EN | wersja EN jako źródło | Folklor kaszubski ma sens tylko w PL |
| Tekst UI | ≤400 stringów | 1000+ | 6 slotów, brak quest logu = mało UI |
| Objętość | ~9 000 słów PL (±20%) | 20 000+ | 105 min, 4 NPC, 25 notatek |

---

## 7. Produkcja

| Pozycja | Wartość | Uzasadnienie |
|---|---|---|
| Zespół | 1 deweloper (Mariusz) + agenci | Rzeczywistość projektu |
| Budżet czasu | 10 h/tydz. | Deklaracja Mariusza |
| Zakres czasowy v1 | 9 miesięcy (≈390 h) | 11 stref × ~20 h + systemy ~80 h + QA ~40 h + bufor ~50 h |
| Kolejność | VS-1 → Akt I → Akt II → Akt III → PL/EN QA → demo | Najpierw systemy, potem treść; demo po pełnej grze |
| Definition of done | `docs/acceptance.md` | Mierzalne, nie „działa dobrze” |

---

## 8. Zasada zmiany zakresu

1. **Kto zatwierdza:** wyłącznie **Mariusz**. Nikt inny — w tym Pucek — nie
   może rozszerzyć zakresu v1.
2. **Co robi agent, który chce czegoś spoza zakresu:** dopisuje wiersz do
   `docs/backlog.md` (priorytet, powód odłożenia, źródło) i **kontynuuje pracę
   w zakresie**. Nie implementuje, nie projektuje szczegółów, nie obiecuje.
3. **Co robi `game-designer`, gdy pomysł zgłosi inny agent:** dopisuje wiersz do
   `docs/backlog.md` bez usuwania cudzych wpisów, nadaje priorytet P0/P1/P2 i
   wskazuje, czy to kandydat post-launch.
4. **Warunki wejścia do v1** (wszystkie muszą być spełnione):
   - zatwierdzenie Mariusza,
   - usunięcie innej pozycji o równoważnym koszcie (v1 nie rośnie, tylko się
     wymienia),
   - aktualizacja `GDD.md`, `scope.md`, `acceptance.md` i `day-night.md`
     w tym samym commicie,
   - brak wpływu na 90–120 min i na liczbę 6 świec / 6 slotów / 3 zagadek.
5. **Priorytety backlogu:**
   - **P0** — blokuje v1 lub naprawia błąd blokujący; do zrobienia przed
     pełną grą.
   - **P1** — kandydat post-launch; sensowny, ale nie w v1.
   - **P2** — pomysł do rozważenia po premierze; może nigdy nie wejść.
6. **Zakaz cichego scope creep:** nowa mechanika w kodzie bez wiersza w tym
   dokumencie = błąd review, nie „inicjatywa”.

---

## 9. Mierniki zakresu (do kontroli na review)

| Miernik | Limit v1 | Gdzie sprawdzane |
|---|---:|---|
| Strefy | 11 | `docs/level-bible.md` |
| Wnętrza | 4 | `docs/level-bible.md` |
| NPC | 4 | `story/` |
| Zagadki | 3 | `docs/level-bible.md` |
| Warianty wroga | 3 (1 typ) | `docs/bestiary.md` |
| Bronie | 2 | `src/` |
| Sloty plecaka | 6 | `src/` |
| Świece | 6 | `levels/` |
| Sloty zapisu | 3 + 1 auto | `src/` |
| Zakończenia | 2 | `story/` |
| Języki | 2 | `story/`, `src/` |
| Czas przejścia | 90–120 min | `docs/acceptance.md` |

---

## 10. Historia zmian

| Wersja | Data | Zmiana | Autor |
|---|---|---|---|
| 0.1 | 2026-10-29 | Pierwszy scope lock na podstawie `AGENTS.md` | game-designer |
| 0.2 | 2026-11-07 | Decyzje Mariusza: modyfikator AI wariantu B („ruch tylko niewidziany”, BAL-56); Pùrtk wycofany; demony-spotkania i duchy opiekuńcze jako zawartość istniejących 3 zagadek (BL-25/26), liczby 11 stref / 4 wnętrza / 3 zagadki / 4 NPC bez zmian. **Wymiana pozycji o równoważnym koszcie (§8 pkt 4) nie została wskazana — do potwierdzenia.** | Mariusz (decyzja), Claude (zapis) |
