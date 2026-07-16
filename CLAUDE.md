# CLAUDE.md

## Project

PSX-style retro low-poly walking narrative game. Godot 4.6, Forward+ renderer, Jolt Physics.
Gameplay: first-person exploration + NPC dialogue. No jumping, no combat.

Narrative/content spec lives in the GDD (currently v0.7, held outside the repo) — 5 locations
(Convenience Store, Crossroads, Under the Overpass, Arcade Alley, School Rooftop), 21 animal NPCs,
a Duck "inner voice" companion, and a hidden fragment thread across 5 NPCs. Only the first 3
locations and 8 NPCs are built so far — see `## NPC System` and `## Directory Structure` below for
what's actually implemented vs pending.

## Engine & Settings

- Godot 4.6, Direct3D 12 (Windows)
- Render resolution: 320×240, window: 1980×1080, Stretch Mode: viewport
- Shader Global required: `precision_multiplier` (Float, 0.5) — controls vertex snapping intensity

## Directory Structure

```
demo/
├── autoload/
│   ├── DuckState.gd                  # cross-scene singleton: tracks which maps played Duck dialogue
│   └── SceneManager.gd               # CanvasLayer (layer=20): fade transition + location name display
├── Scenes/
│   ├── scene_trigger.gd              # reusable map transition trigger (Area3D)
│   ├── Player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── cigarette.gd
│   ├── Maps/
│   │   ├── Map_01_ConvenienceStore.tscn
│   │   ├── Map_02_Crossroads.tscn
│   │   ├── Map_03_UnderTheOverPass.tscn
│   │   ├── Map_04_ArcadeAlley.tscn   # PLANNED — not created yet (GDD v0.7 §4)
│   │   └── Map_05_SchoolRooftop.tscn # PLANNED — not created yet; drop in Scenes/Television/television.tscn +
│   │                                 # an Ending/ending_sequence.gd node (wire its `television` export to it)
│   ├── Duck/
│   │   ├── duck.gd                   # Duck Node3D: PSX shader, warm light, one-shot dialogue, queue_free after lines
│   │   ├── duck_dialogue_ui.gd       # CanvasLayer (layer=4): typewriter + blip audio (400 Hz, fixed pitch)
│   │   └── duck_trigger.gd           # Area3D: fires duck.trigger() once on player entry
│   ├── Television/
│   │   ├── television.gd             # StaticBody3D, extends npc_base.gd: ending trigger, standard NPC dialogue/outline
│   │   └── television.tscn           # prefab: GLB body + CollisionShape3D (npc_base.gd interaction)
│   ├── Ending/
│   │   ├── ending_sequence.gd        # Node: listens for Television's `ending_triggered`, plays ending_title_ui
│   │   └── ending_title_ui.gd        # CanvasLayer (layer=25): immediate cut to black + "YAKO" title fade-in
│   ├── Collectibles/
│   │   ├── yellow_duck_collectible.gd/.tscn  # Area3D pickup, reports to YellowDuckState by duck_id
│   │   └── backroom_teleporter.gd    # Area3D: instant same-scene teleport to a NodePath target
│   ├── NPC/
│   │   ├── npc_base.gd               # base class for all NPCs (extends StaticBody3D)
│   │   ├── NPC_Cat.tscn               # Map 01
│   │   ├── NPC_Sheep.tscn             # Map 01, fragment carrier [F]
│   │   ├── NPC_Goat.tscn              # Map 02
│   │   ├── NPC_Otter.tscn             # Map 03, fragment carrier [F]
│   │   ├── NPC_Dog.tscn               # Map 03
│   │   ├── NPC_Raccoon.tscn           # built, but Map 04 scene doesn't exist yet
│   │   ├── NPC_Fish.tscn              # built, but Map 04 scene doesn't exist yet
│   │   └── NPC_Capybara.tscn          # legacy — not in GDD v0.7's 21-NPC roster, currently unused
│   │   # 14 more NPCs pending per GDD v0.7 roster: Prairie Dog, Rat (Map 01);
│   │   # French Bulldog, Koi Fish, Baboon, Goose[F], Great White Shark (Map 02);
│   │   # Giraffe, Deer, Panda (Map 03); Toucan, Octopus[F], T-Rex, Koala[F] (Map 04)
│   ├── UI/
│   │   └── dialogue_ui.gd            # CanvasLayer (layer=5): typewriter subtitle + blip audio, code-only
│   ├── Fonts/
│   │   └── pixel.ttf                 # pixel bitmap font used for all in-game text
│   └── Assets/
│       ├── Cigarette/
│       │   ├── Cig.glb               # cigarette mesh (4 burn stages: Cig, CigBurn0-2)
│       │   └── cigs_carton.glb       # cigarette carton with CartonTopOpen animation
│       ├── Television/
│       │   └── psx_low-poly_televisions.glb  # 4 colour variants (Black/Box/Grey/Yellow) stacked at
│       │                                      # the same origin; television.gd spreads all 4 into a wall
│       ├── UI/
│       │   └── YellowDuck.jpg        # studio logo (credits screen) — actually JPEG despite the name
│       ├── LampPost/
│       │   └── LampPost.tscn         # prefab: Node3D + MeshInstance3D + OmniLight3D
│       ├── SevenEleven/              # convenience store model + textures (Map 01)
│       ├── UrbanPack/                # street props (Map 02); Textures/, Textures Pack2/, Textures Pack3/
│       ├── Zee/                      # third-party low-poly city pack (Map 02): Buildings/, Car, Road, etc.
│       ├── MiscAssets/                # grab-bag of individually sourced props (Map 01), by category:
│       │   └── animal/ car/ environment/ furniture/ small assets/
│       └── SkyscraperPack/
│           ├── models/               # source FBX + textures/
│           └── glb/                  # converted GLB with emission baked in — currently unreferenced by any map
├── shaders/
│   ├── psx_base.gdshaderinc          # shared: vertex snap + #ifdef NPC_WOBBLE
│   ├── psx_lit.gdshader              # standard lit mesh
│   ├── psx_unlit.gdshader            # unlit/self-lit mesh
│   ├── psx_lit_npc.gdshader          # NPC: psx_lit + NPC_WOBBLE per-vertex jitter
│   ├── npc_outline.gdshader          # white outline (cull_front, applied as next_pass)
│   ├── sky_stars.gdshader            # shader_type sky — procedural pixel stars
│   ├── psx_lit_metal.gdshader
│   ├── psx_lit_transparent.gdshader
│   ├── psx_lit_alpha-scissor.gdshader
│   ├── psx_unlit_*.gdshader          # unlit variants
│   ├── pp_band-dither.gdshader       # fullscreen dither post-process (uses hint_screen_texture)
│   ├── post_process_blur.gdshader
│   ├── lcd_post_process.gdshader
│   └── psxdither.png
├── tools/
│   └── fbx_to_glb_with_texture.py   # Blender batch FBX→GLB converter with emission
└── project.godot
```

## Main Scene Structure

```
Main (Node)
├── CanvasLayer (Layer=10)
│   └── ColorRect                     # fullscreen dither post-process
├── WorldEnvironment                  # night atmosphere + sky_stars.gdshader
├── DirectionalLight3D                # moonlight: cool blue, energy 0.12
├── Floor
├── Player
└── Assets (Node3D, scale=0.45, 90° rotated)
    └── Props (GLB instance)
        ├── LampPost_001 (MeshInstance3D)
        │   └── LampLight (OmniLight3D)   # sodium orange, energy 3.5, range 10
        ├── LampPost_002 … LampPost_004
        └── … (FireHydrant, Mailbox, etc.)
```

## Night Atmosphere (WorldEnvironment)

- Sky: uses `sky_stars.gdshader` (shader_type sky) — gradient matches original ProceduralSky colours + procedural pixel stars
- Ambient: Color source, cool blue `(0.08, 0.1, 0.2)`, energy `0.18`
- Moonlight (DirectionalLight3D): `Color(0.7, 0.78, 1.0)`, energy `0.12`, shadows on
- Fog: enabled, blue-grey `(0.07, 0.08, 0.14)`, density `0.014`
- Glow: intensity `1.4`, bloom `0.25`, HDR threshold `0.75` (low threshold so lamp orange triggers bloom)
- LampPost lights: `OmniLight3D` child at local `Y=0.085` — sodium orange `(1.0, 0.62, 0.18)`, energy `3.5`, range `10`, no shadow

**LampPost prefab:** `Scenes/Assets/LampPost/LampPost.tscn` — Node3D root with Mesh + LampLight (OmniLight3D). Instancing this prefab in any map auto-includes the light with correct parameters.

## Player Scene Structure

```
Player (CharacterBody3D)
├── Head (Node3D, Y=0.72)             # pitch rotation only
│   └── Camera3D
│       └── ItemAnchor (Node3D)
│           ├── CigCartonAnchor (Node3D)   # carton transform/scale
│           │   └── cigs_carton (GLB instance)
│           └── CigAnchor (Node3D)         # cigarette.gd attached here
│               ├── Cig2 (GLB instance)    # mesh stages: Cig, CigBurn0, CigBurn1, CigBurn2
│               └── SmokeParticle (GPUParticles3D)
├── MeshInstance3D
└── CollisionShape3D
```

## Input Map

| Action | Key | Note |
|--------|-----|------|
| `Fowared` | W | Typo — do not rename, code references this exact string |
| `Back` | S | |
| `Left` | A | |
| `Right` | D | |
| `Smoke` | F | Toggle cigarette carton / put away (disabled during NPC dialogue) |
| LMB press | Left Mouse | NPC: open dialogue / advance line; Cigarette: open carton / take cig |
| LMB hold | Left Mouse | Smoke while in SMOKING state |

## Player Controller (player.gd)

- Mouse captured in `_ready()`, released on Esc
- Mouse X → rotate CharacterBody3D (yaw), Mouse Y → rotate Head (pitch, clamped ±90°)
- Movement uses `transform.basis` so direction follows player facing
- No gravity, no jumping — `velocity.y` is unused
- Speed halved (`SPEED * 0.5`) while `cigarette.is_smoking` is true
- `DialogueUI` CanvasLayer instantiated in `_ready()` from `Scenes/UI/dialogue_ui.gd`
- Head bob: `BOB_SPEED=1.3`, `BOB_AMP_Y=0.008`, `BOB_AMP_X=0.004`; accumulates only while velocity > 0
- Footstep audio via `AudioStreamGenerator`: `STEP_INTERVAL=0.42s` (normal), `0.60s` (slow/smoking); 25% sine tone (55–95 Hz, pitch scales with speed) + 75% white noise, −18 dB

### NPC Interaction (player.gd)

- `_process()`: PhysicsRayQueryParameters3D from camera centre, 2 m length
- Outline shown when ray hits NPC (group `"npc"`) within `NPC_INTERACT_RANGE = 1.5` m
- LMB priority: `_current_npc` advance → `_aimed_npc` start → cigarette logic
- Starting NPC dialogue force-closes cigarette (`_enter_hidden()`) and disables F key
- Signals: `npc.line_shown` → `dialogue_ui.show_line()`; `npc.ended` → `dialogue_ui.hide_ui()`

### Cigarette State Machine

States: `HIDDEN → CARTON_CLOSED → CARTON_OPENING → CARTON_OPEN → SMOKING → CARTON_CLOSED → …`

| Trigger | From | To |
|---------|------|----|
| F | HIDDEN | CARTON_CLOSED |
| F | any other | HIDDEN |
| Left click | CARTON_CLOSED | CARTON_OPENING (plays `CartonTopOpen` anim) |
| Anim finished | CARTON_OPENING | CARTON_OPEN |
| Left click | CARTON_OPEN | SMOKING |
| Hold left mouse | SMOKING | cigarette burns (`is_smoking = true`) |
| Release left mouse | SMOKING | cigarette pauses |
| Cigarette burned out | SMOKING | CARTON_CLOSED (auto-reload) |

- Transitions use Tween (0.25 s, CubicEaseOut appear / CubicEaseIn disappear)
- Carton and cigarette each have their own Tween so they can animate simultaneously

## Cigarette System (cigarette.gd)

Script lives on `CigAnchor`. GLB root is `Cig2` with four child Node3D stages: `Cig`, `CigBurn0`, `CigBurn1`, `CigBurn2`. Only one stage is visible at a time.

- `start_smoking()` / `stop_smoking()` — controlled by player.gd (hold left mouse)
- `reset_cigarette()` — called by player.gd before each new cigarette; resets timer and stage
- `signal burned_out` — emitted when `smoke_elapsed >= BURN2_TIME` (15 s total)
- Burn stages: 0–5 s = Cig, 5–10 s = CigBurn0, 10–15 s = CigBurn1, 15 s+ = burned out
- Smoke and ember particles: `GPUParticles3D`, `local_coords = true`
- Particle sizes/velocities are compensated for CigAnchor's ~0.15 world scale (`inv = 1 / gs`)
- Direction and gravity are rotated to local space via `basis.inverse()` so they act as world-up
- Emitter position (`_sync_tip`) is computed once per stage change — not every frame — to avoid jitter

## NPC System (npc_base.gd)

`Scenes/NPC/npc_base.gd` — extends `StaticBody3D`. All NPC scenes use this as their root script.

**Scene structure required:**
```
NPC_Xxx (StaticBody3D, npc_base.gd, group "npc" added automatically)
├── CollisionShape3D    # required for raycast detection
└── [Animal GLB]        # any MeshInstance3D hierarchy
```

**Exported properties:**
- `dialogue_lines: Array[String]` — first interaction lines
- `repeat_lines: Array[String]` — shown on all subsequent interactions
- `wobble_amount: float = 0.005` — PSX per-vertex jitter intensity
- `light_energy: float = 1.2` — OmniLight3D brightness
- `light_color: Color` — Convenience Yellow `(0.91, 0.77, 0.28)` by default
- `voice_pitch: float = 1.0` — base pitch for procedural blip audio (passed to `dialogue_ui.show_line()`)

**What `_ready()` does automatically:**
1. Adds node to group `"npc"`
2. Applies `psx_lit_npc.gdshader` to all MeshInstance3D children (transfers `albedo_texture` from original BaseMaterial3D)
3. Attaches `OmniLight3D` (range 3, no shadow) at Y=1.0 above root

**Dialogue state machine:**
- `start()` → emits `line_shown(text)` with first line; sets `_active = true`
- `advance()` → emits `line_shown` for next line, or emits `ended` and sets `_complete = true`
- After `_complete`, subsequent `start()` calls use `repeat_lines`
- `is_active() → bool`

**Outline system:**
- `set_outline(true/false)` — recursively finds MeshInstance3D children, applies/removes `npc_outline.gdshader` as `next_pass` on surface override materials
- Called by player.gd when NPC enters/leaves aim

**Roster status (GDD v0.7, 21 NPCs across 5 maps):**

| Map | Built | Pending |
|-----|-------|---------|
| 01 Convenience Store | Cat, Sheep [F] | Prairie Dog, Rat |
| 02 Crossroads | Goat | French Bulldog, Koi Fish, Baboon, Goose [F], Great White Shark |
| 03 Under the Overpass | Otter [F], Dog | Giraffe, Deer, Panda |
| 04 Arcade Alley | Raccoon, Fish (no map scene yet) | Toucan, Octopus [F], T-Rex, Koala [F] |
| 05 School Rooftop | Television (`Scenes/Television/television.tscn`, ending trigger built as an NPC-style interactable) | — |

`[F]` = fragment carrier — part of the hidden narrative thread (GDD v0.7 §5.5). `dialogue_lines`/`repeat_lines` content for built NPCs should be pulled from the GDD, not invented here.

## NPC Shader Pipeline

`shaders/psx_lit_npc.gdshader` — defines `NPC_WOBBLE`, includes `psx_base.gdshaderinc`.

`psx_base.gdshaderinc` wobble code (activated by `#define NPC_WOBBLE`):
- Runs **before** `get_snapped_pos()` so snap quantizes the wobbled vertex position
- Per-vertex: uses `VERTEX` position components as hash seeds → each vertex moves independently
- X/Z: 8 Hz; Y: 4 Hz at 25% amplitude

## Sky Star Shader (sky_stars.gdshader)

`shader_type sky` — assign as ShaderMaterial on WorldEnvironment → Sky → Sky Material.

Key uniforms: `star_density` (0.968), `star_brightness` (0.65), `star_size` (0.12), `twinkle_speed` (0.9).

Grid-based star placement: spherical UV divided into ~110×110 cells; `hash()` per cell determines star presence and position. `step(dist, star_size)` makes each star exactly 1–2 pixels at 320×240.

## Autoload Singletons

Registered in `project.godot` under `[autoload]`.

**`autoload/DuckState.gd`** — tracks which maps have played the Duck encounter (persists across scene loads).
- `has_played(map_id: String) → bool`
- `mark_played(map_id: String) → void`

**`autoload/YellowDuckState.gd`** — tracks which hidden Yellow Duck collectibles have been found (persists across scene loads). `TOTAL_DUCKS = 5` (1 hidden per map on Map_01–04, plus 1 more in the Map_03 Backrooms egg — see `## Collectibles` below).
- `collect(duck_id: String) → void`
- `has_collected(duck_id: String) → bool`
- `collected_count() → int`
- `has_collected_all() → bool`

**`autoload/SceneManager.gd`** — CanvasLayer (layer=20, PROCESS_MODE_ALWAYS). Handles all scene transitions with a fade + location name display. Route all scene changes through `SceneManager.change_scene(path)` — never call `change_scene_to_file` directly.
- Overlay: black ColorRect fades in (0.35 s) before switching; fades out (0.45 s) after
- Location name: appears on black during fade-in, stays until 1.8 s after fade-out, then fades (0.6 s)
- `_resolve(path)` — converts `uid://xxxx` paths (stored by Godot 4.4+) to file paths via `ResourceUID`
- `_parse_name(path)` — strips `Map_XX_` prefix, splits CamelCase by character iteration (not RegEx — RegEx in static func returns empty results)
- Font: `res://Scenes/Fonts/pixel.ttf`, size 6, white with 1px black outline via `add_theme_*_override`

## Scene Transition System

`Scenes/scene_trigger.gd` — attach to any `Area3D` node to create a map exit trigger.

```gdscript
@export_file("*.tscn") var target_scene: String = ""
```

- Detects `CharacterBody3D` entering the area via `body_entered`
- Calls `SceneManager.change_scene(target_scene)` — do NOT use `call_deferred(change_scene_to_file, …)` directly
- Set **Target Scene** in Inspector to the destination `.tscn` path
- CollisionShape3D: use a thin BoxShape3D (`Vector3(5, 3, 0.5)`) spanning the exit edge
- Collision Layer = 0 (none), Mask = Layer 1 (Player)

## Collectibles

Hidden Yellow Duck pickups (1 per map, Map_01–04) plus a Map_03 "Backrooms" easter egg
(walk through a hidden gap in a wall → teleported to a hidden pocket space → 1 more duck
there — 5 total). **This is currently just the reserved interface/plumbing** — no ducks,
walls, or backroom space have actually been placed in any map yet; that's level-design work.
Building blocks ready to drop in once placement happens:

**`Scenes/Collectibles/yellow_duck_collectible.tscn`** (`Area3D`,
`yellow_duck_collectible.gd`) — `@export var duck_id: String`, must be a unique string per
placed instance. No ID scheme is enforced in code, but use exactly these 5 (matches
`TOTAL_DUCKS=5` and what the design below assumes):

| `duck_id` | Suggested hiding spot (thematic, not literal coordinates — Zee's call) |
|---|---|
| `Map_01_ConvenienceStore` | Tucked among shelf clutter, near the magazine hidden-detail spot (§4.2) |
| `Map_02_Crossroads` | On/behind the vending machine with the faded sold-out row |
| `Map_03_UnderTheOverPass` | Near the abandoned school bag, in pillar shadow |
| `Map_03_Backroom` | Alone in the empty liminal space — the reward for finding the egg itself |
| `Map_04_ArcadeAlley` | On top of/inside a cabinet, claw-machine-reject vibe |

Tying each duck to an existing GDD hidden-detail beat keeps them feeling like part of the
world instead of arbitrary meta-collectibles — not mandatory, just a suggestion for Zee's
placement pass. On `body_entered` by a
`CharacterBody3D`: calls `YellowDuckState.collect(duck_id)`, emits `signal collected`, then
`queue_free()`s itself. Re-entering an already-collected `duck_id` on scene reload
self-frees immediately in `_ready()` instead of re-triggering. Visual is a billboarded
`Sprite3D` using `Scenes/Assets/UI/YellowDuck.jpg` (`pixel_size=0.0009` → ~0.35m across,
`shaded=false`, nearest-filter) plus a small Duck Yellow (`#F5C842`) `OmniLight3D` glow — a
placeholder look, not a real 3D duck model.

**`Scenes/Collectibles/backroom_teleporter.gd`** (`Area3D`) — generic same-scene teleporter,
not tied to the Backrooms egg specifically. `@export var target_path: NodePath`; on
`body_entered` by a `CharacterBody3D`, sets `body.global_position` to the target node's
`global_position`. No fade/transition — instant, since GDD-style liminal-space eggs read
better as an unexplained snap-cut than a smoothed teleport. Attach to an `Area3D` placed
inside/behind a wall's visible collision (i.e. a gap the player has to notice and walk into)
in Map_03; `target_path` points at wherever the hidden backroom space ends up.

**Television secret ending hook**: `Scenes/Television/television.gd` checks
`YellowDuckState.has_collected_all()` in `_ready()` and, if true, swaps its
`dialogue_lines`/`repeat_lines` for `secret_dialogue_lines`/`secret_repeat_lines` (exports on
Television, editable in the Inspector like the normal lines, defaulting to real drafted text
in the script) before `super._ready()` runs. Current draft: `"are you here" → "you found all
of me." → "every little piece." → "we are always broadcasting."` — frames the 5 collectible
ducks as scattered fragments of the Duck companion, so finding them all pays off narratively
(not just a meta-achievement) without breaking the game's minimalist dialogue tone. Adjust
wording directly on the Television node in the Inspector, no code changes needed.

## Duck Companion System

`Scenes/Duck/` — one-shot NPC encounter that plays per-map dialogue then `queue_free()`s itself.

**`duck.gd`** (Node3D):
- `@export var map_id: String` — unique key passed to `DuckState` to guard replay
- `@export var ending_trigger_path: NodePath` — on Map 05 only, resolved via `get_node_or_null()` in `_ready()` and connected to its `ending_triggered` signal (`CONNECT_ONE_SHOT`) to play Duck's final line once the rooftop Television fires. **Uses `NodePath` + manual `get_node()`, not a typed `@export var x: Node3D`** — the latter looked like it should auto-resolve a hand-written `x = NodePath("...")` line in a `.tscn` into a live node reference, but empirically it silently stayed null at runtime (caught via `ending_sequence.gd` hitting the exact same bug — see below). Don't revert to the typed-Node export style without re-verifying this.
- `_ready()`: applies `psx_lit.gdshader` (no wobble) to all MeshInstance3D children; spawns `OmniLight3D` — warm `Color(1.0, 0.88, 0.55)`, energy 2.8, range 2.5, Y=0.3
- `trigger()` — called by `duck_trigger.gd`; guards via `DuckState.has_played(map_id)`; plays `duck_dialogue_ui.play_lines()`; calls `queue_free()` when done
- Duck does **not** follow the player; it disappears after dialogue on every map

**`duck_dialogue_ui.gd`** (CanvasLayer, layer=4):
- Typewriter at `CHAR_INTERVAL=0.045 s`, hold `1.8 s`, fade `0.5 s`, gap between lines `0.25 s`
- Blip audio: `BLIP_FREQ=400 Hz`, fixed pitch (no variation — distinguishes Duck from NPC's 520 Hz with per-character jitter)
- Font: `res://Scenes/Fonts/pixel.ttf`, size 6, white + 1px outline via `LabelSettings`

## Television / Ending System

`Scenes/Television/` — the Map 05 (School Rooftop) ending trigger, per GDD v0.7 §5.4/§7.
Deliberately built as an NPC (see below) rather than a bespoke interactable — GDD calls for no
outline / a more atmospheric auto-triggered sequence, but that was cut for reliability under
time pressure; revisit post-"pre" if there's time. Built and testable standalone before Map_05
exists — see `Scenes/Television/television_test.tscn` (throwaway verification scene: Player +
floor + Map_03-style night `Environment` + a wired `Television` + `EndingSequence`; safe to
delete once the real Map_05 exists).

**`television.gd`** (`StaticBody3D`) — `extends "res://Scenes/NPC/npc_base.gd"`. Television is
just an NPC with a different mesh: it reuses the full outline/raycast/subtitle-UI interaction
pipeline (`player.gd`'s NPC handling, `dialogue_ui.gd`) as-is, rather than the earlier custom
"render text onto the 3D screen via SubViewport" approach — that approach went through several
rounds of 3D geometry/UV debugging (wrong `QuadMesh` default orientation, then a font-wrapping
red herring) without ever reliably working, so it was scrapped in favor of reusing proven code.
- `signal ending_triggered` — re-emitted whenever the base class's `ended` fires (i.e. once the
  player has clicked through all of `dialogue_lines`)
- `dialogue_lines` = `["are you here", "present day.", "present time.", "we are always broadcasting."]`
  — each requires a click to reveal (standard NPC advance), so the last click (dismissing "we are
  always broadcasting.") is what fires `ended` → `ending_triggered`. **Order deliberately differs
  from GDD v0.7 §5.4**, which has "present time." before "present day." — swapped per direct
  request; don't "fix" this back to match the GDD without checking first.
- `_spread_variants()`: the source GLB (`psx_low-poly_televisions.glb`) ships 4 colour variants
  (`TVBlack`/`TVBox`/`TVGrey`/`TVYellow`) stacked at the same origin — this offsets each variant's
  body+screen wrapper nodes (matched by name prefix) by a fixed `VARIANT_OFFSETS` grid position
  into a 2×2 wall (Serial Experiments Lain nod), run *before* `super._ready()` applies the
  standard NPC shader/outline/light setup to whatever's left in the tree.
- `wobble_amount = 0.0` (export override in the .tscn) — the base class's per-vertex jitter is
  tuned for organic NPCs and looks wrong on a rigid TV cabinet.
- Single shared `CollisionShape3D` (one `BoxShape3D`, deliberately oversized — `Vector3(2.5, 3.5,
  4.0)`) covers the whole 4-TV spread rather than one box per variant, since `npc_base.gd`/
  `player.gd`'s raycast+outline system expects one interactable per NPC node, not four. Sized
  generously on purpose: an undersized/misaligned hitbox (from an earlier pass, sized for a single
  un-spread TV) was the actual cause of a "clicking does nothing" report — oversizing trades a
  slightly-too-generous interact range for not missing the raycast again.
- `_apply_screen_static()` (runs *after* `super._ready()`, overriding what it just set): any
  mesh with `"Screen"` in its name gets `shaders/tv_screen_static.gdshader` instead of the
  standard NPC material — a `shader_type spatial` unlit hash-noise flicker (same technique as
  `sky_stars.gdshader`'s `hash()`), always playing. Being purely procedural per-fragment, this
  is immune to the whole class of UV/geometry bugs the old text-on-screen approach hit — noise
  doesn't care about orientation, so it was safe to keep even after that system was scrapped.
- `_add_screen_lights()` adds one small cyan `OmniLight3D` (`GLOW_COLOR`) per variant at its
  approximate screen centre (`SCREEN_CENTER`), parented under that variant's wrapper so it
  follows the grid spread automatically — in addition to the single generic light `npc_base.gd`
  already adds.
- Text now goes through the same `dialogue_ui.gd` subtitle path every other NPC uses — no
  per-screen text, no outline distinction from a normal NPC. This is a known, deliberate
  simplification vs GDD v0.7 §5.4 (see note above); the cigarette/TV input-overlap gap noted in
  an earlier pass is moot now too, since NPC dialogue already force-closes the cigarette.

**`Scenes/Ending/ending_sequence.gd`** (Node) — `@export var television_path: NodePath`,
resolved to `var television: Node3D` via `get_node_or_null()` in `_ready()` (see the
`NodePath`-vs-typed-`Node3D`-export note above — this bit us here first). On
`television.ending_triggered`: releases the mouse (`Input.mouse_mode = MOUSE_MODE_VISIBLE`),
sets `get_tree().paused = true` (stops `player.gd` — it has no `PROCESS_MODE_ALWAYS` override,
so pausing the tree freezes its `_process`/`_physics_process`/`_input` outright — this is what
actually stops the player after the ending, not anything in `player.gd` itself), then
instantiates `ending_title_ui.gd` (code-only `CanvasLayer`, same `.new()`-and-`add_child()`
pattern as `dialogue_ui.gd`/`duck_dialogue_ui.gd`) under `get_tree().root`. Thin orchestrator by
design so `television.gd` stays a generic reusable interactable — **sunrise sky tween and phone
glow are still deferred** and will hang off this same script later.

**`ending_title_ui.gd`** (CanvasLayer, layer=25, `PROCESS_MODE_ALWAYS` — required so its tweens
still run once `ending_sequence.gd` pauses the tree) — immediate black `ColorRect` (no fade, per
GDD: "CUT: Black. Immediate.") then fades in a centred "YAKO" title (pixel font, size 16, white
+ 1px black outline), holds `TITLE_HOLD=2s`, fades out, then fades in a studio logo
(`TextureRect`, `Scenes/Assets/UI/YellowDuck.jpg`, `TEXTURE_FILTER_NEAREST` to stay crisp at
this resolution, `LOGO_SIZE=64`), a `STUDIO_NAME` label ("YellowDuck Studio", size 8) below it,
and a `CREDITS_TEXT` label (team names/roles, size 6 — matches the project's standard body-text
size) below that, all three in parallel — and stops there: no rooftop-dawn background yet (GDD
wants one), no auto-return to a main menu (doesn't exist yet). The text labels share a
`_make_label()` helper.
**Note**: `Scenes/Assets/UI/YellowDuck.jpg` — despite the source filename ending in `.png`, the
file is actually JPEG data (checked the magic bytes: `FF D8 FF E0`), so it was copied in with a
corrected `.jpg` extension rather than trusting the original name.

**`duck_trigger.gd`** (Area3D):
- Fires once; disconnects `body_entered` after first trigger to prevent replay in same scene load
- Calls `duck.trigger()` via `call_deferred`

**Per-map dialogue:** defined in `duck.gd` via `_lines_for(map_id)` `match` statement — covers all 5 maps.

## Procedural Audio

All in-game audio uses `AudioStreamGenerator` (PCM push) — no audio files required.

**NPC dialogue blips** (`Scenes/UI/dialogue_ui.gd`):
- Square wave, `BLIP_FREQ=520 Hz`, `BLIP_DURATION=0.055 s`, `BLIP_RATE=11025`
- Pitch per character: `voice_pitch ± randf_range(−0.06, 0.06)` — creates per-NPC voice character
- Envelope: `pow(1 − t, 0.4)` decay

**Duck blips** (`Scenes/Duck/duck_dialogue_ui.gd`):
- Same square wave; `BLIP_FREQ=400 Hz`, fixed pitch — quieter, mellower tone

**Footsteps** (`Scenes/Player/player.gd`):
- `AudioStreamGenerator`, −18 dB; fires every `STEP_INTERVAL=0.42 s` (or `0.60 s` when smoking)
- Mix: 25% sine tone (frequency interpolated 55–95 Hz by speed) + 75% white noise
- Decay envelope 0.55; no footstep sound when stationary

**GDScript 4 audio notes:**
- `AudioStreamWAV` format enums (`FORMAT_16_BIT`, `FORMAT_8_BIT`) are inaccessible at runtime in Godot 4.6 — always use `AudioStreamGenerator` + `push_frame()`
- `lerp()` returns `Variant`; use `lerpf()` for float mixing to avoid type inference errors

## Skyscraper Background Buildings

Source: `SkyscraperPack` (CC0). FBX files contain no embedded texture paths — textures must be baked in via Blender before importing to Godot.

**Conversion tool:** `tools/fbx_to_glb_with_texture.py`

```powershell
& "D:\Blender\blender.exe" --background --python tools\fbx_to_glb_with_texture.py `
  -- <models_dir> <textures_dir> <output_dir>
```

Naming convention: `building_01.x.fbx` → `building_01.png`. Script assigns the matching texture as both albedo and emission (strength 1.5) so buildings glow at night without requiring scene lighting.

Output GLBs go to `Scenes/Assets/SkyscraperPack/glb/`.

## Code Conventions

- GDScript with static typing (`:=` or explicit types)
- No comments unless logic is non-obvious
- One script per scene, co-located with the scene file
- All code and documentation in English
