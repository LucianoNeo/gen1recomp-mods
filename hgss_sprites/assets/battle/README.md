# Battle asset collections and compatibility credit

This directory is a self-contained collection for HGSS Visual Overhaul. Its
asset library/content and public layout were adapted from the [Battle Art Voxel
Fork](https://github.com/absol89/DramaticShapeVoxelMod) collections and
conventions: generation folders, lowercase species/trainer slugs, animated
atlas cell geometry and timing-table metadata. That asset-library reuse is
credited here; the HGSS mod's own resolver selects these files and falls back to
the ROM sprite when a file is missing.

No Battle Art runtime module is imported as a dependency, and no Battle Art HUD,
trainer renderer or Voxel runtime is bundled here. The resolver, atlas decoder
and animation/rendering adapters in `../../main.lua` were reimplemented from
Battle Art's battle-art architecture and are credited as adapted code. Battle
Art is not a manifest dependency; it is an optional companion only for users
who want its separate Voxel renderer.

```text
front-animated/gen5/<pokemon>.png
front-animated/gen5/shiny/<pokemon>.png
back-animated/gen5/<pokemon>.png
back-animated/gen5/shiny/<pokemon>.png
```

Only the Gen 5 animated Pokémon atlases are exposed by the current menu. The
engine's native artwork remains the `ROM` option (and is used automatically
when a Gen 5 species is missing). Static trainer art is separate: `TRAINER
ART` can select the bundled HGSS portrait collection for both Gen1 and Gen2,
or `ROM` to restore the original portraits. The HGSS collection now includes
a file for every legacy Gen1 trainer class; its identity-specific additions
and their sources are listed in
[`front-static/hgss/README.md`](front-static/hgss/README.md).

The corresponding `animated_battle_sprites_gen5.lua` and
`animated_battle_sprites_gen5_shiny.lua` files contain the atlas dimensions,
frame counts and timing metadata needed to animate the shipped collection
without loading Battle Art at runtime. The retired Gen2–Gen4 Battle Art
collections are intentionally not bundled; those games fall back to their
native artwork when the active collection does not apply.

The player battle trainer is selected by the HGSS mod's `PLAYER SELECT` option:
`RED` uses `redplayer.png`, `ASH` uses `ashplayer.png`, `ETHAN` uses the
`gen2player.png` strip, `LYRA` uses `lyraplayer.png`, `LEAF` uses
`leafplayer.png`, and `BRENDAN` uses `brendanplayer.png`. Leaf's player artwork
(battle, overworld and bicycle) is credited to `setogabes` on Discord. These
strips are bundled and do not require Battle Art Voxel Fork.

`TRAINER ART` offers `HGSS` (the credited `front-static/hgss` collection) or
`ROM` for both Gen1 and Gen2. Every legacy Gen1 trainer class has a bundled
HGSS-compatible portrait; still-unsupported Gen2 classes fall back to the
original game portrait.

## Source and attribution notes

The adapted Battle Art asset-library/layout convention is credited above. The
image collections themselves retain their separate source credits in each
generation directory. Trainer alternatives in `front-static/hgss/` include
the public Pokémon Showdown trainer collection and the Ody-chan Jessie/James
sheet; the exact variants are listed in that directory's `README.md`. The
included files are used as authored and are not claimed as original artwork by
this project.
