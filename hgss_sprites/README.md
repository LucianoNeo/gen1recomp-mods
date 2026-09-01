# HGSS_SPRITES 1.0.5

This directory is the importable `HGSS_SPRITES` mod for Pokémon Red, Blue and
Yellow on g1recomp. The project overview, current screenshots and companion-mod links
are in the [repository README](../README.md).

## Current feature set

- HGSS-style full-color overworld charsets with six-frame movement for Red,
  Ash, Ethan, NPCs, Gym Leaders, Elite Four, Team Rocket and named map objects.
- Player selection (`RED`, `ASH`, `ETHAN`, `LYRA`, `LEAF`, `BRENDAN`) with an `OFF`
  option that preserves the game's original player, dedicated walking and
  bicycle sheets, follower Pikachu, forced Surfing Pikachu and
  species-specific overworld objects.
- Grounding and lighting behavior for both the 2D and Voxel renderers.
- Battle front/back/trainer artwork for generations 1–5, with animated/native
  resolution assets and transparent backgrounds.
- Leaf's and Brendan's animated full-color battle back sprites are selected by
  `PLAYER SELECT > LEAF` and `PLAYER SELECT > BRENDAN`; both player sprite sets
  are credited to `setogabes` (Discord).
- `TRAINERS ONLY` as the default battle scope, with an optional `COMPLETE`
  scope for bundled Pokémon battle art.
- Optional HGSS party menu, animated party icons and PC box icons, with
  original-screen toggles and four-way party navigation.
- Configurable battle generations, player battle intro and overworld size
  (`0.5x`–`1.0x`, default `0.8x`).
- Intro, catch-summary, evolution, Pokédex and Hall of Fame artwork paths use
  the bundled assets with safe fallback to the game originals.

## Mod options

The options are exposed by the g1recomp Mods menu:

| Option | Values | Default |
| --- | --- | --- |
| Player Select | `RED`, `ASH`, `ETHAN`, `LYRA`, `LEAF`, `BRENDAN`, `OFF` | `RED` |
| Battle Art Scope | `TRAINERS ONLY`, `COMPLETE` | `TRAINERS ONLY` |
| Battle Front Gen | `GEN 1`–`GEN 5` | `GEN 5` |
| Battle Back Gen | `GEN 1`–`GEN 5` | `GEN 5` |
| Battle Trainer Gen | `GEN 1`–`GEN 5` | `GEN 3` |
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
