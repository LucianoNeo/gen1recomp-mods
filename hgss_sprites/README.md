# HGSS_SPRITES 2.0.0

This directory is the importable `HGSS_SPRITES` mod for Pokémon Red, Blue,
Yellow and the supported Gold/Silver/Crystal runtime on g1recomp. The project overview, current screenshots and companion-mod links
are in the [repository README](../README.md).

## Current feature set

- HGSS-style full-color overworld charsets with six-frame movement for Red,
  Ash, Ethan, NPCs, Gym Leaders, Elite Four, Team Rocket and named map objects.
- Player selection (`RED`, `ASH`, `ETHAN`, `LYRA`, `KRIS`, `LEAF`, `BRENDAN`) with an `OFF`
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
- Battle front/back/trainer artwork for Gen 1, with animated/native resolution
  assets and transparent backgrounds; Gen 2 battle Pokémon remain native.
- Leaf's and Brendan's animated full-color battle back sprites are selected by
  `PLAYER SELECT > LEAF` and `PLAYER SELECT > BRENDAN`; both player sprite sets
  are credited to `setogabes` (Discord).
- Kris's overworld and bicycle sheets were generated from the supplied
  `sprite_pack___kris_by_diegowt_dlrukne` pack.
- Kris's animated battle-back atlas was extracted from the supplied trainer
  reference sheet and is used by `PLAYER SELECT > KRIS`.
- `TRAINERS ONLY` as the default battle scope, with an optional `COMPLETE`
  scope for bundled Pokémon battle art.
- Optional HGSS party menu, animated party icons and PC box icons, with
  original-screen toggles and four-way party navigation.
- The party and PC icon layouts also run on Gen2's native menus. With PC icons
  enabled, the full-screen HGSS panel suppresses the native front-static/GSC
  layers. The package contains all 251 two-frame HGSS icon sheets: the 151
  Kanto sheets already shipped with the mod plus 100 Johto sheets generated
  from Wilds of Kanto's original 32x32 overworld cells, with no resampling.
- Configurable Gen1 battle generations, player battle intro and overworld size
  (`0.5x`–`1.0x`, default `0.8x`); Gen2 keeps its native battle presentation
  and hides those Gen1-only selectors.
- Intro, catch-summary, evolution, Pokédex and Hall of Fame artwork paths use
  the bundled assets with safe fallback to the game originals.

## Mod options

The options are exposed by the g1recomp Mods menu:

| Option | Values | Default |
| --- | --- | --- |
| Player Select | `RED`, `ASH`, `ETHAN`, `LYRA`, `KRIS`, `LEAF`, `BRENDAN`, `OFF` | `RED` |
| Battle Art Scope (Gen 1) | `TRAINERS ONLY`, `COMPLETE` | `TRAINERS ONLY` |
| Battle Front/Back/Trainer Gen (Gen 1) | `GEN 1`–`GEN 5` | `GEN 5` / `GEN 3` |
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
not declare Battle Art as a required dependency. Per-asset sources and credits
are documented in [`assets/battle/README.md`](assets/battle/README.md).
