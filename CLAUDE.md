# CLAUDE.md

## Project

PSX-style retro low-poly walking narrative game. Godot 4.6, Forward+ renderer, Jolt Physics.
Gameplay: first-person exploration + NPC dialogue. No jumping, no combat.

## Engine & Settings

- Godot 4.6, Direct3D 12 (Windows)
- Render resolution: 320×240, window: 1980×1080, Stretch Mode: viewport
- Shader Global required: `precision_multiplier` (Float, 0.5) — controls vertex snapping intensity

## Directory Structure

```
demo/
├── Scenes/
│   ├── scene_trigger.gd              # reusable map transition trigger (Area3D)
│   ├── Player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── cigarette.gd
│   ├── Maps/
│   │   ├── Map_01_ConvenienceStore.tscn
│   │   ├── Map_02_Crossroads.tscn
│   │   └── Map_03_UnderTheOverPass.tscn
│   ├── NPC/
│   │   ├── npc_base.gd               # base class for all NPCs (extends StaticBody3D)
│   │   ├── NPC_Cat.tscn              # Map 01
│   │   ├── NPC_Cow.tscn              # Map 02 (Capybara model)
│   │   ├── NPC_Penguin.tscn          # Map 02 (Goat model)
│   │   ├── NPC_Otter.tscn            # Map 03
│   │   ├── NPC_Raccoon.tscn          # Map 04
│   │   ├── NPC_Fish.tscn             # Map 04
│   │   ├── NPC_Dog.tscn              # Map 04
│   │   └── NPC_Sheep.tscn            # Map 05 (ending trigger)
│   ├── UI/
│   │   └── dialogue_ui.gd            # CanvasLayer (layer=5), subtitle display, code-only
│   └── Assets/
│       ├── Player/
│       │   ├── Cig.glb               # cigarette mesh (4 burn stages: Cig, CigBurn0-2)
│       │   └── cigs_carton.glb       # cigarette carton with CartonTopOpen animation
│       ├── LampPost/
│       │   └── LampPost.tscn         # prefab: Node3D + MeshInstance3D + OmniLight3D
│       ├── UrbanPack1/               # street props
│       └── skyscraper_pack/
│           ├── models/               # source FBX + textures/
│           └── glb/                  # converted GLB with emission baked in
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

## Scene Transition System

`Scenes/scene_trigger.gd` — attach to any `Area3D` node to create a map exit trigger.

```gdscript
@export_file("*.tscn") var target_scene: String = ""
```

- Detects `CharacterBody3D` entering the area via `body_entered`
- Uses `call_deferred` to avoid physics callback errors
- Set **Target Scene** in Inspector to the destination `.tscn` path
- CollisionShape3D: use a thin BoxShape3D (`Vector3(5, 3, 0.5)`) spanning the exit edge
- Collision Layer = 0 (none), Mask = Layer 1 (Player)

## Skyscraper Background Buildings

Source: `skyscraper_pack` (CC0). FBX files contain no embedded texture paths — textures must be baked in via Blender before importing to Godot.

**Conversion tool:** `tools/fbx_to_glb_with_texture.py`

```powershell
& "D:\Blender\blender.exe" --background --python tools\fbx_to_glb_with_texture.py `
  -- <models_dir> <textures_dir> <output_dir>
```

Naming convention: `building_01.x.fbx` → `building_01.png`. Script assigns the matching texture as both albedo and emission (strength 1.5) so buildings glow at night without requiring scene lighting.

Output GLBs go to `Scenes/Assets/skyscraper_pack/glb/`.

## Code Conventions

- GDScript with static typing (`:=` or explicit types)
- No comments unless logic is non-obvious
- One script per scene, co-located with the scene file
- All code and documentation in English
