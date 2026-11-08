# Trauma Village - lista animacji

| Pole | Wartość |
|---|---|
| Wersja | 0.1 (Fala 2) |
| Data | 2026-10-29 |
| Właściciel | `animator` |
| Status | `anim/raw/` pusty, klipy modeli: `brak`, systemy proceduralne: `gotowy` |
| Powiązane | `docs/GDD.md`, `docs/day-night.md`, `docs/bestiary.md`, `story/outline.md`, `docs/art-bible.md` |

> **Stan dostawy.** W dniu 2026-10-29 katalog `anim/raw/` jest pusty. Nie ma
> ani jednego FBX/GLB, więc żaden klip modelu nie jest zaimportowany ani
> zretargetowany. Tabela poniżej jest zamówieniem i kontraktem importu, nie
> raportem z wykonanego importu. Systemy proceduralne z `anim/procedural/`
> działają i są objęte walidacją headless.

---

## 1. Konwencja i statusy

**Nazwa klipu:** `<postac>_<akcja>_<wariant>`, wyłącznie małe litery ASCII,
cyfry i podkreślenia. Przykład: `player_aim_walk_default`,
`enemy_attack_c`.

**Status:**

- `brak` - plik nie istnieje w `anim/raw/`, nie ma importu.
- `surowy` - plik jest w `anim/raw/`, ale nie ma retargetu, pętli i testu.
- `gotowy` - klip lub skrypt działa w Godocie i jest objęty walidacją.

**Kody wymagań:**

- `H30/FBX` - Mixamo FBX 7.4 binary, 30 fps w źródle, T-pose, in-place,
  keyframe reduction wyłączony, root motion wyłączony, humanoid, Y-up,
  jednostka cm. W Godot ustaw skalę 0.01 tylko wtedy, gdy po imporcie
  postać ma więcej niż 10 m wzrostu.
- `H30/GLB` - glTF 2.0, 30 fps w źródle, T-pose, in-place, bez keyframe
  reduction, root motion wyłączony, humanoid, metry.
- `PROC` - skrypt proceduralny w `anim/procedural/`, bez zewnętrznego assetu.
- `KOD` - istniejący kod w `src/`, bez nowego assetu.

**Zasada plików:** jeden plik = jeden klip. Nazwa pliku bez rozszerzenia jest
identyczna z nazwą klipu. Jeśli Mariusz dostarczy pack z wieloma klipami,
nazwy klipów w packu muszą być dokładnie takie same jak w tabeli.

**Root motion:** domyślnie wyłączony dla każdego klipu. Żaden klip nie
przesuwa `CharacterBody3D`. Ruch gracza i wroga liczy `src/`.

---

## 2. Gracz

Postać: Marta Kreft. Kamera OTS, postać obraca się z kamera, więc potrzebne
są osobne klipy dla chodu, biegu, strafe i celu.

| Klip | Plik źródłowy | Długość | Pętla | Root motion | Status | Właściciel | Wymagania |
|---|---|---:|---|---|---|---|---|
| `player_idle_default` | `anim/raw/player/player_idle_default.fbx` | 3.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_walk_default` | `anim/raw/player/player_walk_default.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_run_default` | `anim/raw/player/player_run_default.fbx` | 0.7 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_aim_idle_default` | `anim/raw/player/player_aim_idle_default.fbx` | 2.5 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_aim_walk_default` | `anim/raw/player/player_aim_walk_default.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_strafe_l_default` | `anim/raw/player/player_strafe_l_default.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_strafe_r_default` | `anim/raw/player/player_strafe_r_default.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_shoot_pistol` | `anim/raw/player/player_shoot_pistol.fbx` | 0.45 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_shoot_shotgun` | `anim/raw/player/player_shoot_shotgun.fbx` | 0.90 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_reload_pistol` | `anim/raw/player/player_reload_pistol.fbx` | 1.60 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_reload_shotgun` | `anim/raw/player/player_reload_shotgun.fbx` | 0.60 s / nabój | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_hit_default` | `anim/raw/player/player_hit_default.fbx` | 0.40 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_death_default` | `anim/raw/player/player_death_default.fbx` | 2.00 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_interact_default` | `anim/raw/player/player_interact_default.fbx` | 0.80 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `player_quickturn_default` | `anim/raw/player/player_quickturn_default.fbx` | 0.35 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |

Każdy wiersz `brak` w tabeli gracza oznacza dokładnie: plik z kolumny
`Plik źródłowy`, klip o nazwie z kolumny `Klip`, 30 fps, T-pose, in-place,
keyframe reduction wyłączony, root motion wyłączony, Mixamo FBX 7.4 binary
albo glTF 2.0, humanoid.

Uwagi:

- `player_shoot_pistol` i `player_shoot_shotgun` mają długość zgodną z ROF
  z GDD (BAL-13, BAL-16), ale nie zawierają logiki ognia. Logikę trzyma
  `src/player/player.gd`.
- `player_reload_shotgun` to jeden nabój. Po każdym naboju odtwarzany od
  początku, bo przeładowanie strzelby jest przerywalne (BAL-16).
- `player_quickturn_default` jest wymagany przez BAL-34 (180 stopni w 0.35 s).
- `player_interact_default` dotyczy drzwi, dźwigni i świecy. Podnoszenie
  przedmiotów nie ma animacji zgodnie z BAL-40.
- `player_strafe_l_default` i `player_strafe_r_default` obsługują także
  strafe w Locomotion, nie tylko w trybie celowania.

---

## 3. Wróg

Jedyny typ wroga: Wieszczy. Trzy warianty tej samej istoty:

- **A - Głodny.** Szybki, chaotyczny, asymetryczny. Mocne szarpnięcia,
  nierówny krok, głowa prowadzi przed ciałem.
- **B - Ópi.** Rytmiczny, sztywny, nosi ciężar. Ruchy jak pod metronom,
  barki nieruchome, głowa przechylona. **Wymaga czytelnej pozy zamrożenia** (nie
  rusza się, gdy gracz go widzi) i krótkiego, nagłego przejścia w ruch (BAL-56).
- **C - Stary.** Wolny, ciężki, wlecze nogę. Długi windup, dużo masy,
  twarz i dłonie pamiętają dawne gesty.

**Mapowanie kodu.** `src/enemy/enemy.gd` używa nazw `walker`, `stalker`,
`brute`, a GDD używa A/B/C. Rekomendacja dla programisty: A -> `stalker`,
B -> `walker`, C -> `brute`. To mapowanie ról, nie nazw. Programista musi
potwierdzić je i wyrównać liczby z BAL-20 do BAL-22, bo obecne wartości
w `enemy.gd` nie są identyczne z GDD.

| Klip | Plik źródłowy | Długość | Pętla | Root motion | Status | Właściciel | Wymagania |
|---|---|---:|---|---|---|---|---|
| `enemy_idle_a` | `anim/raw/enemy/enemy_idle_a.fbx` | 3.5 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_patrol_a` | `anim/raw/enemy/enemy_patrol_a.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_notice_a` | `anim/raw/enemy/enemy_notice_a.fbx` | 0.7 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_chase_a` | `anim/raw/enemy/enemy_chase_a.fbx` | 0.8 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_attack_a` | `anim/raw/enemy/enemy_attack_a.fbx` | 1.4 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_stagger_a` | `anim/raw/enemy/enemy_stagger_a.fbx` | 0.6 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_death_a` | `anim/raw/enemy/enemy_death_a.fbx` | 2.0 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_idle_b` | `anim/raw/enemy/enemy_idle_b.fbx` | 4.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_patrol_b` | `anim/raw/enemy/enemy_patrol_b.fbx` | 1.2 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_notice_b` | `anim/raw/enemy/enemy_notice_b.fbx` | 1.0 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_chase_b` | `anim/raw/enemy/enemy_chase_b.fbx` | 1.0 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_attack_b` | `anim/raw/enemy/enemy_attack_b.fbx` | 1.8 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_stagger_b` | `anim/raw/enemy/enemy_stagger_b.fbx` | 0.5 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_death_b` | `anim/raw/enemy/enemy_death_b.fbx` | 2.4 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_idle_c` | `anim/raw/enemy/enemy_idle_c.fbx` | 4.5 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_patrol_c` | `anim/raw/enemy/enemy_patrol_c.fbx` | 1.8 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_notice_c` | `anim/raw/enemy/enemy_notice_c.fbx` | 1.6 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_chase_c` | `anim/raw/enemy/enemy_chase_c.fbx` | 1.6 s | tak | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_attack_c` | `anim/raw/enemy/enemy_attack_c.fbx` | 2.6 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_stagger_c` | `anim/raw/enemy/enemy_stagger_c.fbx` | 0.7 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |
| `enemy_death_c` | `anim/raw/enemy/enemy_death_c.fbx` | 3.0 s | nie | off | brak | Mariusz (dostawa) | H30/FBX |

Każdy wiersz `brak` w tabeli wroga oznacza dokładnie: plik z kolumny
`Plik źródłowy`, klip o nazwie z kolumny `Klip`, 30 fps, T-pose, in-place,
keyframe reduction wyłączony, root motion wyłączony, Mixamo FBX 7.4 binary
albo glTF 2.0, humanoid.

Uwagi:

- `enemy_attack_a/b/c` zawierają windup, uderzenie i recovery. Windup wynosi
  0.35 / 0.5 / 0.8 s zgodnie z BAL-20 do BAL-22. Nie dodajemy osobnego stanu
  `windup`, bo GDD wiąże timing z atakiem.
- `enemy_stagger_a/b/c` mają długość klipu, ale w grze odtwarzamy je z
  `speed_scale = długość_klipu / czas_staggera` z BAL-27. Strzelba daje
  dłuższy stagger niż pistolet, więc ten sam klip ma inną prędkość.
- `enemy_notice_*` to jednorazowy zwrot w stronę gracza. Po nim AnimationTree
  przechodzi automatycznie do `chase`.
- Wariant C w finale to Szymon Kreft. Nie dostaje osobnego zestawu klipów
  ani animacji bossa. Ma te same klipy co pozostałe instancje C.

---

## 4. Broń i otoczenie

| Klip | Plik źródłowy | Długość | Pętla | Root motion | Status | Właściciel | Wymagania |
|---|---|---:|---|---|---|---|---|
| `weapon_sway_default` | `anim/procedural/weapon_sway.gd` | ciągła | tak | n/d | gotowy | animator | PROC |
| `camera_shake_hit_default` | `anim/procedural/camera_shake.gd` | 0.4 s impuls | nie | n/d | gotowy | animator | PROC |
| `door_kick_default` | `anim/procedural/door_kick.gd` | 0.18 s + otwarcie | nie | n/d | gotowy | animator | PROC |
| `door_open_default` | `src/interact/door.gd` (tween) | 0.45 s | nie | n/d | gotowy | programmer | KOD |
| `door_close_default` | `src/interact/door.gd` (tween) | 0.45 s | nie | n/d | gotowy | programmer | KOD |
| `light_flicker_default` | `anim/procedural/light_flicker.gd` | ciągła | tak | n/d | gotowy | animator | PROC |
| `candle_light_default` | `anim/procedural/light_flicker.gd` (preset) | ciągła | tak | n/d | gotowy | animator | PROC |
| `branch_sway_default` | `anim/procedural/branch_sway.gd` | ciągła | tak | n/d | gotowy | animator | PROC |
| `bell_swing_default` | `anim/procedural/bell_swing.gd` | 4.0 s wygaszanie | tak | n/d | gotowy | animator | PROC |

Uwagi:

- `door_open_default` i `door_close_default` są już realizowane przez tween
  w `src/interact/door.gd`. Nie zamawiamy do nich FBX. `door_kick_default`
  skraca `open_time` przez publiczny export i wywołuje `interact()`, bez
  edycji `door.gd`.
- `candle_light_default` to ten sam skrypt co `light_flicker_default`, ale
  z innym `rng_seed` dla każdej świecy. Każda świeca ma unikalny seed, żeby
  migotanie nie było zsynchronizowane.
- `bell_swing_default` korzysta z istniejącego `AudioStreamPlayer3D`, jeśli
  ma przypisany stream. Skrypt nie tworzy i nie pobiera audio.
- `camera_shake_hit_default` obsługuje też odrzut po strzale przez
  `shake_shot()`. Nie zmienia długości spring arma ani offsetu barku.

---

## 5. Zamówienie dla Mariusza

**Stan:** `anim/raw/` jest pusty. Poniżej minimalna lista plików. Każdy plik
ma dokładnie jeden klip i nazwę identyczną z nazwą klipu.

### 5.1 `anim/raw/player/` - 15 plików

```text
player_idle_default.fbx
player_walk_default.fbx
player_run_default.fbx
player_aim_idle_default.fbx
player_aim_walk_default.fbx
player_strafe_l_default.fbx
player_strafe_r_default.fbx
player_shoot_pistol.fbx
player_shoot_shotgun.fbx
player_reload_pistol.fbx
player_reload_shotgun.fbx
player_hit_default.fbx
player_death_default.fbx
player_interact_default.fbx
player_quickturn_default.fbx
```

### 5.2 `anim/raw/enemy/` - 21 plików

```text
enemy_idle_a.fbx
enemy_patrol_a.fbx
enemy_notice_a.fbx
enemy_chase_a.fbx
enemy_attack_a.fbx
enemy_stagger_a.fbx
enemy_death_a.fbx
enemy_idle_b.fbx
enemy_patrol_b.fbx
enemy_notice_b.fbx
enemy_chase_b.fbx
enemy_attack_b.fbx
enemy_stagger_b.fbx
enemy_death_b.fbx
enemy_idle_c.fbx
enemy_patrol_c.fbx
enemy_notice_c.fbx
enemy_chase_c.fbx
enemy_attack_c.fbx
enemy_stagger_c.fbx
enemy_death_c.fbx
```

### 5.3 `anim/raw/props/` - 0 plików obowiązkowych

Wszystkie efekty broni i otoczenia są proceduralne. Nie zamawiam do nich
animacji FBX. Opcjonalnie, tylko jeśli level-designer potrzebuje modeli:
`bell.fbx`, `branch.fbx`, `candle.fbx`, `door.fbx`, bez animacji, glTF 2.0
albo FBX, skala 1 jednostka = 1 m. Te pliki nie blokują walidacji.

### 5.4 Wspólne wymagania dla każdego pliku `brak`

- Format: Mixamo FBX 7.4 binary albo glTF 2.0.
- FPS źródła: 30. Nie dostarczaj 60 fps.
- Poza: T-pose, ręce poziomo, dłonie otwarte, stopy na ziemi.
- In-place: bez translacji roota, bez rotacji roota w klipach lokomocji.
- Keyframe reduction: wyłączony w źródle.
- Root motion: wyłączony, `root_motion_track` w Godocie pusty.
- Szkielet: humanoid, jedna hierarchia, korzeń `Hips`, bez dodatkowych
  constraintów IK, bez kamery i bez świateł w pliku.
- Nazwa klipu w pliku: dokładnie jak nazwa pliku, bez prefiksu
  `mixamo.com|` i bez `Armature|`.
- Skala: FBX z Mixamo zwykle w cm, glTF w metrach. Po imporcie sprawdź
  wzrost 1.70 do 1.90 m.
- Osie: Godot Y-up, postać patrzy w -Z. Jeśli w Blenderze patrzy inaczej,
  obróć root o 180 stopni w Blenderze, nie w kodzie.

### 5.5 Kolejność dostawy

1. P0: `player_idle_default`, `player_walk_default`, `player_run_default`,
   `player_aim_idle_default`, `player_aim_walk_default`,
   `player_strafe_l_default`, `player_strafe_r_default`.
2. P0: `player_shoot_pistol`, `player_reload_pistol`, `player_hit_default`,
   `player_death_default`.
3. P0: wszystkie `enemy_idle_*`, `enemy_patrol_*`, `enemy_chase_*`,
   `enemy_attack_*`, `enemy_stagger_*`, `enemy_death_*`.
4. P1: `player_shoot_shotgun`, `player_reload_shotgun`,
   `player_interact_default`, `player_quickturn_default`.
5. P2: `enemy_notice_*` i modele propsów z 5.3.

Bez punktu 1 nie da się uruchomić AnimationTree gracza. Bez punktu 3 nie da
się uruchomić AnimationTree wroga. Reszta może dojść później.

---

## 6. Plan AnimationTree

Plan jest gotowy do wpięcia przez programistę. Animator nie edytuje
`scenes/player.tscn`, `scenes/enemy.tscn` ani `src/`. Poniżej konkretne
ścieżki węzłów i parametry.

### 6.1 Gracz - struktura sceny

```text
Player (CharacterBody3D)
  AnimationPlayer
  AnimationTree
  CameraPivot
    SpringArm3D
      Camera3D
        CameraShake (Node3D, anim/procedural/camera_shake.gd)
  InteractRay
```

Ustawienia `AnimationTree`:

- `anim_player = NodePath("../AnimationPlayer")`
- `tree_root = PlayerSM` (`AnimationNodeStateMachine`)
- `active = true`
- `process_callback = AnimationTree.ANIMATION_PROCESS_PHYSICS`
- `root_motion_track` puste

### 6.2 Gracz - stany

| Stan | Typ | Zawartość |
|---|---|---|
| `Locomotion` | `AnimationNodeBlendSpace2D` | idle, walk, run, strafe_l, strafe_r, warianty wsteczne |
| `Aim` | `AnimationNodeBlendSpace2D` | aim_idle, aim_walk, strafe_l, strafe_r, aim_walk wstecz |
| `Shoot` | `AnimationNodeBlendSpace1D` (discrete) | `player_shoot_pistol` (0), `player_shoot_shotgun` (1) |
| `Reload` | `AnimationNodeBlendSpace1D` (discrete) | `player_reload_pistol` (0), `player_reload_shotgun` (1) |
| `Hit` | `AnimationNodeAnimation` | `player_hit_default` |
| `Interact` | `AnimationNodeAnimation` | `player_interact_default` |
| `QuickTurn` | `AnimationNodeAnimation` | `player_quickturn_default` |
| `Death` | `AnimationNodeAnimation` | `player_death_default`, stan terminalny |

Punkty `Locomotion` (`AnimationNodeBlendSpace2D`):

| Pozycja | Klip | Uwaga |
|---|---|---|
| `(0, 0)` | `player_idle_default` | brak ruchu |
| `(0, 1)` | `player_walk_default` | przód, chód |
| `(0, 2)` | `player_run_default` | przód, sprint |
| `(0, -1)` | `player_walk_default` | `play_mode = backward` |
| `(0, -2)` | `player_run_default` | `play_mode = backward` |
| `(-1, 0)` | `player_strafe_l_default` | lewy strafe |
| `(1, 0)` | `player_strafe_r_default` | prawy strafe |

Punkty `Aim` (`AnimationNodeBlendSpace2D`):

| Pozycja | Klip | Uwaga |
|---|---|---|
| `(0, 0)` | `player_aim_idle_default` | celowanie w miejscu |
| `(0, 1)` | `player_aim_walk_default` | przód |
| `(0, -1)` | `player_aim_walk_default` | `play_mode = backward` |
| `(-1, 0)` | `player_strafe_l_default` | lewy strafe |
| `(1, 0)` | `player_strafe_r_default` | prawy strafe |

`blend_position` licz z prędkości lokalnej, nie ze świata:

```gdscript
var local_velocity := transform.basis.inverse() * velocity
var blend := Vector2(local_velocity.x / walk_speed, -local_velocity.z / walk_speed)
anim_tree.set("parameters/PlayerSM/Locomotion/blend_position", blend.limit_length(2.0))
```

### 6.3 Gracz - przejścia

| Z | Do | Warunek | Tryb |
|---|---|---|---|
| `Locomotion` | `Aim` | `aiming == true` | natychmiast |
| `Aim` | `Locomotion` | `aiming == false` | natychmiast |
| `Locomotion` / `Aim` | `Shoot` | `shooting == true` | natychmiast, `playback.travel("Shoot")` |
| `Locomotion` / `Aim` | `Reload` | `reloading == true` | natychmiast |
| `Locomotion` / `Aim` | `Hit` | `hit == true` | natychmiast |
| `Locomotion` / `Aim` | `Interact` | `interact == true` | natychmiast |
| `Locomotion` / `Aim` | `QuickTurn` | `quickturn == true` | natychmiast |
| dowolny | `Death` | `dead == true` | natychmiast, bez powrotu |
| `Shoot` | `Aim` albo `Locomotion` | koniec animacji | auto, wybór po `aiming` |
| `Reload` | `Aim` albo `Locomotion` | koniec animacji albo `reload_cancelled` | auto |
| `Hit` | `Aim` albo `Locomotion` | koniec animacji | auto |
| `Interact` | `Aim` albo `Locomotion` | koniec animacji | auto |
| `QuickTurn` | `Aim` albo `Locomotion` | koniec animacji | auto |

Parametry warunków (root StateMachine): `parameters/conditions/aiming`,
`parameters/conditions/shooting`, `parameters/conditions/reloading`,
`parameters/conditions/hit`, `parameters/conditions/interact`,
`parameters/conditions/quickturn`, `parameters/conditions/dead`.
Jeśli StateMachine jest zagnieżdżony, poprzedź ścieżkę nazwą węzła.

Playback:

```gdscript
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_playback: AnimationNodeStateMachinePlayback = \
	anim_tree.get("parameters/PlayerSM/playback") as AnimationNodeStateMachinePlayback
```

Wybór broni w stanie `Shoot` i `Reload` ustawiaj przez
`parameters/PlayerSM/Shoot/blend_position` oraz
`parameters/PlayerSM/Reload/blend_position`: 0 = pistolet, 1 = strzelba,
`blend_mode = BLEND_MODE_DISCRETE`.

### 6.4 Wróg - struktura sceny

```text
Enemy (CharacterBody3D)
  AnimationPlayer
  AnimationTree
```

Ustawienia `AnimationTree`:

- `anim_player = NodePath("../AnimationPlayer")`
- `tree_root = EnemySM` (`AnimationNodeStateMachine`)
- `active = true`
- `process_callback = AnimationTree.ANIMATION_PROCESS_PHYSICS`
- `root_motion_track` puste

### 6.5 Wróg - stany wariancji

Każdy stan to `AnimationNodeBlendSpace1D` z `blend_mode =
BLEND_MODE_DISCRETE` i trzema klipami:

- pozycja 0: wariant A
- pozycja 1: wariant B
- pozycja 2: wariant C

| Stan | Klipy A/B/C | Pętla |
|---|---|---|
| `Idle` | `enemy_idle_a/b/c` | tak |
| `Patrol` | `enemy_patrol_a/b/c` | tak |
| `Notice` | `enemy_notice_a/b/c` | nie, auto do `Chase` |
| `Chase` | `enemy_chase_a/b/c` | tak |
| `Attack` | `enemy_attack_a/b/c` | nie, auto do `Chase` |
| `Stagger` | `enemy_stagger_a/b/c` | nie, auto do `Chase` |
| `Death` | `enemy_death_a/b/c` | nie, terminalny |

`blend_position` dla każdego stanu ustaw z `variant_index`: 0 = A,
1 = B, 2 = C. Ścieżki: `parameters/EnemySM/Idle/blend_position`,
`parameters/EnemySM/Patrol/blend_position`,
`parameters/EnemySM/Notice/blend_position`,
`parameters/EnemySM/Chase/blend_position`,
`parameters/EnemySM/Attack/blend_position`,
`parameters/EnemySM/Stagger/blend_position`,
`parameters/EnemySM/Death/blend_position`.

### 6.6 Wróg - przejścia

| Z | Do | Warunek | Tryb |
|---|---|---|---|
| start | `Patrol` | spawn | natychmiast |
| `Patrol` | `Notice` | pierwsze wykrycie gracza | `playback.travel("Notice")` |
| `Notice` | `Chase` | koniec animacji | auto |
| `Chase` | `Attack` | `distance <= attack_range` | natychmiast |
| `Attack` | `Chase` | koniec animacji | auto |
| dowolny | `Stagger` | `take_damage()` i HP > 0 | natychmiast |
| `Stagger` | `Chase` | koniec animacji | auto |
| dowolny | `Death` | `dead == true` | natychmiast, bez powrotu |

Uwaga: `src/enemy/enemy.gd` nie ma stanu `NOTICE`. Programista dodaje
`playback.travel("Notice")` przy pierwszym przejściu z patrolu w pościg
albo sygnał `noticed`, jeśli woli trzymać logikę w skrypcie. Nie zmieniamy
`enemy.gd` w tej fali.

Stagger:

```gdscript
var clip_length := 0.6 # enemy_stagger_a
var speed_scale := clip_length / current_stagger_time
anim_tree.set("parameters/EnemySM/Stagger/speed_scale", speed_scale)
```

`current_stagger_time` bierz z BAL-27: pistolet 0.15 / 0.10 / 0.05 s,
strzelba 0.6 / 0.4 / 0.25 s dla A / B / C. Klip jest jeden na wariant,
ale odtwarzany z inną prędkością.

---

## 7. Retarget w Godot 4.7

### 7.1 Import

1. Wrzuć pliki do `anim/raw/player/`, `anim/raw/enemy/` albo
   `anim/raw/props/`. Nie zmieniaj nazw klipów.
2. Kliknij plik FBX/GLB, otwórz `Import` i `Advanced Import Settings`.
3. `Root Type`: `Node3D`. Model ma być osobnym węzłem, nie rootem
   `CharacterBody3D`.
4. `Meshes`: sprawdź skalę i wysokość. Dla Mixamo w cm ustaw `Scale` 0.01,
   jeśli postać ma ponad 10 m. Dla glTF zostaw 1.0.
5. `Animation`: włącz import animacji, `FPS` ustaw na 30 dla źródła.
   Nie włączaj redukcji klatek w źródle.
6. `Retarget`: utwórz `BoneMap` z profilem `SkeletonProfileHumanoid`.
   Zmapuj `Hips`, `Spine`, `Head`, `LeftUpperArm`, `RightUpperArm`,
   `LeftLowerArm`, `RightLowerArm`, `LeftUpperLeg`, `RightUpperLeg`,
   `LeftLowerLeg`, `RightLowerLeg`, `LeftFoot`, `RightFoot`.
7. Sprawdź podgląd w oknie importu. Postać ma stać pionowo, twarzą w -Z.
8. Zapisz import. Powtórz dla każdego pliku.

### 7.2 Osie i skala

- Godot: Y-up, przód to -Z.
- Mixamo FBX: zwykle Y-up, ale bywa obrócony. Po imporcie sprawdź, czy
  postać patrzy w -Z. Jeśli nie, popraw w Blenderze i wyeksportuj ponownie.
- glTF 2.0: metry, skala 1.0.
- FBX z Mixamo: centymetry, skala 0.01 tylko po sprawdzeniu wysokości.
- Nie skaluj postaci w `scenes/player.tscn` ani `scenes/enemy.tscn`.
  Skala ma być w imporcie, żeby kolizje i navmesh zostały spójne.

### 7.3 Root motion

- W imporcie nie ustawiaj `root_motion_track`.
- W `AnimationPlayer` pozostaw `root_motion_track` puste.
- Jeśli klip ma track translacji roota, usuń go albo przenieś ruch do
  `src/`. Animator nie zmienia fizyki.
- `CharacterBody3D` jest jedynym właścicielem pozycji. Animacja jest
  wizualna.

### 7.4 Pętle

- Dla `Pętla = tak` ustaw `Loop Mode = Linear` w `Animation` lub w
  zaawansowanym imporcie.
- Pierwsza i ostatnia klatka muszą być identyczne. Odetnij duplikat
  ostatniej klatki, żeby nie było przeskoku.
- Długość pętli ma być wielokrotnością 1/15 s dla wroga i 1/24 s dla
  gracza, jeśli importujesz z obniżonym FPS.
- Dla `Pętla = nie` ustaw `Loop Mode = None` i sprawdź, czy ostatnia
  klatka nie ucina powrotu do pozy.

### 7.5 PS2-feel

- Źródło: 30 fps. Import docelowy: gracz 24 fps, wróg 15 fps. To świadome
  ograniczenie, nie utrata danych źródłowych.
- Mniej klatek, mocniejsze pozy: 2 do 4 kluczowych póz na akcję, wyraźna
  sylwetka, brak mikro-ruchu palców i twarzy.
- Interpolacja liniowa. Nie używaj cubic ani ease na każdej kości.
- Brak additive layerów, IK, motion matchingu i proceduralnego retargetu
  w runtime.
- Broń i dłonie mogą mieć osobne kości, ale animacja broni jest proceduralna
  (`weapon_sway_default`), nie klipowa.
- Nie dodawaj motion blur, DOF ani HDR. To warstwa renderu, nie animacji.

### 7.6 Weryfikacja po imporcie

- [ ] Wysokość postaci 1.70 do 1.90 m.
- [ ] Postać patrzy w -Z.
- [ ] `root_motion_track` puste.
- [ ] Nazwy klipów bez prefiksów `mixamo.com|` i `Armature|`.
- [ ] Pętle bez przeskoku w pierwszej i ostatniej klatce.
- [ ] `enemy_attack_*` ma windup 0.35 / 0.5 / 0.8 s.
- [ ] `player_quickturn_default` trwa 0.35 s.
- [ ] Klipy nie zawierają kamery, świateł ani constraintów.
- [ ] Animacja działa na prymitywie z `scenes/player.tscn` i
  `scenes/enemy.tscn` bez zmiany kolizji.

---

## 8. Ryzyka i zależności

| Ryzyko | Wpływ | Mitygacja | Właściciel |
|---|---|---|---|
| `anim/raw/` pusty | brak importu i AnimationTree | lista zamówienia w sekcji 5, proceduralne obejście na prymitywach | Mariusz |
| `enemy.gd` ma nazwy `walker/stalker/brute` i liczby inne niż GDD | złe warianty animacji | mapowanie A/B/C w sekcji 3 i review programisty | programmer |
| `player.gd` nie ustawia parametrów AnimationTree | animacje nie reagują na stan | sekcja 6, programista dodaje parametry i sygnały | programmer |
| Brak audio dla dzwonu | `bell_swing` milczy | skrypt gra tylko wtedy, gdy `AudioStreamPlayer3D` ma stream | artist / programmer |
| Brak modeli i szkieletu w scenach | animacje nie mają na czym grać | proceduralne skrypty działają na prymitywach | programmer |
| `door.gd` zmieni `open_time` na stałą | `door_kick` straci skrócenie | używać publicznego exportu, nie pisać do pola prywatnego | programmer |

---

## 9. Walidacja headless

```bash
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village --script res://anim/validate.gd
flatpak run org.godotengine.Godot --headless --path /var/home/harp9x/github/trauma-village --quit-after 10 res://anim/procedural_test.tscn
```

Oczekiwany wynik pierwszej komendy: `PASS` dla `weapon_sway`,
`camera_shake`, `light_flicker`, `branch_sway`, `door_kick`, `bell_swing`
oraz `PASS all 6 procedural scripts`. Kod wyjścia 0.

Druga komenda ma zakończyć się bez błędów. Scena `anim/procedural_test.tscn`
zawiera prymityw, światło, kamerę, drzwi i każdy skrypt proceduralny.

---

## 10. Historia zmian

| Wersja | Data | Zmiana | Autor |
|---|---|---|---|
| 0.1 | 2026-10-29 | Pierwsza lista klipów, zamówienie, plan AnimationTree, retarget, skrypty proceduralne | animator |

---

## 11. Animacje proceduralne bez szkieletu (Fala 5)

Te skrypty nie wymagają FBX ani riga. Działają na prymitywach i kapsułach.

| Skrypt | Node docelowy | Co robi | Kto podpina |
|---|---|---|---|
| `anim/procedural/view_bob.gd` | `Player/CameraPivot/SpringArm3D` | bob kamery od ruchu, oddech, wygaszenie przy celowaniu, wzmocnienie przy sprincie | programmer |
| `anim/procedural/body_motion.gd` | `Enemy/Body` | kołysanie patrolu, lurch pościgu, zamach ataku, drgawki stagger, przewrócenie po śmierci | programmer |
| `anim/procedural/weapon_sway.gd` | pivot broni lub kamera | kołysanie broni od myszy i ruchu | programmer |
| `anim/procedural/camera_shake.gd` | `Camera3D` | impulsy trafienia i strzału | już wpięte |
| `anim/procedural/light_flicker.gd` | `OmniLight3D` | migotanie świec i latarni | już wpięte |
| `anim/procedural/branch_sway.gd` | korony drzew | wiatr na koronach | już wpięte |
| `anim/procedural/door_kick.gd` | drzwi | szybkie otwarcie z impulsem kamery | wpięte, brak inputu |
| `anim/procedural/bell_swing.gd` | `I4_BellPivot` | wahanie dzwonu | wpięte |

Walidacja: `python3` nie dotyczy; uruchamiaj
`flatpak run org.godotengine.Godot --headless --path . --script res://anim/validate.gd`.
Aktualny wynik: 8 skryptów, 44 asercje, PASS.

---

## 12. Postać gracza — realistyczny GLB

Mariusz dostarczył gotowy model `cool_man.glb` (Sketchfab, CC-BY-4.0,
autor: ardhanaputra). To 169-kostny rig z klipami `Pose`, `walking`, `sit`,
`salute`, `cough` i `shakehand`; używamy `Pose` jako idle i `walking` jako chód.

| Element | Plik | Uwagi |
|---|---|---|
| model | `art/models/characters/cool_man.glb` | okulary, płaszcz, ciemne spodnie, buty; ~1.80 m |
| scena | `anim/characters/real_character.tscn` | `Node3D` + skrypt, instancjonuje GLB |
| skrypt | `anim/characters/real_character.gd` | cross-fade `Pose`/`walking`, speed scale, hide w FPP, przewrócenie po śmierci |
| integracja | `scenes/player.tscn` | `BodyVisual` pod `Player`; kapsuła `Body` ukryta, kolizja bez zmian |

Model jest obrócony o 180° (oryginalnie patrzy +Z). W intro `set_forced_walk(true)`
odtwarza chód, gdy pozycja gracza jest tweenowana do znaku. Stara wersja
proceduralna (`player_character.gd`) zostaje jako fallback. Walidacja:
`flatpak run org.godotengine.Godot --headless --path . --script res://tests/character_test.gd`.
