# HGSS Visual Overhaul

![Version](https://img.shields.io/badge/version-0.3.3-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.78-blue)

A visual pack for Pokemon Yellow on g1recomp, inspired by HeartGold and
SoulSilver. Battle Art Voxel Fork is recommended for its Voxel renderer.

## Scope

This pack owns three visual areas:

- the opening portraits (Nidorino, Professor Oak, Red and Blue);
- HGSS overworld charsets, including walking directions and frames;
- full-color animated party icons.
- self-contained battle Pokemon collections and player trainer intros.

Version 0.3.3 includes the 0.3.2 features plus the animated Pikachu intro and
the guarded HD quad presentation. Version 0.3.2 includes the 0.3.1 features plus the verified map-object and
normal-palette legendary-bird corrections. Version 0.3.1 includes the 0.3.0
features plus verified Ash and Ethan Voxel captures. Version 0.3.0 introduced
corrected voxel grounding and three
configurable presentation options:

- **PLAYER SELECT** — choose `RED`, `ASH` or `ETHAN` for the overworld player
  and the player battle intro.
- **PARTY MENU** — turn the HGSS party screen and full-color icons `ON` or
  leave the original party screen `OFF`.
- **SPRITE SIZE** — scale every HGSS overworld character (player, NPCs and
  leaders) from `0.5x` through `1.0x` in `0.1x` steps. Battle art and party
  icons are not affected.

Ash and Ethan use native 256x1536 sheets at a 28px logical footprint, matching
Red's map proportions in both 2D and Voxel modes. Sprite size applies at draw
time, so it updates existing maps without resampling the source sheets.

## Current in-game captures

### Outdoor Voxel 3D

![Red with Pikachu outdoors](docs/media/readme-voxel-outdoor-pikachu.png)

The `PLAYER SELECT` option is also verified with the Voxel renderer:

![Ash outdoors with Voxel enabled](docs/media/readme-voxel-ash.png)
![Ethan outdoors with Voxel enabled](docs/media/readme-voxel-ethan.png)

### Gym captures

![Pewter Gym with Brock](docs/media/readme-voxel-gym-brock.png)
![Cerulean Gym with Misty](docs/media/readme-voxel-gym-misty.png)

### Party icons

The party menu retains the full-color HGSS icon set:

![HGSS party icons](docs/media/party-icons-hgss.png)
![Party menu with six Pokemon](docs/media/readme-party-icons.png)

## Installation

1. Optionally install [Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod) for the Voxel renderer.
2. Optionally enable `CRYSTAL_251`; it is declared as a compatibility companion, not a requirement.
3. Download the [`HGSS_SPRITES` 0.3.3 asset](https://github.com/LucianoNeo/gen1recomp-mods/releases/tag/v0.3.3).
4. Import the ZIP in the g1recomp mod manager and enable **HGSS Visual Overhaul**.
5. Restart g1recomp after installing or updating any companion mod.

Compatibility: g1recomp `>=0.1.75 <0.2.0`, including tested runtime `0.1.78`,
Pokemon Yellow and Mod API 2. Import, overworld Voxel and battle Voxel smoke
tests passed on 0.1.78.

## Runtime formats

| Asset | Runtime format |
|---|---|
| Walking overworld sheet | `32x192`, six frames |
| Jessie / James / Officer Jenny source sheet | `256x1536`, six frames |
| Ash / Ethan player source sheet | `256x1536`, six frames, 28px logical cell |
| Intro portrait sheets | native transparent PNG |
