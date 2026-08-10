# HGSS Visual Overhaul

![Version](https://img.shields.io/badge/version-0.2.2-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.75-blue)

A companion visual pack for Pokemon Yellow on g1recomp, inspired by
HeartGold and SoulSilver. It requires
[Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod),
which remains the owner of battle and voxel artwork.

## Scope

This pack owns only two visual areas:

- the opening portraits (Nidorino, Professor Oak, Red and Blue);
- HGSS overworld charsets, including walking directions and frames;

Battle Pokemon, trainer portraits, voxel battle presentation and HUD are not
overridden. They remain exclusively with Battle Art Voxel Fork.

## Current in-game captures

### Outdoor Voxel 3D

These fresh captures were taken from the local g1recomp build with the Voxel
pipeline enabled. They show the HGSS overworld charset rendered in outdoor
scenes while Battle Art Voxel Fork supplies the 3D renderer.

| Pallet Town | Route 1 | Cerulean City |
|---|---|---|
| ![Pallet Town in Voxel 3D](docs/media/readme-voxel-outdoor-pallet.png) | ![Route 1 in Voxel 3D](docs/media/readme-voxel-outdoor-route1.png) | ![Cerulean City in Voxel 3D](docs/media/readme-voxel-outdoor-cerulean.png) |

Red and his follower are shown on open ground in a separate outdoor capture;
Pikachu is placed in front of Red and never overlaps a building:

![Red with Pikachu outdoors](docs/media/readme-voxel-outdoor-pikachu.png)

### Party icons

The party menu retains the full-color HGSS icon set:

![HGSS party icons](docs/media/party-icons-hgss.png)
![Party menu with six Pokémon](docs/media/readme-party-icons.png)

Battle screenshots are intentionally omitted: this pack no longer modifies
battle art or HUD.

## Installation

1. Install [Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod).
2. Download the `HGSS_SPRITES` 0.2.2 asset from the [releases page](https://github.com/LucianoNeo/gen1recomp-mods/releases).
3. Import the ZIP in the g1recomp mod manager and enable **HGSS Visual Overhaul**.
4. Restart g1recomp after installing or updating either mod.

Compatibility: g1recomp `>=0.1.75 <0.2.0`, Pokemon Yellow and Mod API 2.

## Runtime formats

| Asset | Runtime format |
|---|---|
| Walking overworld sheet | `32x192`, six frames |
| Jessie / James walking sheet | `128x768`, six frames |
| Intro portrait sheets | native transparent PNG |
