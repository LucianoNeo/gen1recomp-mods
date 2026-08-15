# HGSS Visual Overhaul

![Version](https://img.shields.io/badge/version-0.5.0-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.88-blue)

A visual pack for Pokemon Yellow on g1recomp, inspired by HeartGold and
SoulSilver. Battle Art Voxel Fork is optional and recommended only when its
Voxel renderer is desired.

## Scope

This pack owns three visual areas:

- the opening portraits (Nidorino, Professor Oak, Red and Blue);
- HGSS overworld charsets, including walking directions and frames;
- full-color animated party icons.
- self-contained battle Pokemon collections and player trainer intros.

Version 0.5.0 includes the 0.4.5 package plus current g1recomp sandbox loading
and public voxel-provider compatibility for Battle Art Voxel Fork 1.9.0 and
PotatoVoxel 1.6.0. Version 0.4.5 includes the 0.4.4 package plus the Oak Pikachu-catch crash fix,
the full-color Oak battle back, and Jessie/James assets for generations 4 and 5.
Version 0.4.4 includes the 0.4.3 package plus animated native-resolution icons
for PC withdraw, deposit and release lists. Version 0.4.3 includes the 0.4.2 package plus the corrected Viridian Old Man
overworld charset and true-color battle backs. Version 0.4.2 includes the
0.4.1 package plus normal, sparkle-free legendary
bird party icons and the flat-menu duplicate guard. Version 0.4.1 includes the 0.4.0 package plus the corrected Fighting Dojo
Black Belt directions and six-frame walk sheet. Version 0.4.0 includes the
0.3.3 animated Pikachu intro and guarded HD quad
presentation, plus the current voxel coexistence package test. Version 0.3.2
includes the 0.3.1 features plus the verified map-object and normal-palette
legendary-bird corrections. Version 0.3.1 includes the 0.3.0 features plus
verified Ash and Ethan Voxel captures. Version 0.3.0 introduced corrected voxel
grounding and three
configurable presentation options:

- **PLAYER SELECT** — choose `RED`, `ASH` or `ETHAN` for the overworld player
  and the player battle intro.
- **PARTY MENU** — turn the HGSS party screen and full-color icons `ON` or
  leave the original party screen `OFF`.
- **PC BOX ICONS** — turn the same animated, full-color HGSS icons on or off
  in the PC's withdraw, deposit and release lists.
- **SPRITE SIZE** — scale every HGSS overworld character (player, NPCs and
  leaders) from `0.5x` through `1.0x` in `0.1x` steps. Battle art and party
  icons are not affected.

Ash and Ethan use native 256x1536 sheets at a 28px logical footprint, matching
Red's map proportions in both 2D and Voxel modes. Sprite size applies at draw
time, so it updates existing maps without resampling the source sheets.

## Battle Art Voxel Fork attribution

The battle asset library/content used by this mod was adapted from the public
[Battle Art Voxel Fork /
DramaticShapeVoxelMod](https://github.com/absol89/DramaticShapeVoxelMod)
collections and conventions. Credit is due for the reused/adapted generation
directory layout, lowercase species/trainer filename slugs, animated atlas cell
format and frame-timing tables. This credit concerns the asset library and its
compatibility conventions; individual image sources are documented separately.

A code audit found no runtime module import or manifest dependency on Battle
Art. The local resolver, atlas decoder and frame-timing path were nevertheless
reimplemented from Battle Art's battle-art architecture, so that adapted code
is credited here rather than presented as unrelated original work. HGSS Visual
Overhaul's implementation lives in `main.lua`, uses g1recomp Mod API 2 and
bundles its own assets; Battle Art's HUD, trainer renderer and Voxel runtime are
not included. Battle Art is not a manifest dependency and is only an optional
companion for users who want its separate Voxel renderer. Missing files fall
back to g1recomp.
The original source and credit for each collection are documented in
[`assets/battle/README.md`](assets/battle/README.md) and its generation notes.

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

1. Optionally install [Battle Art Voxel Fork](https://github.com/absol89/DramaticShapeVoxelMod) for its Voxel renderer; it is not required for the mod's battle or overworld assets.
2. Optionally enable `CRYSTAL_251`; it is declared as a compatibility companion, not a requirement.
3. Download the [`HGSS_SPRITES` 0.5.0 asset](https://github.com/LucianoNeo/gen1recomp-mods/releases/tag/v0.5.0).
4. Import the ZIP in the g1recomp mod manager and enable **HGSS Visual Overhaul**.
5. Restart g1recomp after installing or updating any companion mod.

Compatibility: g1recomp `>=0.1.75 <0.2.0`, including tested runtime `0.1.88`,
Pokemon Yellow and Mod API 2. Import, overworld Voxel and battle Voxel smoke
tests passed with Battle Art Voxel Fork 1.9.0 and PotatoVoxel 1.6.0.

## Runtime formats

| Asset | Runtime format |
|---|---|
| Walking overworld sheet | `32x192`, six frames |
| Jessie / James / Officer Jenny source sheet | `256x1536`, six frames |
| Ash / Ethan player source sheet | `256x1536`, six frames, 28px logical cell |
| Intro portrait sheets | native transparent PNG |
