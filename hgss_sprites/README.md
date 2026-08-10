# HGSS Visual Overhaul

![Version](https://img.shields.io/badge/version-0.2.0-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.75-blue)

A companion visual pack for Pokemon Yellow on g1recomp, inspired by
HeartGold and SoulSilver. It requires
[Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod),
which remains the owner of battle and voxel artwork.

## Scope

This pack owns only three areas:

- the opening portraits (Nidoran, Professor Oak, Red and Blue);
- HGSS overworld charsets, including walking directions and frames;
- the flat 2D battle HUD: DS-style borders, cursor and colored HP bars.

Battle Pokemon, trainer portraits and voxel battle presentation are not
overridden, so the Battle Art Voxel Fork can provide them without duplicates,
giant sprites or broken layering.

## Before and after

These captures were made directly from g1recomp runs. The comparison images
are kept as documentation of the visual areas owned by this pack.

### Overworld

| Vanilla Yellow | HGSS overworld |
|---|---|
| ![Vanilla overworld](docs/media/readme-before-overworld.png) | ![HGSS overworld](docs/media/readme-after-overworld.png) |

### 2D battle HUD

| Vanilla HUD | HGSS 2D HUD |
|---|---|
| ![Vanilla battle](docs/media/readme-before-battle.png) | ![HGSS battle HUD](docs/media/readme-after-battle.png) |

The battle-art images are reference captures only; the installed Battle Art
Voxel Fork remains the sole provider of battle Pokemon and trainer sprites.

## Installation

1. Install [Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod).
2. Download [HGSS_SPRITES-0.2.0.zip](https://github.com/LucianoNeo/gen1recomp-mods/releases/download/v0.2.0/HGSS_SPRITES-0.2.0.zip).
3. Import the ZIP in the g1recomp mod manager and enable **HGSS Visual Overhaul**.
4. Restart g1recomp after installing or updating either mod.

Compatibility: g1recomp `>=0.1.75 <0.2.0`, Pokemon Yellow and Mod API 2.

## Runtime formats

| Asset | Runtime format |
|---|---|
| Walking overworld sheet | `32x192`, six frames |
| Jessie / James walking sheet | `128x768`, six frames |
| Intro portrait sheets | native transparent PNG |
