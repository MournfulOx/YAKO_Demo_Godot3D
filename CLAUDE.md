# CLAUDE.md

## Project

PSX-style retro low-poly walking narrative game. Godot 4.6, Forward+ renderer, Jolt Physics.
Gameplay: first-person exploration + NPC dialogue. No jumping, no combat.

Narrative/content spec lives in the GDD (currently v0.7, held outside the repo) — 5 locations
(Convenience Store, Crossroads, Under the Overpass, Arcade Alley, School Rooftop), 21 animal NPCs,
a Duck "inner voice" companion, and a hidden fragment thread across 5 NPCs. Only the first 3
locations and 8 NPCs are built so far — see `## NPC System` and `## Directory Structure` below for
what's actually implemented vs pending. **The GDD's Duck companion has been cut from the actual
build** (direct request) — the Yellow Duck collectible fragments carry that role instead, see
`## Duck Companion System (deprecated)`.

## Engine & Settings

- Godot 4.6, Direct3D 12 (Windows)
- Render resolution: 320×240, window: 1980×1080, Stretch Mode: viewport
- Shader Global required: `precision_multiplier` (Float, 0.5) — controls vertex snapping intensity

## Directory Structure

```
demo/
├── autoload/
│   ├── BackroomState.gd              # cross-scene singleton: has the Map_03 Backrooms egg been entered
│   ├── Localization.gd               # registers the Chinese Translation (English text is the key)
│   ├── SceneManager.gd               # CanvasLayer (layer=20): fade transition + location name display
│   ├── SettingsState.gd              # master volume + language, persisted to user://settings.cfg
│   └── YellowDuckState.gd            # cross-scene singleton: which of the 5 Yellow Duck fragments are collected
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
│   │   └── duck_dialogue_ui.gd       # CanvasLayer (layer=4): typewriter + blip audio (400 Hz, fixed pitch) —
│   │                                 # the Duck companion NPC itself was cut; this UI survives, reused by
│   │                                 # yellow_duck_collectible.gd for its own one-shot pickup line
│   ├── Television/
│   │   ├── television.gd             # StaticBody3D, extends npc_base.gd: ending trigger, standard NPC dialogue/outline
│   │   └── television.tscn           # prefab: GLB body + CollisionShape3D (npc_base.gd interaction)
│   ├── Ending/
│   │   ├── ending_sequence.gd        # Node: listens for Television's `ending_triggered`, plays ending_title_ui
│   │   └── ending_title_ui.gd        # CanvasLayer (layer=25): immediate cut to black + "YAKO" title fade-in
│   ├── Collectibles/
│   │   ├── yellow_duck_collectible.gd/.tscn  # npc_base.gd interactable, reports to YellowDuckState by duck_id
│   │   └── backroom_teleporter.gd    # Area3D: instant same-scene teleport to a NodePath target
│   ├── NPC/
│   │   ├── npc_base.gd               # base class for all NPCs (extends StaticBody3D)
│   │   ├── NPC_Cat.tscn               # for Map 01
│   │   ├── NPC_Sheep.tscn             # for Map 01, fragment carrier [F]
│   │   ├── NPC_PrairieDog.tscn        # for Map 01
│   │   ├── NPC_Rat.tscn               # for Map 01
│   │   ├── NPC_Goat.tscn              # for Map 02
│   │   ├── NPC_FrenchBulldog.tscn     # for Map 02
│   │   ├── NPC_KoiFish.tscn           # for Map 02
│   │   ├── NPC_Baboon.tscn            # for Map 02
│   │   ├── NPC_Goose.tscn             # for Map 02, fragment carrier [F]
│   │   ├── NPC_GreatWhiteShark.tscn   # for Map 02
│   │   ├── NPC_Otter.tscn             # for Map 03, fragment carrier [F]
│   │   ├── NPC_Dog.tscn               # for Map 03
│   │   ├── NPC_Giraffe.tscn           # for Map 03
│   │   ├── NPC_Deer.tscn              # for Map 03
│   │   ├── NPC_Panda.tscn             # for Map 03
│   │   ├── NPC_Raccoon.tscn           # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Fish.tscn              # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Toucan.tscn            # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Octopus.tscn           # for Map 04 (map doesn't exist yet), fragment carrier [F]
│   │   ├── NPC_TRex.tscn              # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Crab.tscn              # for Map 04 (map doesn't exist yet), fragment carrier [F] — replaces Koala
│   │   ├── NPC_Caveman.tscn           # Map_03 Backrooms egg, one-off, not in the GDD roster
│   │   ├── NPC_Chicken.tscn           # bonus, not in GDD roster — from a leftover unused model
│   │   ├── NPC_Penguin.tscn           # bonus, not in GDD roster — from a leftover unused model
│   │   ├── NPC_GreyAlien.tscn         # bonus, not in GDD roster — from a leftover unused model
│   │   └── NPC_Capybara.tscn          # legacy — not in GDD v0.7's 21-NPC roster, currently unused
│   │   # All 21 GDD roster slots now have a prefab. Koala[F] was swapped for Crab per direct
│   │   # request (same fragment dialogue, no model ever sourced for Koala) — don't reintroduce
│   │   # a Koala NPC without checking first.
│   │   # IMPORTANT: "for Map NN" above means the prefab exists and is ready to drag in —
│   │   # as of this writing NONE of these NPCs (old or new) have actually been placed into
│   │   # any map scene yet. Placement is unstarted level-design work for every single one.
│   │   # STILL UNRESOLVED: NPC_Otter/NPC_Raccoon/NPC_Sheep/NPC_Fish have no real model. Checked
│   │   # C:\Users\furik\Downloads\Models and every asset folder in the project — no otter,
│   │   # raccoon, sheep, or generic-fish model exists anywhere accessible. Each now has a
│   │   # bright-magenta CapsuleMesh/CapsuleShape3D placeholder `Body` (radius 0.2, height 0.8)
│   │   # instead of nothing, though — the earlier state (no `Body`, no CollisionShape3D at all)
│   │   # meant they'd be invisible AND un-clickable if dragged into a map, silently broken with
│   │   # no error. Magenta is the deliberate "missing asset" convention so nobody mistakes the
│   │   # capsule for a finished look. Swap the mesh/material for a real model when one's found;
│   │   # no other changes needed elsewhere since npc_base.gd just re-shades whatever's there.
│   │   # Bonus NPCs (Chicken/Penguin/GreyAlien) use placeholder dialogue I wrote myself, not
│   │   # GDD content (there is none for them) — treat as a first draft, not final lines.
│   │   # Deliberately NOT turned into NPCs despite being unused: `parappa_the_rapper.glb`
│   │   # (a recognisable third-party licensed character — PaRappa the Rapper), and
│   │   # `computer_-_serial_experiments_lain.glb` (a modeled recreation of a specific
│   │   # copyrighted anime prop). Also found `mc_donalds_sign_bind.glb` sitting in the same
│   │   # folder — that's a real trademarked brand's signage, not a creature at all, and
│   │   # shouldn't ship in the project regardless of NPC plans; flag for removal/replacement
│   │   # with the level-design team if it's not already spoken for. `psx_coffin.glb` is a
│   │   # non-creature prop, left alone too (nothing to talk).
│   ├── UI/
│   │   ├── dialogue_ui.gd            # CanvasLayer (layer=5): typewriter subtitle + blip audio, code-only
│   │   ├── MainMenu.tscn              # Start/Quit over a live 3D shot of the Television — see below
│   │   ├── main_menu_ui.gd           # CanvasLayer (layer=10), code-built buttons, pixel font
│   │   ├── menu_camera.gd            # Camera3D: self-aims at a NodePath target via look_at() on _ready()
│   │   ├── OpeningQuote.tscn          # Psalm 102:6-7 black screen, reached from MainMenu's Start
│   │   └── opening_quote_ui.gd       # CanvasLayer (layer=10): full text at once, hold, fade, then Map_01
│   ├── Fonts/
│   │   ├── pixel.ttf                 # pixel font for English (locale "en") — no CJK glyphs at all
│   │   ├── ark-pixel-16px-proportional-zh_cn.ttf  # pixel font for Chinese (locale "zh")
│   │   └── ark-pixel-16px-proportional-ja.ttf     # pixel font for Japanese (locale "ja")
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
│       ├── MiscAssets/                # grab-bag of individually sourced props, by category:
│       │   └── animal/ car/ environment/ furniture/ small assets/
│       │       # animal/ holds every NPC's GLB regardless of which map it's for (not just
│       │       # Map 01) — source files come from C:\Users\furik\Downloads\Models
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

- Mouse captured in `_ready()`; Esc no longer just releases the mouse — it now opens the pause
  menu (see `## Pause Menu` below), which handles capture/release itself
- Mouse X → rotate CharacterBody3D (yaw), Mouse Y → rotate Head (pitch, clamped ±90°)
- Movement uses `transform.basis` so direction follows player facing
- No gravity, no jumping — `velocity.y` is unused
- Speed halved (`SPEED * 0.5`) while `cigarette.is_smoking` is true
- `DialogueUI` CanvasLayer instantiated in `_ready()` from `Scenes/UI/dialogue_ui.gd`
- `PauseMenuUI` CanvasLayer instantiated in `_ready()` from `Scenes/UI/pause_menu_ui.gd`
- Head bob: `BOB_SPEED=1.3`, `BOB_AMP_Y=0.008`, `BOB_AMP_X=0.004`; accumulates only while velocity > 0
- Footstep audio via `AudioStreamGenerator`: `STEP_INTERVAL=0.42s` (normal), `0.60s` (slow/smoking); 25% sine tone (55–95 Hz, pitch scales with speed) + 75% white noise, −18 dB

## Pause Menu

`Scenes/UI/pause_menu_ui.gd` — code-built `CanvasLayer` (layer=15, `PROCESS_MODE_ALWAYS`),
instantiated by `player.gd` alongside `DialogueUI`, so it exists on every map that has a Player
(not on `MainMenu`/`OpeningQuote`/the ending screens, which have no Player at all).

- Listens for `KEY_ESCAPE` via `_unhandled_input()` (not `_input()`, so NPC/cigarette input in
  `player.gd` still gets first look at every other key) and calls `toggle()`
- `open()`: shows the menu, sets `get_tree().paused = true`, releases the mouse. Since `player.gd`
  has no `PROCESS_MODE_ALWAYS` override, pausing the tree freezes movement/interaction outright —
  same mechanism `ending_sequence.gd` already relies on to stop the player after the ending
- `close()`: hides the menu, unpauses the tree, recaptures the mouse
- Buttons: **Resume** (`close()`), **Settings** (opens `settings_menu_ui.gd`, see `## Settings &
  Localization` below), **Main Menu** (`close()` then `SceneManager.change_scene()` to
  `Scenes/UI/MainMenu.tscn` — unpausing first matters, since `paused` is tree-global and would
  otherwise carry over and freeze the next scene too), **Quit** (`get_tree().quit()`)

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
- `is_complete() → bool` — has this NPC been talked to all the way through at least once; used by `gated_scene_trigger.gd` to lock an exit until a required conversation is finished

**Outline system:**
- `set_outline(true/false)` — recursively finds MeshInstance3D children, applies/removes `npc_outline.gdshader` as `next_pass` on surface override materials
- Called by player.gd when NPC enters/leaves aim

**Face-player turn:**
- `@export var face_player_on_interact: bool = true` — on `start()`, tweens the NPC's Y
  rotation (`FACE_TURN_DURATION = 0.35s`, shortest-path via `wrapf`) to face whichever
  `Camera3D` is active (`get_viewport().get_camera_3d()` — works without any direct reference
  to the player, since Player's `Camera3D` is the only camera in these scenes); on `_finish()`,
  tweens back to the rotation recorded in `_ready()`. Only rotates yaw (kept level) — pitch/roll
  untouched. Set to `false` on `Television` (a wall-mounted object shouldn't swivel).
- Target angle is computed by borrowing `Node3D.look_at()` itself (snap to face the target,
  read the resulting `rotation.y`, then revert) rather than deriving the angle by hand via
  `Basis`/trig — a first attempt using `Basis.looking_at()` + `get_euler()` produced
  consistently wrong (backwards) results, so it was replaced with this approach instead.
- `@export var face_offset_deg: float = 180.0` — **not every downloaded model was authored
  facing -Z**, so pointing the root's -Z at the player only produces correct-looking results
  for models whose front happens to already line up with Godot's convention. Defaults to 180
  because that's what most of this project's models needed once tested across the roster; the
  confirmed exception is `NPC_TRex`, which sets its own `face_offset_deg = 0.0` override in its
  `.tscn` to protect it from the shared default. If some other NPC still turns to face
  sideways instead of straight on, try 90 or -90 instead. Only affects the face-toward-player
  angle — the resting/idle pose and the revert-on-`_finish()` target are untouched by it.

**Roster status (GDD v0.7, 21 NPCs across 5 maps):**

| Map | Prefab built | Still missing |
|-----|-------|---------|
| 01 Convenience Store | Cat, Sheep [F], Prairie Dog, Rat | — |
| 02 Crossroads | Goat, French Bulldog, Koi Fish, Baboon, Goose [F], Great White Shark | — |
| 03 Under the Overpass | Otter [F], Dog, Giraffe, Deer, Panda | — |
| 04 Arcade Alley | Raccoon, Fish, Toucan, Octopus [F], T-Rex, Crab [F] (map scene doesn't exist yet) | — |
| 05 School Rooftop | Television (`Scenes/Television/television.tscn`, ending trigger built as an NPC-style interactable) | — |

All 21 GDD roster slots now have a built `.tscn` prefab — Koala was swapped for **Crab**
(`Scenes/Assets/MiscAssets/low-poly_crab.glb`, already sitting unused in the project) per
direct request, keeping Koala's exact fragment dialogue unchanged (the lines were never
Koala-specific to begin with). Models sourced from `C:\Users\furik\Downloads\Models` plus
whatever unused assets were already sitting in `Scenes/Assets/MiscAssets/`, copied/kept under
`Scenes/Assets/MiscAssets/animal/`. **None of them — old or new — have actually been placed
into a map scene yet**; "built" here only means the prefab exists and is ready to drag in.
`Scenes/Assets/MiscAssets/animal/ps1_chicken.glb` (no matching GDD roster slot — chicken isn't
one of the 21 animals) was later used for the bonus `NPC_Chicken.tscn` below, so it's no longer
unused; this note is kept only so nobody goes looking for a second use for the same file.

Placement (position/rotation, avoiding overlap with
level geometry, picking a spot that reads well) is unstarted level-design work for every single
one, left to the person doing map layout since it needs visual judgement in the editor.
`dialogue_lines`/`repeat_lines` content for all of them is pulled directly from the GDD, not
invented — except `NPC_Caveman` (Backrooms egg, not in the GDD roster), which is placeholder text.

**Scale/collision caveat**: for the 14 new prefabs, `Body` transform scale and the
`CollisionShape3D` size were computed from each GLB's raw bounding box (aiming for roughly
plausible relative sizes — Giraffe deliberately tall enough to justify "head lodged against the
overpass," Rat/Prairie Dog small, etc.) but **not visually confirmed in the editor**. Check each
one after placing it and adjust `Body`'s scale / the collision box if something looks off —
same caveat that already applied to `NPC_Caveman`.

`[F]` = fragment carrier — part of the hidden narrative thread (GDD v0.7 §5.5).

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

**`autoload/BackroomState.gd`** — tracks whether the player has already entered the Map_03
Backrooms egg (persists across scene loads). Single non-keyed bool, not a dictionary, since
there's only one Backroom in the game (unlike `YellowDuckState`, which keys by duck id). Checked
by `Scenes/backroom_entry_trigger.gd` so the hidden entrance only works once.
- `has_entered() → bool`
- `mark_entered() → void`

**`autoload/Localization.gd`** and **`autoload/SettingsState.gd`** — see `## Settings &
Localization` below.

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

**Map connectivity (Map_01–03)**: `Map_01_ConvenienceStore` → `Map_02_Crossroads` (`ExitTrigger`)
was already wired. `Map_02_Crossroads` had **no exit triggers at all** — a real dead end once
the player arrived — and `Map_03_UnderTheOverPass` had no way back to `Map_02` either (only the
Backroom side-path). Added `ExitToMap01`/`ExitToMap03` in `Map_02_Crossroads.tscn` and
`ExitToMap02` in `Map_03_UnderTheOverPass.tscn` (plain `scene_trigger.gd`, `BoxShape3D
Vector3(5, 3, 0.5)`, placed a few metres from each map's player spawn) so Map_01↔02↔03 is fully
walkable both directions. `Map_03` still has no "continue forward" exit — `Map_04_ArcadeAlley`/
`Map_05_SchoolRooftop` don't exist yet, so there's deliberately nowhere for it to go until those
are built. Placeholder positions again — not tied to actual level geometry/edges, that's Zee's
placement pass.

**`Scenes/gated_scene_trigger.gd`** — same shape as `scene_trigger.gd` but locks the exit
behind an NPC conversation. `@export var required_npc_path: NodePath` in addition to
`target_scene`; on `body_entered`, resolves the NPC via `get_node_or_null()` and only calls
`SceneManager.change_scene()` if `npc.is_complete()` is true (silently does nothing otherwise
— no "locked" message/UI, matches the game's minimal-HUD style). **Fails closed**: if
`required_npc_path` is set but fails to resolve to a node (or that node has no `is_complete()`),
the trigger blocks rather than letting the player through — an earlier version only checked
`npc != null and not npc.is_complete()`, which silently let the player pass whenever the NPC
reference failed to resolve for any reason (this actually happened in testing: the exit fired
with zero interaction with `NPC_Caveman`). Leaving `required_npc_path` empty still means
"ungated," for any future reuse of this script without an NPC requirement. Used on `Scenes/Maps/Backroom.tscn`'s
exit (`ExitTrigger`, near `NPC_Caveman`), gated on `NPC_Caveman` — the player must finish talking
to it before they can leave the Backrooms egg. Kept as a separate script rather than modifying
`scene_trigger.gd` itself since every other exit trigger in the game should stay ungated.
Entry the other direction uses `Scenes/backroom_entry_trigger.gd` (`BackroomEntryTrigger`)
placed in `Map_03_UnderTheOverPass.tscn`, a few metres from the player spawn — a dedicated
one-shot variant of `scene_trigger.gd` rather than the shared generic script itself (same
reasoning as `gated_scene_trigger.gd`: every other exit trigger in the game should stay
ordinary/repeatable). Checks a new `autoload/BackroomState.gd` singleton
(`has_entered()`/`mark_entered()`, registered in `project.godot`'s `[autoload]`) so the egg can
only be entered once per play session — once found, the entry silently stops doing anything on
subsequent passes, matching the "found it, that's it" feel of a hidden easter egg rather than a
repeatable door. `BackroomState` is a single non-keyed bool (unlike `DuckState`/
`YellowDuckState`, which track per-map/per-duck state) since there's only ever one Backroom in
the game. **Both triggers currently sit at placeholder positions/sizes (`BoxShape3D`
`Vector3(3, 3, 1)`, not tucked into an actual hidden gap in the level geometry) purely so the
Map_03 ↔ Backroom loop is testable end-to-end** — this closes a real gap that existed before
(the Backroom was previously unreachable in play despite existing as a scene); dressing the
entry as an actual hidden gap in a wall is still Zee's call.

**`Scenes/NPC/NPC_Caveman.tscn`** — one-off NPC (not part of the GDD v0.7 21-animal roster)
built for the Map_03 Backrooms egg specifically, using `npc_base.gd` like every other NPC.
Model: `Scenes/Assets/Backroom/backrooms_movie_caveman_cutout.glb` (also includes an
intercom/screen prop in the same file). Native mesh scale is huge (~74 units tall) — scaled
down `0.025x` in the `.tscn` to read as roughly human-height; **not yet visually verified**,
same caveat as other freshly-imported assets in this project — check in the editor and adjust
the `Body` transform/`CollisionShape3D` if it looks off. `dialogue_lines`/`repeat_lines` are
placeholder text, not final content.

## Collectibles

Hidden Yellow Duck pickups (1 per map, Map_01–04) plus a Map_03 "Backrooms" easter egg
(walk through a hidden gap in a wall → teleported to a hidden pocket space → 1 more duck
there — 5 total). **This is currently just the reserved interface/plumbing** — no ducks,
walls, or backroom space have actually been placed in any map yet; that's level-design work.
Building blocks ready to drop in once placement happens:

**`Scenes/Collectibles/yellow_duck_collectible.tscn`** (`Area3D`, `yellow_duck_collectible.gd`)
— proximity-triggered, but deliberately NOT an instant pickup-on-touch: the user wants "finding"
a duck to require an actual (if brief) dialogue beat first, modeled on the same
trigger-then-`duck_dialogue_ui.gd` pattern the now-removed Duck companion NPC used to use (see
`## Duck Companion System (deprecated)` below) rather than the NPC raycast+click pipeline.
`@export var duck_id: String`
must be a unique string per placed instance; `@export var lines: Array[String]` defaults to
`["a little piece of you."]` (a deliberate callback to the Television secret ending's "you
found all of me... every little piece." line — these collectibles ARE the scattered Duck
fragments), overridable per-instance for map-specific flavor. No ID scheme is enforced in code,
but use exactly these 5 (matches `TOTAL_DUCKS=5` and what the design below assumes):

| `duck_id` | Suggested hiding spot (thematic, not literal coordinates — Zee's call) |
|---|---|
| `Map_01_ConvenienceStore` | Tucked among shelf clutter, near the magazine hidden-detail spot (§4.2) |
| `Map_02_Crossroads` | On/behind the vending machine with the faded sold-out row |
| `Map_03_UnderTheOverPass` | Near the abandoned school bag, in pillar shadow |
| `Map_03_Backroom` | Alone in the empty liminal space — the reward for finding the egg itself |
| `Map_04_ArcadeAlley` | On top of/inside a cabinet, claw-machine-reject vibe |

Tying each duck to an existing GDD hidden-detail beat keeps them feeling like part of the
world instead of arbitrary meta-collectibles — not mandatory, just a suggestion for Zee's
placement pass. `_ready()`: self-frees immediately if `duck_id` is empty or
`YellowDuckState.has_collected(duck_id)` is already true (re-entering an already-collected duck
on scene reload doesn't re-trigger); otherwise applies a `psx_lit.gdshader` +
warm-`OmniLight3D` treatment (`_apply_psx_shader()` / `_add_light()`, duplicated rather than
shared — matches this codebase's existing pattern of each actor script keeping its own copy
rather than a shared helper) and connects `body_entered`. On first `CharacterBody3D` entry:
disconnects `body_entered` (a one-shot guard, prevents re-firing on repeated overlap in the same
scene load), then `call_deferred`s into `_collect()`, which instantiates a fresh
`Scenes/Duck/duck_dialogue_ui.gd` (reused as-is), `await`s `play_lines(lines)` (fully automatic,
no click needed to advance), and only once that finishes calls
`YellowDuckState.collect(duck_id)`, plays a short `_vanish()` tween (scale to zero with a
`TRANS_BACK` ease so it "pops" rather than just shrinking, a small upward float, and a brief
brightening flash on its own light), then `await`s that before `queue_free()`s itself —
disappearing outright the instant it's collected read as jarring, so this softens it into a
small dissolve-into-light beat. The pickup-notification UI (below) fires strictly after the
dialogue beat, never on the instant the player walks in.
`CollisionShape3D` is an oversized `SphereShape3D` (`radius = 2.0`) rather than something the
player has to bump into directly — the trigger should fire from a comfortable few-metre
distance while approaching it, not require exact contact. Visual is an instance of
`Scenes/Assets/MiscAssets/animal/Duck.glb` (`Body`, scale `3`), not the earlier flat
`Sprite3D`/jpg placeholder. **Placeholder instances have
been dropped near the player spawn in every map that currently exists** — `duck_id =
"Map_01_ConvenienceStore"` in `Map_01_ConvenienceStore.tscn`, `"Map_02_Crossroads"` in
`Map_02_Crossroads.tscn`, `"Map_03_UnderTheOverPass"` in `Map_03_UnderTheOverPass.tscn`, and
`"Map_03_Backroom"` in `Backroom.tscn` — purely so the pickup-notification UI has something to
test against in each one; none of these are the real thematic placement from the table above,
that's still Zee's call. `Map_04_ArcadeAlley` has no instance yet since that map doesn't exist.
Note for whoever edits maps by hand: if a map scene is open in the Godot editor while this file
(or any file inside it) is edited externally, the next editor-side save will silently overwrite
the external edit — close the relevant scene tab first.

**`Scenes/Collectibles/duck_pickup_notification_ui.gd`** (`CanvasLayer`, layer=6) —
instantiated by `player.gd` alongside `DialogueUI`/`PauseMenuUI`, so it's live on every map
with a Player. Connects to `YellowDuckState.duck_collected(count, total)` (emitted from
`collect()`), so it only has to wire up once instead of per-instance. Shows `"Yellow Duck found.
<count> / <total>"` near the top of the screen (or `"All 5 Yellow Ducks found."` once the last
one is picked up), fades in (`0.3s`), holds (`2.2s`), fades out (`0.6s`) — same fade-tween idiom
used everywhere else in the project's UI, no typewriter needed since it's a short status line,
not dialogue.

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
of me. every little piece." → "none of them added up to a whole person. that's alright." →
"distance never really separated us." → "we are always broadcasting."` — frames the 5
collectible ducks as scattered fragments of the Duck companion, so finding them all pays off
narratively (not just a meta-achievement) without breaking the game's minimalist dialogue tone.
Same Eva/Lain/*Oyasumi Punpun*-flavored tribute pass as the collectible lines themselves (see
`## Collectibles` above) — original wording, no direct quotes or copyrighted material. Adjust
wording directly on the Television node in the Inspector, no code changes needed.

## Duck Companion System (deprecated)

The original "inner voice" companion — a one-shot NPC (`duck.gd` + `duck_trigger.gd`, guarded by
an autoload `DuckState`) that walked up per-map, said a short line, then `queue_free()`d itself —
has been **cut entirely**, direct request: the Yellow Duck collectible fragments (see
`## Collectibles` above) now carry that role instead. `duck.gd`, `duck_trigger.gd`, and
`autoload/DuckState.gd` have been deleted and `DuckState` removed from `project.godot`'s
`[autoload]`; don't reintroduce them without checking first. Every map had already lost its Duck
instance (Map_01's was removed directly in the editor; Map_02/03 turned out to never have had
one placed, or lost theirs the same way) by the time this was confirmed, so no map scenes needed
further edits for the removal.

**`Scenes/Duck/duck_dialogue_ui.gd`** (CanvasLayer, layer=4) — the one piece of this system that
survives, because `yellow_duck_collectible.gd` reuses it as-is for its own one-shot pickup line
(see `## Collectibles` above):
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
- `@export var show_screen_static: bool = true` — gates `_apply_screen_static()` (runs *after*
  `super._ready()`, overriding what it just set): any mesh with `"Screen"` in its name gets
  `shaders/tv_screen_static.gdshader` instead of the standard NPC material — a `shader_type
  spatial` unlit hash-noise flicker (same technique as `sky_stars.gdshader`'s `hash()`), always
  playing. Being purely procedural per-fragment, this is immune to the whole class of UV/geometry
  bugs the old text-on-screen approach hit — noise doesn't care about orientation, so it was safe
  to keep even after that system was scrapped. Set to `false` on the `Television` instance in
  `Scenes/UI/MainMenu.tscn` — constant flicker read as too visually busy for a menu backdrop.
- `@export var flicker_screen_static: bool = false` / `flicker_interval: float = 6.0` /
  `flicker_duration: float = 2.5` / `flicker_noise_speed: float = 8.0` — alternative to
  `show_screen_static` for exactly this "too busy for a background prop" case: screens stay on
  their normal baked look and only swap to `tv_screen_static.gdshader` for `flicker_duration`
  seconds every `flicker_interval` seconds (a looping `Timer` + `await
  get_tree().create_timer(...)`, `_setup_screen_flicker()`/`_collect_screen_surfaces()`/
  `_on_flicker_tick()`), then swap back to each surface's original material — a brief "signal
  glitch" instead of continuous noise. `flicker_noise_speed` overrides the noise shader's own
  `flicker_speed` uniform (default `24.0`, very fast) down to a slower per-instance value so the
  static reads as a held glitch frame rather than a rapid strobe within the flash itself — first
  pass used the shader's default speed with only a `0.15s` duration/`4.0s` interval and the user
  reported it flickered too fast with no perceptible pause; both the hold duration and the
  in-shader speed were slowed down together to fix it. Only takes effect when `show_screen_static`
  is `false` (checked first in `_ready()`). Enabled on the `Television` instance in
  `Scenes/UI/MainMenu.tscn` (`flicker_screen_static = true`, default interval/duration/speed) in
  place of the old fully-static-off look. Not visually confirmed — tune further if still off.
- `_add_screen_lights()` adds one small cyan `OmniLight3D` (`GLOW_COLOR`) per variant at its
  approximate screen centre (`SCREEN_CENTER`), parented under that variant's wrapper so it
  follows the grid spread automatically — in addition to the single generic light `npc_base.gd`
  already adds. Intensity/range are exported (`screen_glow_energy = 1.4`, `screen_glow_range =
  1.5` by default) rather than hardcoded — the menu camera in `Scenes/UI/MainMenu.tscn` sits much
  closer to the screens than a normal NPC conversation distance, which blew these out into
  overexposed blobs (aggravated by the scene's low `glow_hdr_threshold = 0.75`), so that instance
  overrides them down to `0.6` / `1.0`. Not visually confirmed — tune further if still too bright.
- Text now goes through the same `dialogue_ui.gd` subtitle path every other NPC uses — no
  per-screen text, no outline distinction from a normal NPC. This is a known, deliberate
  simplification vs GDD v0.7 §5.4 (see note above); the cigarette/TV input-overlap gap noted in
  an earlier pass is moot now too, since NPC dialogue already force-closes the cigarette.

**`Scenes/Ending/ending_sequence.gd`** (Node) — `@export var television_path: NodePath`,
resolved to `var television: Node3D` via `get_node_or_null()` in `_ready()`. **Uses `NodePath` +
manual `get_node()`, not a typed `@export var x: Node3D`** — the latter looked like it should
auto-resolve a hand-written `x = NodePath("...")` line in a `.tscn` into a live node reference,
but empirically it silently stayed null at runtime. Don't revert to the typed-Node export style
without re-verifying this first. On
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
(`TextureRect`, `Scenes/Assets/Logo/YellowDuck.jpg`, `TEXTURE_FILTER_NEAREST` to stay crisp at
this resolution, `LOGO_SIZE=64`), a `STUDIO_NAME` label ("YellowDuck Studio", size 8) below it,
and a `CREDITS_TEXT` label (team names/roles, size 6 — matches the project's standard body-text
size) below that, all three in parallel — and stops there: no rooftop-dawn background yet (GDD
wants one), no auto-return to a main menu (doesn't exist yet). The text labels share a
`_make_label()` helper.
**Note**: `Scenes/Assets/Logo/YellowDuck.jpg` — despite the source filename ending in `.png`, the
file is actually JPEG data (checked the magic bytes: `FF D8 FF E0`), so it was copied in with a
corrected `.jpg` extension rather than trusting the original name.

## Main Menu

`Scenes/UI/MainMenu.tscn` — now `project.godot`'s `run/main_scene` (previously Map_01 directly;
change this back if you need quick iteration on gameplay without going through the menu first).
Background is a **live, real-time-rendered shot of the Television** (per GDD's "real-time
rendered street scene" main menu spec), not a static image — reuses the same environment/floor
setup as `Scenes/Television/television_test.tscn` plus a `Television` instance, but swaps out
`Player` for a dedicated menu camera since there's no gameplay here.

- `Scenes/UI/menu_camera.gd` (`Camera3D`) — `@export var look_at_path: NodePath`; on `_ready()`,
  sets `current = true` and calls `look_at()` at the target. Deliberately touches rotation ONLY,
  not position — an earlier version also computed `global_position` from `distance`/`height`
  export floats, which silently overwrote whatever position was set by hand in the editor
  (dragging the gizmo did nothing, since `_ready()` clobbered it on run) and was confusing/
  surprising, so it was reverted. Position the camera by dragging it in the editor like any other
  node; the script only takes care of aiming it at the target. **Note**: the small Camera3D
  preview thumbnail in the Inspector does not match the real windowed output (different
  aspect/post-processing handling) — always verify framing by actually running the scene, not by
  eyeballing that preview.
- `Scenes/UI/main_menu_ui.gd` (`CanvasLayer`, layer=10) — code-built "YAKO" title + `Start`/
  `Settings`/`Quit` buttons (pixel font, white with black outline, matching the rest of the
  game's UI convention). Sets `Input.mouse_mode = MOUSE_MODE_VISIBLE` in `_ready()` since there's
  no `Player` node here to do it. `Start` calls `SceneManager.change_scene()` to
  `Scenes/UI/OpeningQuote.tscn` (see below), not straight to Map_01. `Settings` opens
  `settings_menu_ui.gd` — see `## Settings & Localization` below.

## Opening Quote

`Scenes/UI/OpeningQuote.tscn` — Psalm 102:6-7 on a black screen, per GDD §"Opening Quote"
(referencing Death Stranding's opening-quote format). `opening_quote_ui.gd` (`CanvasLayer`,
layer=10, `PROCESS_MODE_ALWAYS`): full quote text appears all at once (not typewriter — GDD is
explicit about this, unlike every other text system in the game), holds for `QUOTE_HOLD = 12s`
(GDD's 10-15s range), fades out over `FADE_DURATION = 1s`, then calls
`SceneManager.change_scene("res://Scenes/Maps/Map_01_ConvenienceStore.tscn")`. No skip input —
matches GDD ("No skip"). Reached via `MainMenu`'s `Start` button, not the project's actual
`run/main_scene` (that's still `MainMenu.tscn`). Since the screen is already black when
`SceneManager.change_scene()` fires, its own fade-to-black-then-back overlay reads as a
continuation rather than a visible cut, which is what "fades into game" in the GDD describes.

## Settings & Localization

Direct request to build the previously-deferred Settings menu (language + volume, per the GDD)
now that the rest of the UI loop was solid — and then, once the font gap below got resolved, to
add Japanese alongside the originally-requested Chinese. Two new autoloads plus a reusable
Settings screen support all three: English, Chinese, and Japanese.

**`autoload/Localization.gd`** — registers one `Translation` resource per non-English language
(`zh`, `ja`) with `TranslationServer` in `_ready()`. English source text is used directly as the
translation key (gettext-style): every `tr("...")` call elsewhere passes the literal English
string that was already sitting in NPC `dialogue_lines`/`repeat_lines` and UI code, so no NPC
`.tscn` file needed touching — only the *display* layer wraps text in `tr()`. No English
`Translation` is registered; when locale is `"en"` (the default) `tr()` calls simply have no
match and fall through to the original string. `ZH_STRINGS`/`JA_STRINGS` are two big dictionary
literals, each covering every NPC's dialogue (all 25 + Caveman + Television, regular and secret
lines), all 5 Yellow Duck fragment lines, the Opening Quote (Psalm 102:6-7 — phrased to match
the specific "desert owl" / "owl among the ruins" imagery of the English text already in
`opening_quote_ui.gd`, not lifted verbatim from a specific published Bible edition in either
language), UI button/label text (including the two `%d`-templated pickup-notification strings
in `duck_pickup_notification_ui.gd` — translate the template *before* `%` substitution, e.g.
`tr("Yellow Duck found. %d / %d") % [count, total]`), the derived location names shown during
scene transitions, and the ending credits' role labels (team member names themselves are left
untranslated). Registered *before* `SettingsState` in `project.godot`'s `[autoload]` list —
order matters here, since `SettingsState._ready()` calls `TranslationServer.set_locale()` and
needs the target-language `Translation` already registered for that to have any effect.

**CJK fonts**: `Scenes/Fonts/pixel.ttf` (the original Latin pixel font) has zero glyph coverage
for CJK ranges at all — confirmed by parsing its binary `cmap` table directly, not a guess. Two
Ark Pixel Font files (OFL-licensed, so freely bundleable) were sourced to cover the other two
languages: `ark-pixel-16px-proportional-zh_cn.ttf` and `ark-pixel-16px-proportional-ja.ttf` —
also verified by parsing their `cmap` tables (both cover CJK ideographs *and* hiragana/katakana,
so the `ja` font isn't missing kana). **Deliberately three separate font files, switched
per-language, rather than one font with the other two set as `fallbacks`**: CJK is
"Han-unified" — the same Unicode codepoint for a shared Han character can have a different
region-specific glyph shape in Chinese vs. Japanese, so a static fallback *chain* would render
shared characters using whichever font happens to be earlier in the list regardless of which
language is actually active, producing visibly wrong-looking (if not incorrect) glyph shapes for
one of the two languages. Switching the *entire* active font per-language avoids that.

**`autoload/SettingsState.gd`** — `master_volume: float` (0–1, linear) and `language: String`
(`"en"`/`"zh"`/`"ja"`, cycled in that order by `cycle_language()`), persisted to
`user://settings.cfg` via `ConfigFile` and reloaded/reapplied in `_ready()` so preferences
survive a restart. `set_master_volume()` converts linear→dB (`linear_to_db`, with an explicit
`-80.0` floor at `0.0` since `linear_to_db(0.0)` is `-inf`) and writes it to the `"Master"` audio
bus — this is a single global control, not per-sound-type sliders, since every audio-emitting
script in the project (footsteps, NPC/Duck blips) already routes through the default Master bus
with its own hardcoded `volume_db` offset; adjusting the bus itself scales all of them together
without touching each script. `set_language()` calls `TranslationServer.set_locale()` directly
and emits `language_changed`. `get_active_font() -> Font` looks up `FONT_PATHS[language]` (falls
back to the English font for an unrecognized locale) — every UI script that used to
`load("res://Scenes/Fonts/pixel.ttf")` directly now calls this instead, so the whole game's font
follows whatever language is currently active. `get_active_font_size(base_size: int) -> int`
exists for the same reason but on the size axis: the Ark Pixel fonts are 16px-grid pixel fonts,
so rendering them at the small sizes tuned for `pixel.ttf` (6–10px, used everywhere in this
project) scales them down non-integrally and blurs them — first reported directly (user swapped
in a 16px-rendered export of the font after finding the initial 12px one too small/blurry, which
is what prompted adding this scaling layer at all). For English, `get_active_font_size()` is a
no-op (returns `base_size` unchanged); for `zh`/`ja` it buckets every size used in the project
into a clean multiple of 16 — `<=10 → 16` (body text, buttons, small labels), `>10 → 32`
(titles) — rather than trying to scale each one proportionally, since non-multiples-of-16 would
still blur. Every `add_theme_font_size_override()`/`LabelSettings.font_size` call site that
displays `tr()`-translatable (or even just Latin) text through the active font now routes its
literal size through this function — including labels that never show translated text
themselves (e.g. the "YAKO"/"YellowDuck Studio" labels in `ending_title_ui.gd`), because the
blur comes from the *font file's* native grid, not from whether that specific string happens to
be in English.

**`get_display_font_size(en_size: int, cjk_size: int) -> int`** — a second, separate sizing
helper for the handful of screens (`opening_quote_ui.gd`, and NPC/Duck dialogue —
`dialogue_ui.gd`'s `show_line()`, `duck_dialogue_ui.gd`'s `_play_one()`) where English and CJK
are meant to read as the *same visual size* rather than following the usual
"English stays small, CJK gets bucketed to 16/32" rule from `get_active_font_size()`. Returns
`en_size` for `"en"`, `cjk_size` otherwise — **not** the same number for both, because
`pixel.ttf` and the Ark Pixel fonts don't share a common em-square design: passing a single
flat `16` for every language (the first attempt) rendered English dramatically larger/wider
than the CJK fonts at the same nominal size, confirmed by direct visual comparison, not
assumed — English then wrapped far more aggressively (6+ short lines instead of 4-5) and read
as oversized. `10` for English then turned out too big specifically for the NPC/Duck dialogue
box (reported with a screenshot); went to `7`, then settled on **`9`** as the current tuned
value — `dialogue_ui.gd`/`duck_dialogue_ui.gd` now use `get_display_font_size(9, 16)` while
`opening_quote_ui.gd` stays at `get_display_font_size(10, 16)` — the two contexts didn't need to
match each other, only English-vs-CJK within each screen. If either still doesn't look
size-matched, adjust that call site's English number only — CJK at `16` has not been reported
as wrong anywhere. Both dialogue labels also gained an explicit
`vertical_alignment = VERTICAL_ALIGNMENT_CENTER` (previously unset, defaulting to top-aligned) —
requested alongside the size tuning so the text block sits centered in its box regardless of how
many lines it wraps to or which language/font is active, instead of always starting from the
same fixed top edge and growing an inconsistent amount downward. `dialogue_ui.gd`'s and
`duck_dialogue_ui.gd`'s subtitle box (`offset_top`) was widened from `-52.0` to `-80.0` (52px →
66px tall) to give the larger text
more room — at the old 6px-tuned box height, even the reduced size here only has room for ~2-3
lines before clipping, and several NPC lines run long enough to wrap to 3.

**`Scenes/UI/settings_menu_ui.gd`** (`CanvasLayer`, layer=16, `PROCESS_MODE_ALWAYS`) — a
dim-background overlay with a Volume `HSlider` (bound live to `SettingsState.set_master_volume`)
and a Language button that calls `cycle_language()` then its own `_refresh_text()` — this is the
one screen where live-refresh matters most, since the whole point of the button is to show the
change taking effect immediately: its own title/labels/buttons re-fetch font, font size
(`get_active_font_size()`), and `tr()` text right there, not just the button's own label.
`queue_free()`s itself on **Back**. Instantiated on-demand (not pre-built into any scene)
by a new **Settings** button added to both `main_menu_ui.gd` and `pause_menu_ui.gd` — each
guards against opening a second instance while one is already up (`_settings_instance` tracked,
cleared via the freed instance's `tree_exited` signal) rather than stacking duplicates if the
button is double-clicked. Because `main_menu_ui.gd` doesn't pause the tree and
`pause_menu_ui.gd` already does (and its Settings child inherits `PROCESS_MODE_ALWAYS` from
being instantiated as its own top-level `CanvasLayer`, not from inheriting the paused parent's
mode), Settings works correctly opened from either place.

**Live-refresh, and where it matters**: `tr()` and the active font only get (re-)applied at the
moment text is *about to be shown* — `dialogue_ui.gd`'s `show_line()`,
`duck_dialogue_ui.gd`'s `_play_one()`, `duck_pickup_notification_ui.gd`'s
`_on_duck_collected()`, `SceneManager.gd`'s `_transition()` (only when about to display a
location name) — rather than being fetched once and forgotten. This matters specifically for
anything long-lived that can still be on screen (or about to reappear) *after* a language change
happens elsewhere: those four all persist for an entire map session (or, for `SceneManager`, the
entire game), so a one-time-at-`_ready()` font/text fetch would go stale the moment the player
opens Settings mid-game and switches languages — this was caught and fixed during this pass, not
theoretical. `main_menu_ui.gd` and `pause_menu_ui.gd` have the same persistence problem for
their *own* buttons (Settings opens as a child overlay on top of them, so their labels aren't
recreated when Settings closes) — both now expose a `_refresh_text()` called on `open()`
(pause menu) or immediately after building the buttons (main menu) *and* from the Settings
child's `tree_exited` callback, so returning from Settings always repaints the parent menu's own
text/font too. `opening_quote_ui.gd` and `ending_title_ui.gd` don't need this — neither has a
path to Settings while on screen, so a one-time `_ready()` fetch is correct for them.

**No live-refresh of already-displayed text**: switching language while a dialogue line/menu
label is already on screen does not retroactively re-translate it — `tr()` only runs at the
moment a string is *about to be shown* (`dialogue_ui.gd`'s `show_line()`,
`duck_dialogue_ui.gd`'s `_play_one()`, each menu's `_ready()`). Since Settings is reached from
the Main Menu or the Pause menu (both static screens redrawn fresh each time they open), this is
not visibly a problem in practice — nobody is mid-typewriter when they flip the language toggle.

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
