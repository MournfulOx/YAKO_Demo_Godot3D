# YAKO / 夜行 — PSX-Style Walking Narrative Game

A short first-person walking game set on a midnight Japanese city street. PSX-era low-poly aesthetic, Godot 4.6.

> Taylor's Mental Wellness Campaign — October 2026

## Requirements

- Godot 4.6 (Forward+, Direct3D 12 on Windows)
- No additional plugins required

## Getting Started

1. Clone or download the project
2. Open `project.godot` in Godot 4.6
3. Verify `Project → Project Settings → Shader Globals` contains `precision_multiplier` (Float, value `0.5`)
   — add it manually if missing, otherwise shaders will throw errors
4. Run the Main scene

## Project Structure

```
├── autoload/
│   ├── DuckState.gd           # cross-scene singleton: Duck encounter state
│   └── SceneManager.gd        # fade transition + location name display (layer=20)
├── Scenes/
│   ├── scene_trigger.gd       # reusable map transition trigger (Area3D)
│   ├── Player/                # CharacterBody3D, cigarette state machine
│   ├── Maps/                  # Map_01 – Map_03 scenes
│   ├── Duck/                  # duck.gd, duck_dialogue_ui.gd, duck_trigger.gd
│   ├── NPC/                   # npc_base.gd + 8 pre-configured NPC scenes
│   ├── UI/                    # dialogue_ui.gd (CanvasLayer, created in code)
│   ├── Fonts/                 # pixel.ttf — pixel bitmap font
│   └── Assets/
│       ├── Player/            # Cig.glb, cigs_carton.glb
│       ├── LampPost/          # LampPost.tscn prefab (mesh + light bundled)
│       └── skyscraper_pack/glb/   # background buildings with emission baked in
├── shaders/                   # PSX pipeline — see Shader Reference below
├── tools/
│   └── fbx_to_glb_with_texture.py   # Blender batch FBX→GLB converter
└── project.godot
```

## Implemented

### Core
- First-person mouse look + WASD movement relative to facing direction
- PSX post-processing pipeline — 320×240 render resolution, dithering, vertex snap
- **Night urban atmosphere** — deep blue-black sky, warm sodium-orange lamp bloom, blue-grey fog
- **Pixel star sky** — procedural star field via `sky_stars.gdshader` (density, brightness, twinkle all tunable)

### Cigarette System
Full interaction loop with state machine (F → open carton → left click → smoke → burns out → auto-reload):
- Hold LMB to smoke; release to pause
- 3 burn stages over 15 s, GPU particle smoke + ember
- Movement speed halved while actively smoking

### NPC Interaction System
- **`npc_base.gd`** — base class for all NPCs (extends `StaticBody3D`):
  - `dialogue_lines` / `repeat_lines` exported — set in Inspector per NPC
  - Souls-style: LMB to open, LMB to advance, repeat line after first completion
  - Auto-applies `psx_lit_npc.gdshader` (PSX vertex snap + per-vertex wobble) to all mesh children
  - White outline on focused NPC via `npc_outline.gdshader` (next_pass on surface material)
  - OmniLight3D auto-attached — makes NPCs visible in dark environments
  - `wobble_amount`, `light_energy`, `light_color`, `voice_pitch` all exposed as `@export`
- **Typewriter dialogue** — timer-driven character reveal (0.045 s/char); LMB skips to end, then advances
- **Procedural NPC voices** — `AudioStreamGenerator` square wave blips (520 Hz base); pitch varies per character + per NPC via `voice_pitch`; no audio files required
- **`Scenes/UI/dialogue_ui.gd`** — bottom-centre subtitle CanvasLayer, created in code
- **Player raycast** — 2 m ray from camera centre; outline + interaction at ≤ 1.5 m
- If cigarette is active when interacting with NPC, it is forcibly put away first
- **8 NPC scenes** pre-configured with GDD dialogue (`Scenes/NPC/`):

  | Scene | Character | Map | Voice Pitch |
  |---|---|---|---|
  | `NPC_Cat.tscn` | Cat | Map 01 — Convenience Store | 1.35 |
  | `NPC_Cow.tscn` | Capybara | Map 02 — Crossroads | 0.72 |
  | `NPC_Penguin.tscn` | Goat | Map 02 — Crossroads | 1.15 |
  | `NPC_Otter.tscn` | Otter | Map 03 — Under the Overpass | 0.88 |
  | `NPC_Raccoon.tscn` | Raccoon | Map 04 — Arcade Alley | 1.10 |
  | `NPC_Fish.tscn` | Fish | Map 04 — Arcade Alley | 0.82 |
  | `NPC_Dog.tscn` | Dog | Map 04 — Arcade Alley | 0.95 |
  | `NPC_Sheep.tscn` | Sheep | Map 05 — School Rooftop | 0.78 |

### Duck Companion
- One-shot encounter per map; rubber duck NPC with warm self-illumination (`OmniLight3D`, 2.8 energy)
- Plays map-specific dialogue via typewriter, then `queue_free()`s — does not follow the player
- Duck voice: 400 Hz square wave blip, fixed pitch (distinct from NPC voices)
- `DuckState` autoload tracks which maps have triggered the encounter across scene loads
- Place `duck_trigger.gd` on an `Area3D` near the duck model; fires once per scene load

### Player Feel
- **Head bob** — subtle camera oscillation while moving (`BOB_SPEED=1.3`, `BOB_AMP_Y=0.008`, `BOB_AMP_X=0.004`)
- **Footstep audio** — procedural: sine tone (55–95 Hz, pitch scales with speed) + white noise mix, −18 dB; cadence slows when smoking

### Maps & Scene Transitions
- **Map 01 — 便利店 Convenience Store** — night atmosphere, sidewalk, player spawn, skyscraper background
- **Map 02 — 交差点 Crossroads** — in progress
- **Map 03 — 高架下 Under the Overpass** — in progress
- **Scene transition system** — `scene_trigger.gd` on any `Area3D`; set `target_scene` in Inspector
- **Loading screen + location name** — `SceneManager` autoload fades to black, displays the map name (parsed from filename), then fades in; name stays visible 1.8 s after arrival

### UI & Font
- All in-game text uses `Scenes/Fonts/pixel.ttf` — pixel bitmap font, size 6
- Dialogue, Duck lines, and the scene name display all share the same font stack

## Adding a New NPC to a Map

1. Open the relevant NPC scene from `Scenes/NPC/` (dialogue is pre-filled)
2. Add two child nodes under the `StaticBody3D`:
   - The animal GLB model
   - `CollisionShape3D` with a `BoxShape3D` or `CapsuleShape3D` sized to the model
3. Save, then **Instance** the scene into the map
4. Adjust `light_energy` / `wobble_amount` in Inspector if needed per location

## Shader Reference

| File | Purpose |
|---|---|
| `psx_lit.gdshader` | Standard PSX lit mesh |
| `psx_unlit.gdshader` | Unlit / self-emissive mesh |
| `psx_lit_npc.gdshader` | NPC mesh — PSX lit + per-vertex wobble (`#define NPC_WOBBLE`) |
| `npc_outline.gdshader` | White outline (applied as `next_pass` when NPC is focused) |
| `sky_stars.gdshader` | Procedural pixel star sky (`shader_type sky`) |
| `pp_band-dither.gdshader` | Fullscreen dither post-process |
| `psx_base.gdshaderinc` | Shared include — vertex snap + wobble logic |

Applying PSX shaders to environment meshes:
1. `MeshInstance3D` → Material → new `ShaderMaterial` → `psx_lit.gdshader`
2. Set any textures to Filter: **Nearest**, Mipmaps: **off**

## Input Actions

| Action | Key | Note |
|---|---|---|
| `Fowared` | W | Typo is intentional — matches code exactly, do not rename |
| `Back` | S | |
| `Left` | A | |
| `Right` | D | |
| `Smoke` | F | Pull out / put away cigarette carton |
| LMB (press) | Left Mouse | Open NPC dialogue / advance line / open carton / take cigarette |
| LMB (hold) | Left Mouse | Smoke while in SMOKING state |

> GDD v0.6 on file. Updated GDD coming after current sprint.
