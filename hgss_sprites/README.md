# HGSS_SPRITES 1.0.2

This directory is the importable `HGSS_SPRITES` mod for Pokémon Yellow on
g1recomp. The project overview, current screenshots and companion-mod links
are in the [repository README](../README.md).

## Current feature set

- HGSS-style full-color overworld charsets with six-frame movement for Red,
  Ash, Ethan, NPCs, Gym Leaders, Elite Four, Team Rocket and named map objects.
- Player selection (`RED`, `ASH`, `ETHAN`, `LEAF`, `BRENDAN`), dedicated walking
  and bicycle sheets, follower Pikachu, forced Surfing Pikachu and
  species-specific overworld objects.
- In Gold/Silver/Crystal, `PLAYER SELECT` now resolves the matching foot and
  bicycle sheet for Red, Ash, Ethan, Lyra, Leaf or Brendan; it no longer
  substitutes Ethan for the other choices.
- Grounding and lighting behavior for both the 2D and Voxel renderers.
- Player battle back portraits follow `PLAYER SELECT` (Red, Ash, Ethan, Lyra,
  Leaf or Brendan); Pokémon and opponent battle sprites remain the game's
  originals. Each selectable protagonist uses its own bundled HGSS Battle Art
  back strip.
- Leaf's animated full-color battle back sprite is selected by `PLAYER SELECT >
  LEAF`; the Leaf player sprite set is credited to `setogabes` (Discord).
- Optional HGSS party menu, animated party icons and PC box icons, with
  original-screen toggles and four-way party navigation.
- Player battle intro selection and configurable overworld size (`0.5x`–`1.0x`,
  default `0.8x`).
- Intro, catch-summary, evolution, Pokédex and Hall of Fame artwork paths use
  the bundled assets with safe fallback to the game originals.

## Mod options

The options are exposed by the g1recomp Mods menu:

| Option | Values | Default |
| --- | --- | --- |
| Player Select | `RED`, `ASH`, `ETHAN`, `LEAF`, `BRENDAN` | `RED` |
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
