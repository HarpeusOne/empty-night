# Trauma Village — kontekst projektu

Gra: linearny survival horror w stylu PS2, Kaszuby, Linia 2026.
Dzień → zmierzch → noc na tej samej przestrzeni. OTS, pistolet + strzelba,
zagadki środowiskowe, 1 typ wroga, 2 zakończenia. Silnik: Godot 4.7.

## Zespół agentów (subagenty)

| Agent | Właściciel katalogów | Rola |
|---|---|---|
| `game-designer` | `docs/` | GDD, balans, zakres, kryteria akceptacji |
| `writer` | `story/`, `docs/bestiary.md` | Ink, dialogi, dokumenty, folklor |
| `artist` | `art/`, `tools/` | ComfyUI, tekstury, portrety, manifest |
| `level-designer` | `levels/`, `docs/level-bible.md` | blockouty, przepływ, zagadki |
| `programmer` | `src/`, `scenes/`, `tests/`, `project.godot` | systemy, shadery, testy |
| `animator` | `anim/`, `docs/anim-list.md` | rig, retarget, AnimationTree |

Pucek (główny agent) jest reżyserem: dzieli zadania, uruchamia subagenty przez
`Task`, scala wyniki i pilnuje kryteriów. Mariusz zatwierdza kierunek i
ocenia grywalność.

## Twarde zasady

- **Nie commituj i nie pushuj.** Commit tylko na wyraźne polecenie Mariusza.
- **Zero runtime LLM w grze.** AI tworzy treść offline; build jest deterministyczny.
- **Zakres v1 jest zamknięty:** 1 wieś, 4 wnętrza, 2 korytarze leśne,
  3 zagadki, 1 typ wroga (3 warianty), 2 bronie, 2 zakończenia, 90–120 min.
  Nowy pomysł spoza zakresu → zapis w `docs/backlog.md`, nie implementacja.
- **Licencje:** tylko modele i assety dopuszczone komercyjnie. Każdy wygenerowany
  obraz ma wpis w `art/manifest.json` (model, seed, licencja, prompt).
  Flux dev (niekomercyjny) jest zakazany.
- **Folklor:** żadnych zmyślonych nazw demonów; każde imię ma źródło w
  `docs/bestiary.md`. Wątpliwości → konsultacja, nie zgadywanie.
- **Język:** kod i nazwy po angielsku, treść gry PL, tłumaczenie EN.

## Uruchamianie subagentów

- Tylko przez narzędzie `Task` z sesji opencode **otwartej w katalogu projektu**.
- `opencode run --agent <name>` nie obsługuje `mode: subagent` — cofa się do
  `build` z pełnymi uprawnieniami. Nie używać do pracy zespołu.
- Subagenty nie podpisują się jako „Pucek”; Pucek to wyłącznie reżyser.
- Commity i push są zablokowane hookami `.git/hooks/pre-commit` i `pre-push`.
  Obejście wyłącznie świadomie: `TV_ALLOW_COMMIT=1 git commit ...`.

## Komendy

```bash
# Godot (flatpak)
flatpak run org.godotengine.Godot --path /var/home/harp9x/github/trauma-village --headless --quit-after 120

# testy
flatpak run org.godotengine.Godot --headless --path . --script res://tests/smoke_test.gd

# grafika (ComfyUI musi działać na 127.0.0.1:8188)
python3 tools/gen.py --prompt "..." --prefix test --seed 1

# walidacja narracji
python3 tools/ink_check.py
```

## Przepływ pracy

1. Pucek wybiera falę zadań i uruchamia subagenty (równolegle, gdy niezależne).
2. Agent pisze tylko w swoich katalogach i kończy raportem: co zrobił,
   pliki, ryzyka, następny krok.
3. Pucek robi review, uruchamia testy i walidator, zgłasza Mariuszowi.
4. Mariusz ocenia vertical slice / build i zatwierdza kolejną falę.

## Definicja ukończenia zadania

- Zmiana działa w Godocie (nie tylko „powinna działać”).
- Test headless lub walidator zielony, albo jawnie opisany brak testu.
- Brak plików poza własnym zakresem, brak sekretów, brak commitów.
