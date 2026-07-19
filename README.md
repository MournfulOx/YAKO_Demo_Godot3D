# YAKO / 夜行 — PSX-Style Walking Narrative Game

A short first-person walking game set on a midnight city street. PSX-era low-poly aesthetic, Godot 4.6.

> Taylor's Mental Wellness Campaign — October 2026 (GDD v0.7 on file, held outside the repo)

## Requirements

- Godot 4.6 (Forward+, Direct3D 12 on Windows, Jolt Physics)
- No additional plugins required

## Getting Started

1. Clone or download the project
2. Open `project.godot` in Godot 4.6
3. Verify `Project → Project Settings → Shader Globals` contains `precision_multiplier` (Float, value `0.5`)
   — add it manually if missing, otherwise shaders will throw errors
4. Run the project — it starts at the Main Menu (`Scenes/UI/MainMenu.tscn`), not a map directly

## Project Structure

```
├── autoload/
│   ├── BackroomState.gd       # has the Map_03 "Backrooms" easter egg been entered (single bool)
│   ├── Localization.gd        # registers Chinese/Japanese Translations; English text is the key
│   ├── SceneManager.gd        # fade transition + location name display (layer=20)
│   ├── SettingsState.gd       # master volume + language, persisted to user://settings.cfg
│   └── YellowDuckState.gd     # which of the 5 Yellow Duck collectible fragments are found
├── Scenes/
│   ├── scene_trigger.gd       # reusable map transition trigger (Area3D)
│   ├── gated_scene_trigger.gd # scene_trigger.gd variant locked behind an NPC conversation
│   ├── backroom_entry_trigger.gd  # one-shot scene_trigger.gd variant (Map_03 → Backroom egg)
│   ├── Player/                # CharacterBody3D, cigarette state machine, pause menu hookup
│   ├── Maps/                  # Map_01–03 + the Backroom easter-egg pocket space
│   ├── NPC/                   # npc_base.gd + all 21 GDD-roster NPCs, Crab (replaces Koala),
│   │                          # 3 bonus NPCs, and the Backroom's Caveman
│   ├── Duck/                  # duck_dialogue_ui.gd — reused by Yellow Duck collectibles;
│   │                          # the original Duck companion NPC itself has been cut
│   ├── Collectibles/           # yellow_duck_collectible.gd/.tscn, pickup toast, teleporter
│   ├── Television/             # Television ending-trigger prop (reuses npc_base.gd)
│   ├── Ending/                 # ending_sequence.gd + title/credits card
│   ├── UI/                     # MainMenu, OpeningQuote, pause menu, Settings menu,
│   │                          # dialogue_ui.gd — all CanvasLayers built in code
│   ├── Fonts/                  # pixel.ttf (English, no CJK glyphs) +
│   │                          # ark-pixel-16px-proportional-{zh_cn,ja}.ttf
│   └── Assets/
│       ├── Cigarette/         # Cig.glb, cigs_carton.glb
│       ├── LampPost/          # LampPost.tscn prefab (mesh + light bundled)
│       ├── MiscAssets/animal/ # every NPC's source GLB
│       └── SkyscraperPack/glb/   # background buildings with emission baked in
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
  - **Turns to face the player** while talking, then turns back when the conversation ends
    (`face_player_on_interact`, `face_offset_deg` — most downloaded models need a 180° offset
    from Godot's -Z convention; per-NPC override if a specific model still turns sideways)
  - `wobble_amount`, `light_energy`, `light_color`, `voice_pitch` all exposed as `@export`
- **Typewriter dialogue** — timer-driven character reveal; LMB skips to end, then advances
- **Procedural NPC voices** — `AudioStreamGenerator` square wave blips (520 Hz base); pitch varies per character + per NPC via `voice_pitch`; no audio files required
- **`Scenes/UI/dialogue_ui.gd`** — bottom-centre subtitle CanvasLayer, created in code
- **Player raycast** — 2 m ray from camera centre; outline + interaction at ≤ 1.5 m
- If cigarette is active when interacting with NPC, it is forcibly put away first
- **All 21 GDD-roster NPCs are built** (Convenience Store, Crossroads, Under the Overpass, and
  Arcade Alley's roster, though Arcade Alley's map doesn't exist yet), plus Crab (a stand-in for
  Koala, no model ever sourced for Koala), 3 bonus NPCs from otherwise-unused downloaded models
  (Chicken, Penguin, Grey Alien), and a one-off Caveman for the Backroom easter egg. **Placement
  into the actual maps is separate, ongoing level-design work** — a built NPC prefab existing
  under `Scenes/NPC/` doesn't mean it's been dragged into a map yet. `NPC_Otter`/`NPC_Raccoon`/
  `NPC_Sheep`/`NPC_Fish` currently use a placeholder magenta capsule body — no matching source
  model has been found for these four.

### Television / Ending System
- `Scenes/Television/television.gd` — a wall-mounted "TV" prop that reuses the standard NPC
  interaction pipeline (raycast, outline, subtitle dialogue) rather than a bespoke interactable.
  Spreads the source GLB's 4 colour variants into a 2×2 wall (a *Serial Experiments Lain* nod);
  screens can show constant static, no static, or an intermittent static "glitch" flicker
- Emits `ending_triggered` once its dialogue is fully dismissed; `Scenes/Ending/ending_sequence.gd`
  listens for that and plays the cut-to-black title/credits card (`ending_title_ui.gd`)
- If the player has found all 5 Yellow Duck fragments before reaching it, the Television swaps to
  an alternate "secret" dialogue instead of its normal lines
- Testable standalone before the real rooftop map exists via `Scenes/Television/television_test.tscn`

### Yellow Duck Collectibles
- 5 hidden fragments (one per map, plus one in the Map_03 "Backrooms" easter egg) that used to be
  a separate "Duck companion" NPC system — that system has been cut; these collectibles carry the
  role instead. Walking near one auto-plays a short line (typewriter, no click needed), then it's
  marked collected and vanishes with a small scale/float/light-flash tween
- `Scenes/Collectibles/backroom_teleporter.gd` — generic same-scene teleporter for hidden pockets
  of space (used by the Backrooms egg)
- The Map_03 Backrooms egg is entered via a one-shot trigger (`backroom_entry_trigger.gd`, only
  works once per play session) and exited via a conversation-gated trigger
  (`gated_scene_trigger.gd`, locked until the Caveman NPC's dialogue is finished)

### Main Menu / Opening Quote / Pause Menu
- **Main Menu** — a live, real-time-rendered 3D shot of the Television (not a static image), per
  the GDD's "real-time rendered street scene" spec. Start / Settings / Quit
- **Opening Quote** — Psalm 102:6-7 on a black screen (Death Stranding-style), full text at once
  (not typewriter), no skip input, then fades into Map_01
- **Pause Menu** (Esc) — Resume / Settings / Main Menu / Quit; pauses the scene tree while open

### Settings & Localization
- Master volume slider (linear→dB onto the `"Master"` audio bus) and a 3-way language toggle
  (English / 中文 / 日本語), both persisted to `user://settings.cfg`
- English source text doubles as the translation key for `tr()` lookups — no NPC scene needed
  editing to support this, only the display layer wraps text in `tr()`
- Each language uses its own font file (`pixel.ttf` for English, a dedicated Ark Pixel font per
  CJK language) rather than a shared font with fallbacks, since Chinese and Japanese can render
  the same Han character with different region-specific glyph shapes

### Player Feel
- **Head bob** — subtle camera oscillation while moving (`BOB_SPEED=1.3`, `BOB_AMP_Y=0.008`, `BOB_AMP_X=0.004`)
- **Footstep audio** — procedural: sine tone (55–95 Hz, pitch scales with speed) + white noise mix, −18 dB; cadence slows when smoking

### Maps & Scene Transitions
- **Map 01 — 便利店 Convenience Store**, **Map 02 — 十字路口 Crossroads**, **Map 03 — 高架下
  Under the Overpass** — all built and connected both directions (01↔02↔03); Map_04 (Arcade
  Alley) and Map_05 (School Rooftop) don't exist yet, so Map_03 has no "continue forward" exit
- **Map_03 Backroom** — a hidden pocket-space easter egg, reachable from a trigger in Map_03
- **Scene transition system** — `scene_trigger.gd` on any `Area3D`; set `target_scene` in Inspector
- **Loading screen + location name** — `SceneManager` autoload fades to black, displays the map
  name (parsed from filename, translated per the active language), then fades in; name stays
  visible 1.8 s after arrival. Only shown for real map transitions, not menu/UI scene changes

### UI & Font
- English UI/dialogue text uses `Scenes/Fonts/pixel.ttf`; Chinese/Japanese use their own Ark
  Pixel font files (see Settings & Localization above) — routed through
  `SettingsState.get_active_font()`/`get_active_font_size()` rather than hardcoded per script

## Adding a New NPC to a Map

1. Open the relevant NPC scene from `Scenes/NPC/` (dialogue is pre-filled)
2. Add two child nodes under the `StaticBody3D`:
   - The animal GLB model
   - `CollisionShape3D` with a `BoxShape3D` or `CapsuleShape3D` sized to the model
3. Save, then **Instance** the scene into the map
4. Adjust `light_energy` / `wobble_amount` / `face_offset_deg` in Inspector if needed per location

## Shader Reference

| File | Purpose |
|---|---|
| `psx_lit.gdshader` | Standard PSX lit mesh |
| `psx_unlit.gdshader` | Unlit / self-emissive mesh |
| `psx_lit_npc.gdshader` | NPC mesh — PSX lit + per-vertex wobble (`#define NPC_WOBBLE`) |
| `npc_outline.gdshader` | White outline (applied as `next_pass` when NPC is focused) |
| `sky_stars.gdshader` | Procedural pixel star sky (`shader_type sky`) |
| `tv_screen_static.gdshader` | TV screen static/glitch noise (`shader_type spatial`) |
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
| `Smoke` | F | Pull out / put away cigarette carton (disabled during NPC dialogue) |
| LMB (press) | Left Mouse | Open NPC dialogue / advance line / open carton / take cigarette |
| LMB (hold) | Left Mouse | Smoke while in SMOKING state |
| Esc | Escape | Open/close the pause menu |

> GDD v0.7 on file (held outside the repo). See `CLAUDE.md` for full implementation notes,
> known gaps, and design-decision history.
