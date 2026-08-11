# HGSS Visual Overhaul

![Version](https://img.shields.io/badge/version-0.2.6-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.75-blue)

A visual pack for Pokemon Yellow on g1recomp, inspired by HeartGold and
SoulSilver. Battle Art Voxel Fork is recommended for its Voxel renderer.

## Scope

This pack owns three visual areas:

- the opening portraits (Nidoran, Professor Oak, Red and Blue);
- HGSS overworld charsets, including walking directions and frames;
- full-color animated party icons.

Version 0.2.6 includes corrected voxel grounding and updated full-resolution
Agatha and Lorelei overworld sheets. Jessie, James and Officer Jenny retain
the standard six-frame walking layout.

## Current in-game captures

### Outdoor Voxel 3D

![Red with Pikachu outdoors](docs/media/readme-voxel-outdoor-pikachu.png)

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
3. Download the [`HGSS_SPRITES` 0.2.6 asset](https://github.com/LucianoNeo/gen1recomp-mods/releases/tag/v0.2.6).
4. Import the ZIP in the g1recomp mod manager and enable **HGSS Visual Overhaul**.
5. Restart g1recomp after installing or updating any companion mod.

Compatibility: g1recomp `>=0.1.75 <0.2.0`, Pokemon Yellow and Mod API 2.

## Runtime formats

| Asset | Runtime format |
|---|---|
| Walking overworld sheet | `32x192`, six frames |
| Jessie / James / Officer Jenny source sheet | `256x1536`, six frames |
| Intro portrait sheets | native transparent PNG |
