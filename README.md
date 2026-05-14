# Demo — PSX-Style Walking Narrative Game

A retro low-poly game built in Godot 4.6, inspired by PS1/PS2 aesthetics. Core gameplay is first-person exploration and NPC dialogue.

## Requirements

- Godot 4.6 (Forward+)
- No additional plugins required

## Getting Started

1. Clone or download the project
2. Open `project.godot` in Godot 4.6
3. Verify `Project → Project Settings → Shader Globals` contains `precision_multiplier` (Float, value `0.5`)
   - Add it manually if missing, otherwise shaders will throw errors
4. Run the Main scene

## Project Structure

```
demo/
├── Scenes/
│   ├── Player/           # Player scene, controller, cigarette system
│   └── Assets/Player/    # Cig.glb, cigs_carton.glb
├── shaders/              # PSX-style shaders — do not modify
└── project.godot
```

## Implemented

- First-person mouse look (mouse captured on start, Esc to release)
- WASD movement relative to facing direction
- PSX post-processing (320×240 render resolution + dithering)
- **Night urban atmosphere** — millennium-era city night feel:
  - Deep blue-black sky with warm horizon glow (city light pollution)
  - Low-energy cool blue moonlight with shadows
  - Subtle blue-grey fog (urban haze)
  - Boosted glow for streetlight bloom effect
  - Street lamp posts with sodium-orange OmniLight3D (warm, no shadow)
- **Cigarette system** — full interaction loop with state machine:
  - F to pull out / put away carton (slides up/down with eased tween)
  - Left click to open carton lid (plays GLB animation)
  - Left click again to take a cigarette (carton slides away, cigarette slides in)
  - Hold left mouse to smoke; release to pause
  - Cigarette burns through 3 mesh stages over 15 s, then auto-reloads
  - Smoke + ember GPU particles, world-scale compensated for node scale
  - Movement speed halved while actively smoking

## Scene Conventions

- Each scene gets its own folder under `Scenes/`, e.g. `Scenes/Town/`
- Keep the scene file and its script in the same directory

## Applying PSX Shaders to Meshes

1. Select a `MeshInstance3D` → Material → create a `ShaderMaterial`
2. Set Shader to `shaders/psx_lit.gdshader` (lit) or `psx_unlit.gdshader` (unlit)
3. For any textures used: set Filter to **Nearest** and disable **Mipmaps**

## Input Actions

| Action | Key | Note |
|--------|-----|------|
| `Fowared` | W | Typo is intentional — matches the code, do not rename |
| `Back` | S | |
| `Left` | A | |
| `Right` | D | |
| `Smoke` | F | Pull out / put away cigarette carton |
| Left mouse (hold) | LMB | Smoke while in smoking state |

> Full design documentation (GDD) coming soon.
