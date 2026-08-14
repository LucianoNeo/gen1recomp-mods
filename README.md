# Gen1Recomp Mods

Mods for [g1recomp](https://github.com/bryanthaboi/gen1recomp).

## HGSS Visual Overhaul

A visual pack for Pokemon Yellow. It replaces the intro portraits, adds HGSS
overworld charsets, and preserves the full-color party icons.

[Mod documentation, current screenshots and installation guide](hgss_sprites/README.md)

[Download HGSS_SPRITES 0.4.5](https://github.com/LucianoNeo/gen1recomp-mods/releases/tag/v0.4.5) - [All releases](https://github.com/LucianoNeo/gen1recomp-mods/releases)

### Outdoor Voxel 3D

Fresh in-game outdoor capture with the Voxel pipeline enabled:

![Red and Pikachu outdoors](hgss_sprites/docs/media/readme-voxel-outdoor-pikachu.png)

The selectable HGSS player sprites also work in the Voxel map renderer:

![Ash outdoors with Voxel enabled](hgss_sprites/docs/media/readme-voxel-ash.png)
![Ethan outdoors with Voxel enabled](hgss_sprites/docs/media/readme-voxel-ethan.png)

Ash and Ethan also have dedicated bicycle sheets, selected automatically when
the player mounts the bike.

Battle artwork is self-contained. `BATTLE ART SCOPE` selects `TRAINERS ONLY`
or `COMPLETE`, while the front/back/trainer generation selectors choose the
bundled Gen 1-5 collections. `PLAYER SELECT` also chooses the battle trainer
intro: RED, ASH or ETHAN. Missing files fall back to g1recomp's original
sprites.

### Battle Art Voxel Fork credit and scope

The battle asset library/content used by this mod was adapted from the public
[Battle Art Voxel Fork / DramaticShapeVoxelMod](https://github.com/absol89/DramaticShapeVoxelMod)
collections and conventions. Credit is due for the reused/adapted generation
organization, lowercase species/trainer slugs, animated atlas cell layout and
frame-timing metadata. Individual image sources are listed separately in the
battle asset notes.

The code audit found no runtime module import or manifest dependency on Battle
Art. However, the local resolver/atlas decoder/frame-timing path was
reimplemented from that project's battle-art architecture and is therefore
credited as adapted code, not presented as an unrelated original design. The
implementation lives in `hgss_sprites/main.lua`, uses g1recomp Mod API 2 and
operates on the bundled assets; Battle Art's HUD, trainer renderer and Voxel
runtime are not bundled. Battle Art is therefore not required by HGSS Visual
Overhaul; it is only an optional companion for users who want its separate
Voxel renderer. Missing files fall back to the original game assets. Image
sources and their credits are listed in
[`hgss_sprites/assets/battle/README.md`](hgss_sprites/assets/battle/README.md)
and the generation-specific notes.

### Gym captures

![Pewter Gym with Brock](hgss_sprites/docs/media/readme-voxel-gym-brock.png)
![Cerulean Gym with Misty](hgss_sprites/docs/media/readme-voxel-gym-misty.png)

### HGSS party icons

The party screen keeps the custom full-color HGSS icon set:

![HGSS party icons](hgss_sprites/docs/media/party-icons-hgss.png)
![Party menu with six Pokemon](hgss_sprites/docs/media/readme-party-icons.png)

### Oak catch fix and battle assets in 0.4.5

Version 0.4.5 fixes the scripted Oak/Pikachu catch battle and uses Oak's
full-color HGSS back sprite. Jessie and James now reuse the approved artwork
for generation 4 and generation 5 battle selections.

### PC box icons and character updates in 0.4.4

Version 0.4.4 adds animated full-color HGSS icons to PC withdraw, deposit and
release lists, with the reversible `PC BOX ICONS` option.

### Character and party updates in 0.4.3

Voxel grounding was corrected for the HGSS overworld replacements. The mod
menu offers `PLAYER SELECT` (`RED`, `ASH`, `ETHAN`), `PARTY MENU`
(`ON`/`OFF`), `PC BOX ICONS` (`ON`/`OFF`) and `SPRITE SIZE`
(`0.5x`-`1.0x` in `0.1x` steps). Sprite size
changes all overworld characters while preserving source quality and does not
alter battle art or party icons. Ash and Ethan keep a 28px logical footprint
so their map scale matches Red. Map-object replacements and legendary-bird
sprites use dedicated normal-palette HGSS sheets.

## Quick installation

1. `CRYSTAL_251` is an optional compatibility companion; no battle-art mod is required.
2. Download the HGSS_SPRITES ZIP from the release above.
3. Import it through the g1recomp mod manager and restart the game.

Package: `0.4.5` - Lean runtime package - Compatible with g1recomp
`>=0.1.75 <0.2.0` (tested on `0.1.78`).
