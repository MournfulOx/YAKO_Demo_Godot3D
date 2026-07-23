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
│   │   ├── NPC_Toucan.tscn            # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Octopus.tscn           # for Map 04 (map doesn't exist yet), fragment carrier [F]
│   │   ├── NPC_TRex.tscn              # for Map 04 (map doesn't exist yet)
│   │   ├── NPC_Crab.tscn              # for Map 04 (map doesn't exist yet), fragment carrier [F] — replaces Koala
│   │   ├── NPC_Caveman.tscn           # Map_03 Backrooms egg, one-off, not in the GDD roster
│   │   ├── NPC_Penguin.tscn           # bonus, not in GDD roster — from a leftover unused model
│   │   ├── NPC_Pig.tscn               # bonus, not in GDD roster — freshly imported model, placed in Map_04
│   │   ├── NPC_GreyAlien.tscn         # bonus, not in GDD roster — from a leftover unused model
│   │   └── NPC_Capybara.tscn          # legacy — not in GDD v0.7's 21-NPC roster, currently unused
│   │   # All 21 GDD roster slots now have a prefab. Koala[F] was swapped for Crab per direct
│   │   # request (same fragment dialogue, no model ever sourced for Koala) — don't reintroduce
│   │   # a Koala NPC without checking first.
│   │   # IMPORTANT: "for Map NN" above means the prefab exists and is ready to drag in —
│   │   # as of this writing NONE of these NPCs (old or new) have actually been placed into
│   │   # any map scene yet. Placement is unstarted level-design work for every single one.
│   │   # STILL UNRESOLVED: NPC_Otter/NPC_Raccoon/NPC_Sheep have no real model. Checked
│   │   # C:\Users\furik\Downloads\Models and every asset folder in the project — no otter,
│   │   # raccoon, or sheep model exists anywhere accessible. `NPC_Fish` had the same problem but
│   │   # was deleted outright per direct request rather than left as a placeholder — see the
│   │   # Map_04 bonus-NPC note under `## NPC System` below. Each of the three remaining ones has a
│   │   # bright-magenta CapsuleMesh/CapsuleShape3D placeholder `Body` (radius 0.2, height 0.8)
│   │   # instead of nothing, though — the earlier state (no `Body`, no CollisionShape3D at all)
│   │   # meant they'd be invisible AND un-clickable if dragged into a map, silently broken with
│   │   # no error. Magenta is the deliberate "missing asset" convention so nobody mistakes the
│   │   # capsule for a finished look. Swap the mesh/material for a real model when one's found;
│   │   # no other changes needed elsewhere since npc_base.gd just re-shades whatever's there.
│   │   # Bonus NPCs (Penguin/Pig/GreyAlien) use placeholder dialogue I wrote myself, not
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
- Ambient: Color source, cool blue `(0.08, 0.1, 0.2)`, energy `0.4` (raised from `0.18` — see note below)
- Moonlight (DirectionalLight3D): `Color(0.7, 0.78, 1.0)`, energy `0.3` (raised from `0.12`), shadows on
- Fog: enabled, blue-grey `(0.07, 0.08, 0.14)`, density `0.014` on Map_01 — **`0.0015` on Map_02–05**
  (see note below; the two densities are deliberately different, not a drift/inconsistency)
- Glow: intensity `1.4`, bloom `0.25`, HDR threshold `0.75` (low threshold so lamp orange triggers bloom)
- LampPost lights: `OmniLight3D` child at local `Y=0.085` — sodium orange `(1.0, 0.62, 0.18)`, energy `3.5`, range `10`, no shadow

**LampPost prefab:** `Scenes/Assets/LampPost/LampPost.tscn` — Node3D root with Mesh + LampLight (OmniLight3D). Instancing this prefab in any map auto-includes the light with correct parameters.

**Unified across all 5 maps**: Map_02–05 originally shipped (from Zee's map imports) with a plain
`ProceduralSkyMaterial` sky (no stars) and no `MoonLight` node at all — only Map_01 had the full
night atmosphere. Both gaps were closed by copying Map_01's setup exactly: each map's `Sky`
sub-resource now points at a `ShaderMaterial` using `sky_stars.gdshader` with the same
`shader_parameter/*` values as Map_01 (not each map's own slightly-different `ProceduralSkyMaterial`
top/horizon colours — deliberately replaced outright for a single consistent sky across the game),
and each map gained its own `MoonLight` (`DirectionalLight3D`) node with identical
transform/color/energy/`shadow_enabled` to Map_01's. Ambient/fog/glow `Environment` properties were
already identical across all 5 maps before this pass (Zee had already matched those), so only the
sky material and the missing directional light needed touching.

**Map_02 building lights (first pass)**: after the sky/moonlight fix, Map_02 still read as very
dark — traced to Zee having wired up a `Light` node (with 2-3 `LampLight`/`LampLight2`/`LampLight3`
`OmniLight3D` children, sodium orange `Color(1, 0.62, 0.18)`, `light_energy = 3.5`) on only 3 of
its ~33 buildings (`Commercial/04`, `Commercial/27`, `Commercial/05` — two more, `Commercial/03`
and `Commercial/06`, had an empty placeholder `Light` node with no light children at all). Every
other building had zero point-light source, leaving most of the map lit by moonlight/ambient
alone (deliberately very dim by design). Completed the pattern on the remaining 31 buildings
(23 Commercial + 8 Station) by adding one `StreetLamp` `OmniLight3D` directly as a child of each
building's own instance node, using **local position `(0,0,0)`** (an identity `Transform3D`,
i.e. no `transform` line at all) rather than copying Zee's small hand-tuned offsets — those
offsets are only safe on the specific building scale/model they were tuned against, since this
city's building instances carry huge, wildly-varying scale factors (roughly 40–900×) baked into
their own transform; a zero local position is scale-invariant (`0 × anything = 0`) and so is the
one offset guaranteed not to end up floating in a wall or the sky regardless of the parent's
scale. Color/energy/`omni_range` (`598.71625`, matching Zee's own already-placed lights rather
than Map_01's much smaller `range = 10` LampPost convention — this city's buildings sit hundreds
of units apart, so a small range would be pointless here) were copied verbatim from Zee's
existing lights as the only real precedent for "what looks right at this coordinate scale."
**Not visually confirmed** — same standing caveat as every other placeholder placement in this
project: open Map_02 in the editor and check whether `598.71625` reads as too broad/blown-out
now that ~30 buildings each cast one, and tune down if so. Map_03/04/05 have not had this same
per-building lamp pass yet.

**City-glow pass (80s city-pop look)**: even after the ambient/moonlight bump, Zee's skyscraper/
building GLBs (`Scenes/Assets/Zee/all_buildings/...`) still read as flat dark silhouettes —
their `StandardMaterial3D`s carry an albedo texture (often already painted with warm lit-window
detail, e.g. `japan_house_restaurant_by_night..glb`) but never had `emission_enabled` set, so
none of that texture actually glows; it just sits there unlit like every other surface. Fixed
with a small reusable runtime script, **`Scenes/city_glow.gd`** (plain `Node`, not `Node3D`),
following the same "duplicate-and-override at `_ready()`" idiom already used by `npc_base.gd`/
`television.gd` rather than touching the imported `.glb`s or their `.import` files directly
(equivalent in spirit to `tools/fbx_to_glb_with_texture.py`'s existing "bake texture as both
albedo and emission" trick for `SkyscraperPack`, just applied at runtime instead of at import
time, since reimporting isn't something this environment can trigger). `@export var
target_paths: Array[NodePath]` lists the building-container node(s) to walk (scoped narrowly —
deliberately not the whole map — to avoid accidentally lighting up roads/sidewalks/fences too);
`@export var emission_energy: float = 1.5` matches the value the project's own
`fbx_to_glb_with_texture.py` already uses for the same effect. `_apply_glow()` recurses from
each target, and for every `MeshInstance3D` surface whose material is a `StandardMaterial3D`
with an `albedo_texture` and `emission_enabled == false`, duplicates that material (so the glow
doesn't leak onto every other instance sharing the same imported mesh resource) and sets
`emission_texture = albedo_texture` at the configured energy. Instanced as a `CityGlow` node
(`parent="."`) in Map_02/03/04/05 (Map_01 has no Zee buildings, so skipped), each with its own
`target_paths` since every map's building container ended up named differently by Zee — Map_02:
`Map 02/Asset New/Building`; Map_03: `buildings` + `commercial_buildings`; Map_04:
`Assets/Buildings` + `school` + `school_walls`; Map_05: `assets/school` + `assets/store`.
**Reported as still not visibly working** after the first pass — root cause: the type check was
`mat is StandardMaterial3D`, but glTF/Sketchfab imports very commonly land as `ORMMaterial3D`
(Godot's variant for models with a packed occlusion/roughness/metallic map) — a **sibling** of
`StandardMaterial3D` under `BaseMaterial3D`, not a subclass of it, so `is StandardMaterial3D`
silently failed to match most of these buildings' materials and the glow code never ran on them
at all. Fixed by checking/duplicating as `BaseMaterial3D` instead (both classes expose the same
`albedo_texture`/`emission_enabled`/`emission_texture`/`emission_energy_multiplier` properties,
so the rest of the logic is unchanged). Also bumped the default `emission_energy` `1.5 → 3.5`
(matching this project's own already-established "clearly visible light source" value, e.g. the
street lamps' `light_energy = 3.5`) so the glow reads as unmistakable rather than subtle once it
actually applies. **Still not visually confirmed** — same standing caveat, open each map and
check the effect now actually shows up on the buildings, and tune each `CityGlow` node's own
`emission_energy` export if still too dim or blown out.

**Fog was hiding the glow on anything not close by**: user correctly diagnosed that even a
correctly-glowing building would vanish at a distance because `fog_density = 0.014` (copied
unchanged from Map_01 during the earlier "unify across all 5 maps" pass) is tuned for Map_01's
much smaller SevenEleven-store scale. Godot's exponential depth fog is roughly `1 - exp(-density
* distance)`; at `0.014`, fog reaches ~95% opacity by ~215 units — but Zee's city places
buildings hundreds of units apart (the `omni_range = 598.71625` Zee used on their own working
lights is a good proxy for the scale this content was actually built at), so most of Map_02–05
was already fully fogged out well before reaching most buildings, regardless of how bright their
emission is. Fixed by dropping `fog_density` on **Map_02/03/04/05 only** — Map_01 keeps its original `0.014`,
since that value is correct for its own (much smaller) scale and was never the problem. First
attempt went to `0.0015`, which fixed distant visibility but then reportedly felt like the fog had
disappeared entirely — reasonable, since at that density even a 100-unit close-up view is barely
~14% fogged, losing the hazy/misty look the night atmosphere depends on. Went to `0.003` next (~26%/59%/83%/95% at 100/300/600/1000 units) — still reported too light, then
`0.0045` (~36%/74%/93%/99%) — still not foggy enough; the user's actual goal turned out to be
stronger than "some haze": **regular geometry should become hard to see within a fairly short
distance, while distant *lit* buildings should still be dimly, hazily perceptible** — i.e. the
classic heavy-fog look where only bright light sources punch through. Currently **`0.008`**:
~55% by 100 units, ~80% by 200, ~96% by 400, ~99.2% by 600 — unlit geometry is genuinely hard to
read past a couple hundred units, which is the point. For a light source to still read as a hazy
glow at 600+ units despite only ~0.8% of its color surviving that blend, it has to be *far*
brighter than a normal surface to begin with — so `city_glow.gd`'s default `emission_energy` was
also raised **`3.5 → 10.0`** alongside this fog increase (comfortably over the `glow_hdr_threshold
= 0.75` bloom cutoff even after heavy fog attenuation, so bloom can still pick it up and let it
visibly bleed through the haze). The fog number alone was never going to produce "dark fog +
glowing windows" — that look needs the emissive buildings to be disproportionately bright
*relative to* the fog, not just the fog itself tuned differently. **Not visually confirmed** —
same standing caveat as everything else in this pass; reasoned from Godot's exponential depth-fog
falloff (`1 - exp(-density * distance)`) and how HDR bloom interacts with fog-attenuated
brightness, not measured in the editor.

**Recurring gotcha while tuning this**: `Scenes/Maps/Map_03_UnderTheOverPass.tscn` reverted an
external `fog_density` edit back to a stale value partway through this back-and-forth — almost
certainly the documented "editor has the scene open, its next save clobbers external edits"
pitfall (see the note under `## Scene Transition System` below) rather than anything wrong with
the edit itself. If a map's value doesn't seem to be taking effect in-editor, check whether that
scene tab is open and close it before any further external edits.

**Still reported too dark after the above** — most likely because these per-building lights
are children of each building's own instance node, and this city's building models carry wildly
inconsistent scale factors (~40×–900×, several also pre-rotated 90° from FBX import) with a
pivot origin that doesn't reliably sit near the model's street-facing exterior — confirmed
indirectly by the fact that Zee's own 3 working lights needed hand-tuned local offsets rather
than sitting at each building's raw origin. A `(0,0,0)`-local light is scale/rotation-safe
positionally, but if the model's origin happens to fall inside its own solid mesh, the light is
simply occluded and invisible regardless. Diagnosing/repositioning each of the 31 lights would
need per-building visual inspection in the editor, which isn't available here, so per user's
choice the fix instead went broad rather than per-building: `ambient_light_energy` raised
`0.18 → 0.4` and `MoonLight`'s `light_energy` raised `0.12 → 0.3`, applied identically across all
5 maps (kept unified rather than only brightening Map_02) — see the `## Night Atmosphere` section
above for the current values. The 31 per-building `StreetLamp` nodes from the first pass are left
in place (harmless even if several are currently occluded) rather than reverted; revisit their
placement once someone can eyeball each building in the editor.

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
| 04 Arcade Alley | Raccoon, Toucan, Octopus [F], Crab [F] (map scene doesn't exist yet); T-Rex placed in Map_03 instead, Fish deleted (no model), see notes below | — |
| 05 School Rooftop | Television (`Scenes/Television/television.tscn`, ending trigger built as an NPC-style interactable) | — |

All 21 GDD roster slots now have a built `.tscn` prefab — Koala was swapped for **Crab**
(`Scenes/Assets/MiscAssets/low-poly_crab.glb`, already sitting unused in the project) per
direct request, keeping Koala's exact fragment dialogue unchanged (the lines were never
Koala-specific to begin with). Models sourced from `C:\Users\furik\Downloads\Models` plus
whatever unused assets were already sitting in `Scenes/Assets/MiscAssets/`, copied/kept under
`Scenes/Assets/MiscAssets/animal/`. **None of them — old or new — have actually been placed
into a map scene yet**; "built" here only means the prefab exists and is ready to drag in.
`ps1_chicken.glb` was briefly used for a bonus `NPC_Chicken.tscn`, but both the prefab and the
source model have since been deleted outright per direct request (see the Map_04 bonus-NPC note
below) — there is no chicken NPC in the game anymore.

Placement (position/rotation, avoiding overlap with
level geometry, picking a spot that reads well) is unstarted level-design work for every single
one, left to the person doing map layout since it needs visual judgement in the editor.
`dialogue_lines`/`repeat_lines` content for all of them is pulled directly from the GDD, not
invented — except `NPC_Caveman` (Backrooms egg, not in the GDD roster), which is placeholder text.

**Map_01/02/03 roster placed (Map_04 deliberately skipped, per direct request)**: all 15 of
Map_01–03's NPCs (`Cat`/`Sheep`/`PrairieDog`/`Rat`; `Goat`/`FrenchBulldog`/`KoiFish`/`Baboon`/
`Goose`/`GreatWhiteShark`; `Otter`/`Dog`/`Giraffe`/`Deer`) are now instanced directly into their
respective map scenes, scattered in a simple ring around each map's own `Player` spawn
(`~10–25` units out, one per compass-ish direction) purely so each one exists *somewhere*
reachable — **not visually confirmed, not tied to actual level geometry or points of interest**;
this is placeholder-position-only, exactly like every other blind-placement pass this session
(exit triggers, spawn points, `ExitArrow`s) — whoever does the real level-design pass needs to
drag each one to an actual spot that reads well and doesn't clip into a wall/building. Map_04 was
left untouched per the request's own scope (its roster — `Raccoon`/`Fish`/`Toucan`/`Octopus`/
`TRex`/`Crab` — is still fully unplaced).

**`NPC_Panda.tscn` doesn't actually exist** despite being listed above and in the roster table —
checked `Scenes/NPC/`, the file isn't there. This table entry is stale/aspirational; either the
prefab was never actually created despite the note claiming "all 21 slots have a built .tscn," or
it was lost at some point. Map_03 currently ships with only 4 of its 5 documented NPCs as a
result. Needs a fresh prefab built from a giraffe... er, panda model before it can be placed.

**`NPC_TRex` moved from Map_03 to Map_04, then back out of Map_04 again** — it had originally
been sitting in `Map_03_UnderTheOverPass.tscn` (stray/test placement, not this session's doing).
Since T-Rex is Map_04's roster NPC per the table above, it was removed from Map_03 and re-added
to `Map_04_ArcadeAlley.tscn` (same placeholder-ring placement convention as the rest of this
pass, offset from Map_04's own `Player` spawn). It then had to be **re-added a second time** in
Map_04 — a teammate's large "Update Map_04_ArcadeAlley" edit (1000+ lines, unrelated
level-design work) apparently didn't include the first placement, so it silently disappeared
from the file. **Per direct request, T-Rex was then removed from Map_04 again** — the user
placed it in Map_03 themselves by hand instead, so it shouldn't also exist in Map_04. Node
instance + its `ext_resource` (`id="83_trex"`) both removed from `Map_04_ArcadeAlley.tscn`;
verified no dangling references remain. **Current state**: T-Rex lives in Map_03 (placed by the
user directly, not this session's placeholder-ring convention), and Map_04's GDD-roster NPCs are
`Toucan`/`Crab` only (`Fish` was later deleted outright — no model ever existed for it, see the
Map_04 bonus-NPC note below — rather than left unplaced like Otter/Raccoon/Sheep) — one short of
its original 6-NPC GDD table entry, with `Raccoon`/`Octopus` still redirected to Map_02 (direct
request — Map_02's huge Zee-city scale left it
feeling sparse/empty relative to its size even with its own 6-NPC roster already placed),
positioned far from the existing Map_02 cluster (~300 units out in two different directions) to
actually help fill out the space rather than adding to the same corner. Their dialogue isn't
location-specific, so the mismatch with the GDD's Map_04/Map_02 assignment doesn't read as wrong.

**Map_04 bonus NPCs (originally Chicken/Penguin/Pig, direct request)**: user newly imported
three models — `low_poly_penguin.glb`, `ps1_pig.glb`, `ps1_chicken.glb` — into
`Scenes/Assets/MiscAssets/animal/`. `NPC_Chicken.tscn`/`NPC_Penguin.tscn` already existed as
prefabs (see roster table note above) but had never actually been placed anywhere; built a new
`NPC_Pig.tscn` prefab from `ps1_pig.glb` (same `npc_base.gd` pattern as every other NPC — no
model existed for a pig before now, this is a first). Pig's raw mesh bounding box (parsed
directly from the GLB's glTF JSON, same technique used for the Television model) is
`~2.19 × 3.34 × 6.51` — scaled `0.2x` in `Body`'s transform to land around real-world pig
proportions (~0.44m × 0.67m × 1.3m); `CollisionShape3D` is a `BoxShape3D(0.45, 0.7, 1.3)`
approximating that, **not visually confirmed**, same caveat as every other freshly-scaled
import in this project. Dialogue is original placeholder text matching the same plain/wistful
tone already established for Chicken/Penguin's bonus lines — not GDD content, there is none for
a bonus animal.
**`ps1_pig.glb` has no `.import` file yet** (the other two models do) — since this environment
can't run the Godot editor to trigger an import pass, `NPC_Pig.tscn`'s `ext_resource` references
it by path only, same as `NPC_Penguin.tscn` already does for its own glb. Godot will auto-import
it the next time the project is opened in the editor; no action needed unless it doesn't pick it
up automatically, in which case reimport it manually via the FileSystem dock.
All three were initially instanced into `Map_04_ArcadeAlley.tscn` under the existing `NPC`
container node, scattered around `Player`'s spawn point (`-73.77, 2.702, -0.42`) at the same
`~15x` instance-level scale multiplier already used on Map_04's `Toucan`/`Crab` placements (this
map's Zee/school assets are scaled up much more than Map_01–03's, so NPCs need a matching
multiplier to read as the right size). **The user then opened the map in the editor and hand-
tuned `Pig`'s and `Penguin`'s placement themselves** (both now carry real rotation + a more
moderate ~3–5x scale instead of the blind 15x guess) — confirmed by diffing the file before/after
an editor session. `NPC_Chicken` did not survive that same editor session (its `ext_resource`
and node both disappeared from Map_04) — and per a follow-up direct request, Chicken was then
**removed from the project entirely** rather than just left out of Map_04: `NPC_Chicken.tscn`
deleted, its source `ps1_chicken.glb`/`.import`/texture files deleted from
`Scenes/Assets/MiscAssets/animal/` (the unrelated `crispy_chicken_bucket_-_ps1_low_poly.glb`
prop in `MiscAssets/small assets/` was left alone — different asset, not part of this cleanup),
and its `ZH_STRINGS`/`JA_STRINGS` translation entries removed from `autoload/Localization.gd`.
Map_04's bonus roster is `Penguin`/`Pig` only; there is no chicken NPC anywhere in the game
anymore.
**Live-editor-clobbering caveat applies here too** (see the recurring note under `## Scene
Transition System`) — an attempt to write both `NPC_Chicken` and the Yellow Duck collectible
into this file in the same pass got silently reverted by the editor's own next save because the
Map_04 tab was still open; the Yellow Duck edit only stuck once the user confirmed the tab was
closed. If an edit to a currently-open map doesn't seem to take, this is the first thing to
check — same standing issue as the Map_01/Map_03 incidents earlier in this project's history.
**`NPC_Fish` found missing from Map_04, then deleted outright per direct request** — while doing
this pass, grep turned up zero references despite CLAUDE.md's own history claiming it had been
added alongside Toucan/Crab (same silent-disappearance pattern as `NPC_TRex`'s two earlier
vanishing acts, most likely subsumed by a teammate's large unrelated map edit). It was briefly
re-added using its existing magenta capsule-placeholder prefab, but per direct request — no real
fish model has ever been sourced for it — it was removed again instead of restored: `NPC_Fish`'s
node instance + `ext_resource` pulled from `Map_04_ArcadeAlley.tscn`, `Scenes/NPC/NPC_Fish.tscn`
deleted outright, and its `ZH_STRINGS`/`JA_STRINGS` translation entries removed from
`autoload/Localization.gd`. Map_04's roster is now Toucan/Crab plus the two remaining bonus
animals (Penguin/Pig, see above for why Chicken didn't make the final cut) — Fish is dropped
from the roster entirely rather than left as an unplaced placeholder, unlike Otter/Raccoon/Sheep
(still magenta-capsule placeholders elsewhere, not
deleted) since those are actual GDD-roster fragment/animal slots that still need a real model,
whereas Fish's own map slot is filled by these three bonus animals now anyway.

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

**Fixed a real bug**: `_transition()` computed `_resolve(path)` only to decide whether to show the
location-name label, then called `get_tree().change_scene_to_file(path)` with the original,
*unresolved* `path` — so a `target_scene` stored as `uid://...` (which `@export_file` picks in
Godot 4.4+'s file browser) could silently fail to load. Reported as "walked through the exit
trigger, scene never changed." Now both the label-name check and the actual scene change use the
same `resolved_path := _resolve(path)`.

## Map_05 Television Never Triggered the Ending

Reported bug: talking to the `Television` in Map_05 never produced the ending (cut to black +
title card). Root cause: `television.gd` only *emits* `ending_triggered` — actually playing the
ending is `Scenes/Ending/ending_sequence.gd`'s job, and that's a **separate node** that has to be
placed in the map and pointed at the Television via `@export var television_path: NodePath`. Since
`Map_05_SchoolRooftop.tscn` never had an `EndingSequence` node at all (confirmed by grep — zero
matches), the signal fired into the void every time. Fixed by adding one (`television_path =
NodePath("../Television")`), matching the exact pattern already used in
`Scenes/Television/television_test.tscn`.

Also explicitly set `show_screen_static = true` / `flicker_screen_static = false` on Map_05's
`Television` instance — these already matched `television.gd`'s own defaults (so functionally
nothing changes), but were made explicit per direct request rather than left implicit, since the
ask was specifically "same look as `television_test.tscn`."

## Map_05 Scale Mismatch (school.glb vs Zee's Commercial/store buildings)

Reported as "player and buildings are out of proportion" — confirmed direction: buildings read as
gigantic, player as tiny. Root cause: `school.glb` (the map's main building) is instanced at
`6.115x`, matching the identical value used for the same asset in Map_04 — clearly a deliberate,
consistent convention for this specific model. But the three `assets/store/*` Commercial-building
instances (the same Zee city pack reused across Map_02–05) were scaled `355x`–`848x` — a ~50–150×
mismatch against the school. This scale gap has existed since Map_02 (every map reuses the same
Commercial building instances at similarly huge multipliers) but was never reported there, likely
because those maps never place `school.glb` alongside them to make the contrast obvious.

Fixed by dividing each `store` instance's scale by 100 (bringing `355x/498x/848x` down to
`~3.55x/4.98x/8.48x`, the same order of magnitude as the school's `6.115x`), touching only the
scale component of each `Transform3D` — position/rotation untouched. Also found and reset two
other nodes that had apparently been scaled *up* as a workaround for the oversized buildings
rather than fixing the buildings themselves: `Player` was at `5x` in this map specifically (every
other map's `Player` is plain `1x`), and `Television` was at `4x` (its own doc note already
states it's pre-scaled to real-world size, `1x`, needing no compensation). Both reset to `1x`.

**Not visually confirmed** — the `÷100` correction factor was inferred from matching order-of-
magnitude with `school.glb`'s already-consistent `6.115x`, not measured against each building's
actual bounding box, so the three store buildings may still need individual fine-tuning once
seen in the editor. **This same `355x`–`848x` scale likely still exists unfixed in Map_02/03/04**
for these building instances — only Map_05 was reported/touched this pass.

**Player still reported too small after the above** — rather than assume `school.glb`'s `6.115x`
was itself the correct reference (it was only ever inferred from "used consistently in two maps,"
not measured), treated this as the same kind of iterative, feedback-driven tuning as the fog-
density pass earlier: halved every building's scale again (school `6.115x → 3.0575x`; the three
store instances proportionally to `~2.49x/1.775x/4.238x`), keeping the ratios already matched
between them. **Not visually confirmed** — same caveat; if still off, the next step is the same
halving move again (or the reverse, if this overshot), not a full re-derivation.

## Scene Transition System

`Scenes/scene_trigger.gd` — attach to any `Area3D` node to create a map exit trigger.

```gdscript
@export_file("*.tscn") var target_scene: String = ""
@export var spawn_id: String = ""
```

- Detects `CharacterBody3D` entering the area via `body_entered`
- If `spawn_id` is set, calls `TravelState.set_pending_spawn(spawn_id)` **before**
  `SceneManager.change_scene(target_scene)` — see `## Reciprocal Spawn Points` below.
  `gated_scene_trigger.gd` has the same `spawn_id` export, applied after its NPC-completion check
  passes.
- Calls `SceneManager.change_scene(target_scene)` — do NOT use `call_deferred(change_scene_to_file, …)` directly
- Set **Target Scene** in Inspector to the destination `.tscn` path
- CollisionShape3D: use a thin BoxShape3D (`Vector3(5, 3, 0.5)`) spanning the exit edge
- Collision Layer = 0 (none), Mask = Layer 1 (Player)

## Reciprocal Spawn Points

Direct request, fixing a real bug: previously every map's `Player` node had one fixed authored
position, so leaving Map_02 → Map_03 and immediately walking back into Map_02 always dropped the
player at Map_02's single default spawn — not anywhere near the doorway they'd just walked back
through. Fixed with a small three-piece system rather than special-casing it per map:

- **`autoload/TravelState.gd`** (new autoload) — a single `pending_spawn_id: String`.
  `set_pending_spawn(id)` / `consume_pending_spawn()` (returns the id and clears it — read-once,
  so a later ordinary scene load with no pending id behaves exactly as before). Registered in
  `project.godot`'s `[autoload]` list.
- **`scene_trigger.gd`** / **`gated_scene_trigger.gd`** — both gained `@export var spawn_id: String`;
  if set, they call `TravelState.set_pending_spawn(spawn_id)` right before `SceneManager.change_scene()`.
- **`Scenes/spawn_point.gd`** (new, `extends Marker3D`) — `@export var spawn_id: String`; on
  `_ready()`, adds itself to group `"spawn_point"` (skipped entirely if `spawn_id` is empty, so a
  stray unconfigured marker can't silently match anything). Purely a position/rotation reference —
  no visuals, no logic beyond registering itself.
- **`player.gd`** — new `_apply_pending_spawn()`, called via `call_deferred()` at the top of
  `_ready()` (before the cigarette/dialogue/pause-menu setup that already lived there): consumes
  `TravelState.consume_pending_spawn()`; if non-empty, scans `get_tree().get_nodes_in_group("spawn_point")`
  for a matching `spawn_id` and snaps `global_position`/`global_rotation.y` to it (yaw only —
  pitch/roll stay untouched, matching how `npc_base.gd`'s face-player turn also only ever touches
  yaw; reads the marker's *global* rotation rather than its local one, since a `SpawnPoint` sitting
  under a rotated trigger `Area3D` would otherwise report the wrong facing direction). If no
  pending id, or no matching marker is found in the new scene, the player just ends up at whatever
  position was authored on the `Player` node in that scene, i.e. current behavior is unchanged
  when this system isn't used.
  **Must be `call_deferred()`, not a direct call** — reported bug: arriving back at a map always
  landed on the map's plain authored `Player` position, never the matching `SpawnPoint`. Root
  cause is Godot's `_ready()` ordering: it runs bottom-up per branch, but across *siblings* it
  fires in tree order, and `Player` is declared before the exit-trigger `Area3D` (whose child
  `SpawnPoint` only joins the `"spawn_point"` group in its own `_ready()`) in every map file. A
  direct call to `_apply_pending_spawn()` from `Player._ready()` therefore always ran before that
  `SpawnPoint` had registered itself, so the group lookup came up empty every time. Deferring the
  call lets it run after the whole scene's `_ready()` pass finishes, by which point every
  `SpawnPoint` sibling has already joined the group.

**Naming convention**: one `spawn_id` per *connection*, shared by both directions — e.g.
`"Map01_Map02"` is set on both Map_01's exit-to-02 trigger and Map_02's exit-to-01 trigger, and
both maps each get their own `SpawnPoint` marker using that same id (positioned appropriately for
*that* map's side of the doorway). This halves the bookkeeping versus a separate id per direction —
each map only ever needs to define spawn markers for the connections *it itself* has an exit for.

**Placement pattern that survived a live-editing session**: spawn markers are added as a **child
of the trigger `Area3D` itself** (or, when that trigger's own `CollisionShape3D` carries a further
local offset — as `Map_01`'s original `ExitTrigger` does — a child of the `CollisionShape3D`
instead), with a small local position offset along whichever axis the trigger's own `BoxShape3D`
is thinnest on (i.e. the "walk-through" axis) — e.g. `Vector3(0, 0, 2)` when the box's `size.z` is
the small dimension, `Vector3(3, 0, 0)` when `size.x` is. This was deliberately chosen over
computing an absolute world position by hand: this exact session had Map_02's `ExitToMap03` and
Map_03's `ExitToMap02` triggers get **physically repositioned by the user mid-session** (Zee/the
user actively placing these while this system was being built), and a hand-computed world offset
would have gone stale immediately — a locally-offset child re-derives the correct world position
automatically no matter where the parent trigger later moves. This is the same trick already used
for `ExitArrow` (see below) once it got reparented under its trigger instead of living at the map
root with an absolute transform.
**Currently wired**: `"Map01_Map02"` (Map_01 `Area3D` ↔ Map_02 `Map01_Map02`), `"Map02_Map03"`
(Map_02 `Map02_Map03` ↔ Map_03 `ExitToMap02`), `"Map03_Map04"` (Map_03 `Map03_Map04` ↔ Map_04
`Map03_Map04`), and `"Map04_Map05"` (Map_04 `Map04_Map05` ↔ Map_05 `Map04_Map05`) — all 5 maps are
now reciprocally connected end to end (Map_01↔02↔03↔04↔05). All positions on the Map_03↔04 and
Map_04↔05 connections are placeholder guesses (offset from each map's own player spawn) since
neither map's real layout could be seen from here — same pattern: pick a shared id, set
`spawn_id` on both directions' triggers, add a `SpawnPoint` (`spawn_point.gd`) child under each
trigger nudged clear of its own `BoxShape3D`'s thin axis.

**Spawn-point clearance must account for the player's own collision radius, not just the box's
half-extent** — first pass nudged each `SpawnPoint` by exactly (or barely past) the box's
half-extent, which sounds safe until you remember `Player`'s `CapsuleShape3D` has no radius
override, i.e. it uses Godot's default **0.5**. A marker sitting 0.5 units past the box edge still
has the player's own capsule overlapping the trigger volume at the moment they spawn, which
re-fires `body_entered` immediately and bounces them right back — this was reported and reproduced
on both the Map01_Map02 and Map02_Map03 connections (margins of ~0 and ~0.07 respectively). Fixed
by widening every `SpawnPoint` offset to clear (box half-extent + player radius + ~1.5-2 unit
buffer), not just the bare half-extent. All new connections should size their nudge the same way:
`offset > half_extent_along_that_axis + 0.5 + margin`.
**Not visually confirmed** — same standing caveat as the rest of this pass; double check a fresh
spawn doesn't immediately re-trigger the exit it just came from, and that facing direction (each
`SpawnPoint`'s own rotation, read via `global_rotation.y`) looks right — it defaults to 0 or
whatever rotation you last happened to set the marker to.

**Live-editor-clobbering risk observed repeatedely this session**: `project.godot` and
`Map_03_UnderTheOverPass.tscn` both had unrelated external edits silently reverted partway through
this same session — almost certainly the Godot editor being open with these files' state already
loaded, then re-saving its own (stale) in-memory copy over the external change. `project.godot`
specifically had `DuckState="*res://autoload/DuckState.gd"` (an autoload pointing at a `.gd` file
that no longer exists, since the Duck companion system was deleted — see `## Duck Companion System
(deprecated)`) resurrected this way after already having been removed once. If a value you (or I)
just changed doesn't seem to be taking effect, this is the first thing to suspect — close the
relevant scene tab / reload the project in the editor before making further external edits.

**A teammate's git sync fully reverted Map_01/Map_03 to their pre-session state once** — Zee had
uncommitted local changes to both files that conflicted with an incoming pull; committing those
local changes and then merging appears to have resolved the conflict by keeping Zee's side
wholesale for both files, discarding this session's entire history of changes to them (sky/
moonlight unification, ambient/fog retuning, `CityGlow`, the `ExitArrow`/`SpawnPoint` additions,
and the whole `Map03_Map04` connection — none of it touched Map_02/04/05, which came through
fine). Recovered by reapplying every change from scratch on top of the post-merge file (not by
resetting to an old commit, since Zee's own new edits in that merge needed to stay). If this
happens again: `git show <old-commit>:<path>` to pull up the last-known-good version of a file
as a reference for what needs reapplying, rather than assuming a git reset is safe (it would also
discard whatever new work the teammate did in the same file).

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

**`Scenes/Assets/ExitArrow/exit_arrow.tscn`** — a small retro gold arrow (`CylinderMesh` cone for
the head, `bottom_radius=0` so the point faces down, plus a thin `CylinderMesh` shaft above it;
unshaded `StandardMaterial3D` with emission so it reads clearly regardless of the scene's ambient
level) that floats above a map exit to signal "you can leave to another map here." `exit_arrow.gd`
just bobs it up/down forever via a looping `Tween` on `position.y` (`BOB_AMPLITUDE=0.15`,
`BOB_DURATION=1.2s` per half-cycle) — no rotation, since a cone+cylinder is rotationally symmetric
around Y and spinning it wouldn't be visible anyway. Instanced above all 4 existing cross-map
exits: Map_01's `ExitTrigger`, Map_02's `ExitToMap01`/`ExitToMap03`, Map_03's `ExitToMap02` — each
placed ~1.8 units above the trigger's true world position. **Note for `ExitTrigger` specifically**:
its `CollisionShape3D` child carries its own non-zero local offset on top of the `Area3D`'s own
90°-rotated transform, so the arrow's placement had to be computed by actually transforming that
child offset through the parent's rotation+translation — not just read off the `Area3D` node's own
transform line, which would have been off by roughly 54 units. Map_02/03's own trigger
`CollisionShape3D` children have no offset (identity), so those two arrows use the trigger node's
transform directly. Not placed on any Map_04/05 exit since neither map has a working exit trigger
yet (per `## Scene Transition System` below).

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
`"Map_03_Backroom"` in `Backroom.tscn`, and `"Map_04_ArcadeAlley"` in `Map_04_ArcadeAlley.tscn`
(added later, once that map existed — see the Map_04 bonus-NPC note under `## NPC System` above
for the live-editor-clobbering snag hit while adding it) — purely so the pickup-notification UI
has something to test against in each one; none of these are the real thematic placement from
the table above, that's still Zee's call. All 5 duck slots (`TOTAL_DUCKS = 5`) now have a
placeholder instance somewhere.
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

**Secret Alien NPC (same all-ducks-collected condition)**: direct request — alongside the
Television's secret dialogue swap, Map_05 now also gets a normally-hidden `NPC_GreyAlien`-style
NPC standing next to the Television, only appearing/interactable once
`YellowDuckState.has_collected_all()` is true. Rather than modify the shared `NPC_GreyAlien.tscn`
prefab (still reused elsewhere, e.g. `television_test.tscn`, without this gating), added a small
dedicated subclass, **`Scenes/NPC/secret_alien_npc.gd`** (`extends
"res://Scenes/NPC/npc_base.gd"`): in `_ready()`, if `has_collected_all()` is false, sets
`visible = false`, `collision_layer = 0`, `collision_mask = 0`, disables `_process`/
`_physics_process`, and returns *without* calling `super._ready()` — so the node never joins the
`"npc"` group, never gets `npc_base.gd`'s auto-shader/light treatment, and is both invisible and
un-raycastable (Player's interaction raycast has no custom `collision_mask`, so a `layer = 0`
body is the standard way to make something raycast-transparent). If ducks are already all
collected when the map loads, `super._ready()` runs as normal and the NPC behaves like any other.
Placed as a plain `StaticBody3D` node (`Scenes/Maps/Map_05_SchoolRooftop.tscn`'s `SecretAlienNPC`)
using the same `alien.tscn` mesh + collision-box dimensions as `NPC_GreyAlien.tscn`, positioned a
few units beside the Television (placeholder offset, not visually confirmed) with its own drafted
dialogue leaning into "the alien was watching the whole time" rather than reusing
`NPC_GreyAlien.tscn`'s own generic default lines, since this placement is specifically framed as
a reward for 100% collection. The check only runs once, at `_ready()` — but unlike a hypothetical
"collect the last duck mid-scene" case, this is a non-issue in practice: all 5 Yellow Ducks live
in Map_01–04 and the Backroom easter egg, never in Map_05 itself, so the collected-all state
literally cannot change while the player is standing in Map_05 to begin with.

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

**Reported bug: player could still interact during the paused ending** — `get_tree().paused =
true` freezes everything with default `process_mode` (which is why the player can't move/click
during the ending), but `pause_menu_ui.gd` is deliberately `PROCESS_MODE_ALWAYS` (see `## Pause
Menu` above) specifically so **Esc still opens it while paused** — the one loophole that same
property leaves open is that Esc still opens the pause menu *during the ending too*, letting the
player jump to Main Menu or Settings mid-cutscene. Fixed narrowly rather than pausing the whole
game differently: `player.gd` now calls `add_to_group("player")` in `_ready()` and exposes
`lock_for_ending()` (sets `_pause_menu.process_mode = Node.PROCESS_MODE_DISABLED`, which
overrides `PROCESS_MODE_ALWAYS` and stops it receiving `_unhandled_input` regardless of tree-pause
state). `_on_ending_triggered()` looks the player up via
`get_tree().get_first_node_in_group("player")` and calls it right alongside setting
`paused = true`. No other UI needed this treatment — `dialogue_ui.gd`/
`duck_pickup_notification_ui.gd` have no `PROCESS_MODE_ALWAYS` override, so pausing already
covers them.

**`ending_title_ui.gd`** (CanvasLayer, layer=25, `PROCESS_MODE_ALWAYS` — required so its tweens
still run once `ending_sequence.gd` pauses the tree) — immediate black `ColorRect` (no fade, per
GDD: "CUT: Black. Immediate.") then fades in a centred "YAKO" title (pixel font, size 16, white
+ 1px black outline), holds `TITLE_HOLD=2s`, fades out, then — direct request, to give the ending
a beat to land on rather than cutting straight to credits — shows `CLOSING_LINES` (an
`Array[String]`, not one combined block): each line fades in on its own (`QUOTE_FADE=1.8s`,
`TRANS_SINE` for a slower, more deliberate "cinematic" ease rather than linear), holds
`QUOTE_LINE_HOLD=4.5s`, fades out, then a `QUOTE_GAP=1.2s` beat of plain black before the next
line — i.e. the two lines are never on screen together, shown as sequential title cards like film
subtitles, per direct request ("两句分别显示", "更有电影感"). Text size dropped slightly to
`get_display_font_size(9, 16)` (from an initial `10`) with the label box narrowed (`24px` side
margins instead of `10px`) and `line_spacing` bumped to `6` — direct request for "更高级" framing:
narrower measure + more line-air reads as more deliberately typeset than a nearly-full-width block.
Only then does it fade in the studio logo (`TextureRect`, `Scenes/Assets/Logo/YellowDuck.jpg`,
`TEXTURE_FILTER_NEAREST` to stay crisp at this resolution, `LOGO_SIZE=64`), a `STUDIO_NAME` label
("YellowDuck Studio", size 8) below it, and a `CREDITS_TEXT` label (team names/roles, size 6 —
matches the project's standard body-text size) below that, all three in parallel. The text labels
share a `_make_label()` helper. `CLOSING_LINES` ("the owl came down from the roof, at last." /
"it had somewhere to be, after all.") is original wording, not lifted from the opening Psalm —
deliberately echoes its "owl on a rooftop" imagery (fitting, since the ending itself plays out on
the Map_05 rooftop) as a bookend. **First-draft text, not final** — same caveat as every other
placeholder line in this project (Caveman's dialogue, the bonus NPCs' lines); rewrite the array
directly, no code changes needed, each element becomes its own title card.

**Auto-return to Main Menu (direct request)**: after `CREDITS_HOLD=4s`, logo/studio/credits fade
back out, then `get_tree().paused = false` (mirrors `pause_menu_ui.gd`'s own "Main Menu" button —
`paused` is tree-global, so leaving it `true` would freeze the Main Menu scene the instant it
loaded) before `SceneManager.change_scene(MAIN_MENU_SCENE)`. **Deliberately does not free this
CanvasLayer immediately after calling `change_scene`** — `ending_sequence.gd` originally added it
under `get_tree().root` (not the old scene tree), so it survives `change_scene_to_file()` and
would otherwise sit on top of the freshly-loaded Main Menu forever at layer 25 (above
`SceneManager`'s own layer 20), permanently hiding it behind an opaque black `ColorRect`. Since
this layer's own overlay is already fully opaque and *above* `SceneManager`'s, it also has the
side effect of fully masking `SceneManager`'s entire fade-in/switch/fade-out sequence underneath —
harmless, since the net result is still just "black, then Main Menu," but worth knowing if the
timing ever needs adjusting. Waits a flat `1.0s` (comfortably longer than `SceneManager`'s own
~0.9s fade-in + switch + fade-out) for that transition to finish off-screen, then fades its own
overlay out over `0.6s` for a clean final reveal of the Main Menu, then `queue_free()`s itself.
**Not visually confirmed** — the `1.0s` buffer is sized from reading `SceneManager.gd`'s own
hardcoded durations, not measured; if the Main Menu ever appears to "pop" in before the fade
finishes (or there's an awkward extra-long hold of black), shorten/lengthen this buffer.
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

## Level Collision & Boundary Walls

**Found: Map_01 had almost no collision anywhere in the level geometry** — before this pass, the
*only* `CollisionShape3D` in the entire file belonged to the exit trigger's `Area3D`; the store
shell, shelves, and every other prop had none, so the player could walk straight through all of
them. This game has no gravity (`velocity.y` is unused per `player.gd`), so missing floor
collision doesn't cause falling — the actual problem is purely "nothing stops horizontal
movement," i.e. walking through walls and off the edge of the designed area.

**Split into two deliberately separate jobs**, since only one of them is something that can be
done without seeing the actual geometry:
1. **Precise per-object collision** (walls, shelves, building shells reading as solid) needs
   visual fitting and is left to whoever's in the editor: select the relevant `MeshInstance3D`
   node(s), **Mesh menu → Create Trimesh Static Body** — Godot generates an exact collision shape
   from the visible mesh, which is far more reliable than guessing box positions blind. Works on
   multiple selected nodes at once for batch use across `Buildings`/`Cars`/etc.
2. **A rough perimeter safety net**, added now: `Map_01_ConvenienceStore.tscn` gained a
   `Boundary` node (`parent="."`) containing a `Floor` `StaticBody3D` (one large flat
   `BoxShape3D`, `230×0.4×120`, centered under the map's known content — `Player`/NPC spawns,
   `Shop` mesh, `ExitTrigger`'s true position all sit inside this footprint) plus four
   `WallNorth`/`WallSouth`/`WallEast`/`WallWest` `StaticBody3D`s (tall thin `BoxShape3D`s) ringing
   that same footprint, so at minimum the player can't wander out of the designed area into empty/
   undecorated space even before the real walls get their own collision.
**Not visually confirmed** — same standing caveat as everything else placed blind this session;
the boundary was sized from known node positions (spawn points, NPCs, the `Shop` mesh, the exit
trigger), not from seeing the room, so it may be too tight (clipping something at the edge) or too
loose (leaving dead space outside the playable area) — check in the editor and resize the three
`BoxShape3D_floor01`/`BoxShape3D_wallNS01`/`BoxShape3D_wallEW01` sub-resources if so. Same
treatment (floor + 4 perimeter walls, sized from each map's own known positions) should be applied
to Map_04–05 next; neither has it yet.

**Map_02** got the same `Boundary` treatment, but sized much larger — this map's Zee-city
buildings are scattered on the order of hundreds of units apart (vs. Map_01's tens-of-units
SevenEleven scale), so the footprint was estimated from the widest known points instead: both
cross-map exit triggers (`~Z=261` toward Map_01, `~Z=-310` toward Map_03), the two NPCs
deliberately placed far out to fill empty space (`Raccoon` at `X≈145`, `Octopus` at `Z≈19`), and
the most extreme building positions seen while working on this map earlier (roughly `X: -835` to
`+500`). Landed on a floor/wall footprint of `X: -900 to 550`, `Z: -350 to 300`, floor around
`Y≈3` (matching Player/NPC/exit-trigger height in this map, not the wildly-inconsistent Y values
individual building meshes sit at), walls `15` units tall (taller than Map_01's `10`, since this
city reads as multi-story). Same caveat as Map_01, doubly so given the rougher position data this
was built from: **not visually confirmed**, margins around the known extreme points are as slim
as ~40–65 units at this scale, so treat this as a coarse first pass more than Map_01's was.

**Map_03** got the same treatment: footprint estimated from `Player`/NPC spawn cluster
(`X:113–153, Z:-29–24`), the `BackroomEntryTrigger` (`Z≈24`), and — the widest outlier by far —
the `Map03_Map04` connection sitting at `X≈245, Z≈-197`, since Zee had repositioned that trigger
well away from the rest of the map's known content. Landed on `X: 50–300`, `Z: -230–50`, floor at
`Y≈2.7` (matching this map's consistent Player/NPC/trigger height), `15`-unit walls (same
convention as Map_02). Margins around the `Map03_Map04` outlier point are ~33–55 units — same
coarse-first-pass caveat as Map_02, **not visually confirmed**.

**`tools/bulk_add_collision.gd`** — an `EditorScript` (run via the Script editor's File → Run /
Ctrl+Shift+X while the target map is the open scene, *not* attached to any node) for batch-adding
collision to every `MeshInstance3D` under a given `TARGET_PATH`. Went through two revisions after
reported failures:
1. First version called `create_trimesh_collision()`/`create_convex_collision()` (the same thing
   the editor's own Mesh menu → Create Trimesh/Convex Static Body does), parented under each mesh
   — reported as producing wrong/misaligned collision on this project's buildings.
2. Second version swapped the hull generation for a plain `BoxShape3D` sized to each mesh's own
   `get_aabb()`, still parented locally under the mesh — **still misaligned**. Root cause: this
   project uses **Jolt Physics** (`project.godot`'s `3d/physics_engine`), which does not reliably
   apply inherited node scale to collision shapes the way rendering does — so a shape parented
   under one of these heavily-scaled/rotated building instances (see the Sketchfab-style
   `Sketchfab_Scene → fbx_root → RootNode → mesh` chains throughout `Scenes/Assets/Zee/...`) comes
   out wrong regardless of whether the shape itself is a precise hull or a simple box.
3. **Current version**: computes each mesh's axis-aligned bounding box **in world space** (transforms
   all 8 local-AABB corners through the mesh's `global_transform`), then creates a fresh,
   *unscaled* `StaticBody3D` directly under the scene root (in a new `GeneratedCollision_<target>`
   container, not nested under the mesh at all) sized/positioned to match. Since this new body has
   no inherited scale for Jolt to mishandle, it doesn't hit the same failure mode. Trade-off: an
   axis-aligned box doesn't rotate to match an angled building, so it's generously oversized on
   the diagonal for rotated instances — fine for "can't walk through it," not a precise hull.
   **Not idempotent** (no "already has collision" check, since generated bodies live in a separate
   container rather than as mesh children) — delete the previous `GeneratedCollision_<name>` node
   before re-running on the same target.
Explicitly sets `owner` on every created node so it actually persists on save — a real risk with
editor-scripted node creation, not just theoretical.

**Manually-placed `CollisionShape3D` nodes not working (Map_03)** — reported and fixed: several
`CollisionShape3D`s had been hand-added directly as children of mesh/`Node3D` wrapper nodes
(`Sculpture/Sketchfab_Scene`, `Sketchfab_Scene2`, and `commercial_buildings/Sketchfab_Scene3`/
`05`/`0_7_1`/`0_8_1`), with reasonable shapes/transforms already tuned — but a bare
`CollisionShape3D` does nothing unless its **direct parent** is a `CollisionObject3D`-derived node
(`StaticBody3D`/`Area3D`/`RigidBody3D`/`CharacterBody3D`); parented straight under a mesh, it's
inert (Godot flags this with a warning icon in the Scene dock, easy to miss). Fixed by inserting a
plain `StaticBody3D` between each mesh and its existing `CollisionShape3D` child/children —
transform and `shape` on each `CollisionShape3D` were left completely untouched, only the parent
path changed, so nothing about the already-tuned positioning was lost.

**`CityGlow`'s `target_paths` were broken on all 4 maps that have one** (Map_02/03/04/05) — found
while debugging the above. `city_glow.gd`'s `_ready()` calls `get_node_or_null(path)` on `self`
(the `CityGlow` node), which resolves a relative `NodePath` starting from `CityGlow` itself, not
from the scene root. But every map's `CityGlow` node is a **sibling** of its building containers
(both parented under the same parent — e.g. Map_03 has `CityGlow` and `buildings` both at
`parent="."`), not a parent of them — so a plain path like `"buildings"` was actually asking
"does `CityGlow` have a child named `buildings`?", which is always false, throwing `Found invalid
node path 'buildings' on node '.../CityGlow'` and silently no-opping the whole glow pass on every
map, this whole session. Fixed by prefixing every `target_paths` entry with `../` (go up to the
shared parent first, then down to the sibling) — `Map_02`: `../Asset New/Building`; `Map_03`:
`../buildings`, `../commercial_buildings`; `Map_04`: `../Assets/Buildings`, `../school`,
`../school_walls`; `Map_05`: `../assets/school`, `../assets/store`. This means **city_glow.gd has
never actually applied emission to a single building on any map until now** — the whole "make
Zee's buildings glow at night" pass earlier this session looked complete in the code but was a
no-op the entire time. Still not visually confirmed now that the path itself resolves.

**First real test massively overexposed** — with the path bug fixed, `city_glow.gd` ran for the
first time ever, and `emission_energy = 10.0` (tuned much earlier, for a *different* purpose:
making a small lamp-sized light punch through heavy fog) turned out to be wildly wrong for this
use, where the *entire building facade texture* becomes the emitter rather than a small point
light — one building lit up as an overexposed white blob dominating the whole screen. Dropped the
default to **`0.8`** (over 90% cut) as a much more conservative starting point. **Not visually
confirmed** — this is a corrective guess after seeing the "way too much" extreme, not a tuned
value; likely needs another round or two of adjustment (same iterative back-and-forth as the fog
density tuning earlier) once actually seen at this new value.

## Code Conventions

- GDScript with static typing (`:=` or explicit types)
- No comments unless logic is non-obvious
- One script per scene, co-located with the scene file
- All code and documentation in English
