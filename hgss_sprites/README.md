# HGSS_SPRITES 2.1.7

This directory is the importable `HGSS_SPRITES` mod for Pokémon Red, Blue,
Yellow and the supported Gold/Silver/Crystal runtime on g1recomp. The project overview, current screenshots and companion-mod links
are in the [repository README](../README.md).

## Current feature set

- HGSS-style full-color overworld charsets with six-frame movement for Red,
  Ash, Ethan, NPCs, Gym Leaders, Elite Four, Team Rocket and named map objects.
- Player selection (`RED`, `ASH`, `ETHAN`, `LYRA`, `KRIS`, `KRIS V2`, `LEAF`, `BRENDAN`) with an `OFF`
  option that preserves the game's original player, dedicated walking and
  bicycle sheets, follower Pikachu, forced Surfing Pikachu and
  species-specific overworld objects.
- Gen 2 player, NPC, Elm's Lab object, Route 30 and Pokémon overworld
  replacements use the Gen 2 sprite registry. All 35 canonical Crystal
  overworld-Pokémon slots, all 76 trainer/person slots and the mounted-Surf
  Lapras have HGSS sheets, while battle Pokémon sprites remain on the game's
  original artwork.
- The map-audited Gen 2 Pokémon objects use six-frame HGSS follow-sprite sheets
  prepared from Wilds of Kanto's original HGSS cells. Shared generic slots are
  redirected only for their named map/object instances; other generic objects,
  the `OW_WILD_*` resolver and all Gen 1 records remain untouched. See
  [`assets/gen2/pokemon-overworld/README.md`](assets/gen2/pokemon-overworld/README.md).
- Grounding and lighting behavior for both the 2D and Voxel renderers.
- Crystal Party and PC menus use the real HGSS shiny icon sheets for all 251
  species, generated from Wilds of Kanto true-size shiny overworld assets;
  static menu icons omit the source animation's transient sparkle overlay.
- The only bundled Pokémon battle-art option is the Gen 5 animated atlas
  (`GEN 5 ANIMATED`). `ROM` restores the engine's original front/back art;
  missing species or unsupported legacy settings fall back automatically.
  `TRAINER ART` exposes the credited HGSS portrait set or `ROM` on both Gen1
  and Gen2. The HGSS directory includes compatibility portraits for every
  legacy Gen1 trainer class; any still-unsupported Gen2 class falls back
  automatically to the game's original portrait.
- Gen2 rival battles resolve `RIVAL1` and `RIVAL2` to the canonical HGSS
  Silver portrait; Yellow keeps its separate Blue rival portrait.
- Hall of Fame portraits use the corresponding Pokémon player sprites for
  Red, Ethan, Lyra, Kris, Leaf and Brendan; sources and fair-use notices are
  documented in `assets/graphics/hall_front/SOURCES.md`.
- Kris's overworld and bicycle sheets were generated from the supplied
  `sprite_pack___kris_by_diegowt_dlrukne` pack.
- Kris's animated battle-back atlas was extracted from the supplied trainer
  reference sheet and is used by `PLAYER SELECT > KRIS`.
- `PLAYER SELECT > KRIS V2` uses the alternate supplied walking and bicycle
  sprites while retaining Kris's animated battle-back atlas.
- Gen2 fishing switches supported selectable protagonists to a matching directional
  fishing charset for the complete cast/bite sequence in both 2D and Voxel.
  Leaf uses her native HGSS standing poses with Ethan's fishing rod added.
  Ethan and Lyra use the extracted HGSS frames; Red uses the public Red pack,
  Ash uses PKMNTrainerRick's full HGSS/DPP pack, Brendan uses hyo's HGSS
  trainer sheet, Leaf keeps her supplied HGSS standing art with the Ethan rod
  pixels added, and both Kris variants use the supplied Kris pack.
- `TRAINERS ONLY` as the default battle scope, with an optional `COMPLETE`
  scope for bundled Pokémon battle art.
- Optional HGSS party menu, animated party icons and PC box icons, with
  original-screen toggles and four-way party navigation.
- The party and PC icon layouts also run on Gen2's native menus. With PC icons
  enabled, the full-screen HGSS panel suppresses the native front-static/GSC
  layers. The package contains all 251 two-frame HGSS icon sheets: the 151
  Kanto sheets already shipped with the mod plus 100 Johto sheets generated
  from Wilds of Kanto's original 32x32 overworld cells, with no resampling.
- Configurable Gen1 Gen-5 animated battle art/ROM selection, player battle
  intro and overworld size (`0.5x`–`1.0x`, default `0.8x`); Gen2 keeps its
  native battle presentation and hides those Gen1-only selectors.
- Intro, catch-summary, evolution, Pokédex and Hall of Fame artwork paths use
  the bundled assets with safe fallback to the game originals.

## Runtime module layout

`main.lua` remains the compatibility entry point, but its feature seams are
now loaded through the mod-local sandbox loader. `lib/Options.lua` owns the
generation-aware menu schema, and `lib/Gen2Npc.lua` owns Crystal's trainer
registry plus map/object identity redirects. `lib/Gen2Player.lua` owns Gen 2
player selection, HGSS sheet geometry, fishing-state seams and player/NPC
sprite registration. Keeping those seams outside the entry chunk makes future
Gen 2 map audits independent from the Gen 1 battle and menu hooks while
preserving the same Mod API 2 package entry point.

## Gen 2 support

Gold, Silver and Crystal are first-class targets in the `2.0.x` Gen 2 release line.
The Gen 2 path is gated separately from the Red/Blue/Yellow hooks, so enabling
this mod does not replace Gen 1 battle, menu, map or sprite behavior. The
following Gen 2 features are included:

- Native Gold/Silver/Crystal player slots with `ETHAN`, `LYRA`, `KRIS`, `KRIS
  V2`, `LEAF` and `BRENDAN` choices, plus a live `PLAYER SELECT` switch after
  the save has started. New Gen 2 saves use Ethan or Lyra for the initial
  boy/girl choice; the menu can then change to any supported character. Girl
  saves keep that explicit selection after reload, and Gen 1/Gen 2 retain
  independent player choices when switching games.
- HGSS walking, bicycle, fishing and animated battle-back sheets for the
  selectable protagonists, with shared grounding, mirror and Voxel pivot
  handling. `KRIS V2` is an additional option and does not replace the
  original Kris entry.
- Gen 2 NPC/person and map-object redirects, including Elm's Lab, the Route 30
  objects, the tutorial fisherman, the legendary dogs, Sudowoodo, the Lake of
  Rage Red Gyarados, Ho-Oh, Lugia and the mounted Surf Lapras object.
- HGSS true-colour follow sprites and two-frame party/PC icons for the complete
  251-species National Dex. The Gen 2 party and PC layouts use the same
  two-column icon treatment as Yellow and suppress the native front-static/GSC
  layers when the icon option is enabled.
- Gen 2-native Pokémon battle presentation remains available. `TRAINER ART`
  can use the dedicated HGSS portraits or `ROM`; unsupported classes fall back
  to the original cartridge portrait. The Gen 1-only Pokémon front/back
  selectors stay hidden on Gold/Silver/Crystal.

### Recommended Voxel combinations by generation

The Voxel companion must match the game generation. Enable only one Voxel
renderer for a game at a time; the Gen 1 and Gen 2 Battle Art packages are
different mods and are not interchangeable.

#### Gen 1 — Red, Blue and Yellow

Use [Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod)
(`BATTLE_ART_VOXEL_FORK`, the Gen 1 package) with `HGSS_SPRITES`. It owns the
Gen 1 Voxel overworld and battle presentation. [Wilds of Kanto](https://github.com/YoDrehDenSwagAuf/overworld-spawn-mod)
and the Shiny mod are optional companions. Do not enable
`BATTLE_ART_VOXEL_GEN2` for a Gen 1 game, and do not run PotatoVoxel or another
Voxel renderer alongside Battle Art.

#### Gen 2 — Gold, Silver and Crystal

Use the [Gen 2-compatible Battle Art package 2.1.1](https://github.com/absol89/Gen2Recomped-DramaticShapes/releases/tag/2.1.1)
(`BATTLE_ART_VOXEL_GEN2`) with `HGSS_SPRITES`. [Wilds of Kanto](https://github.com/YoDrehDenSwagAuf/overworld-spawn-mod)
is the recommended companion for its 251-species follow/overworld collection;
HGSS Visual Overhaul supplies the audited Crystal object, character and menu
redirects. The Gen 1 `BATTLE_ART_VOXEL_FORK` package is not a substitute for
the Gen 2 package. PotatoVoxel is not required.

The screenshots below were captured in the latest g1recomp build with Crystal,
HGSS_SPRITES enabled, Battle Art Voxel enabled and Wilds of Kanto enabled.
The legendary-object captures use the production Gen 2 sprite registry and a
camera-isolated QA placement so the Voxel geometry does not hide the subject.

### Gen 2 Voxel scenes

**Legendary dogs — HGSS Gen2 sprite registry (Raikou, Entei and Suicune):**

![Raikou, Entei and Suicune in Battle Art Voxel](docs/screenshots/gen2-legendary-dogs-voxel.png)

**Lake of Rage — scripted shiny Gyarados:**

![Shiny Lake of Rage Gyarados in Battle Art Voxel](docs/screenshots/gen2-lake-of-rage-gyarados-voxel.png)

**Lugia — water scene using the HGSS Lugia object:**

![Lugia in Battle Art Voxel](docs/screenshots/gen2-lugia-voxel.png)

**Ho-Oh — Tin Tower roof object:**

![Ho-Oh in Battle Art Voxel](docs/screenshots/gen2-ho-oh-voxel.png)

## Mod options

The options are exposed by the g1recomp Mods menu:

| Option | Values | Default |
| --- | --- | --- |
| Player Select | `RED`, `ASH`, `ETHAN`, `LYRA`, `KRIS`, `KRIS V2`, `LEAF`, `BRENDAN`, `OFF` | `RED` |
| Battle Art Scope (Gen 1) | `TRAINERS ONLY`, `COMPLETE` | `TRAINERS ONLY` |
| Battle Front/Back Gen (Gen 1) | `ROM`, `GEN 5 ANIMATED` | `GEN 5 ANIMATED` |
| Battle Trainer Gen | `ROM` | `ROM` |
| Party Menu | `ON`, `OFF` | `ON` |
| PC Box Icons | `ON`, `OFF` | `ON` |
| Sprite Size | `0.5x`–`1.0x` | `0.8x` |

## Installation package

Import the release ZIP from the g1recomp Mods screen. The package contains
the `mod.json`, `main.lua`, bundled overrides and assets required to run the
mod; no source checkout or companion mod is required.

## Battle-art attribution

The bundled battle asset organization, atlas conventions and compatibility
approach were adapted from the public
[DramaticShapeVoxelMod / Battle Art Voxel](https://github.com/absol89/DramaticShapeVoxelMod)
project. HGSS_SPRITES contains its own resolver and bundled assets and does
not declare Battle Art as a required dependency. The Gen2 HGSS Trainer Art
portraits in [`assets/battle/front-static/hgss/`](assets/battle/front-static/hgss/)
are sourced from the Smogon/Pokémon Showdown trainer collection at commit
`0e1f57f4234f20b999dbb442dac1093b445e0088`; the non-canonical Gen1
compatibility alternatives and their sources are documented in that directory.
Per-asset sources and credits are documented in
[`assets/battle/README.md`](assets/battle/README.md).
Hall of Fame player portrait sources are listed individually in
[`assets/graphics/hall_front/SOURCES.md`](assets/graphics/hall_front/SOURCES.md).
