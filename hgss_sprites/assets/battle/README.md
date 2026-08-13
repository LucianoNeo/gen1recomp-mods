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
front-animated/<gen1|gen2|gen3|gen4|gen5>/<pokemon>.png
back-static/<gen1|gen2|gen4>/<pokemon>.png
back-animated/<gen3|gen5>/<pokemon>.png
front-static/<gen1|gen2|gen3>/<trainer>.png
```

The player battle trainer is selected by the HGSS mod's `PLAYER SELECT` option:
`RED` uses `redplayer.png`, `ASH` uses `ashplayer.png`, and `ETHAN` uses the
Battle Art-compatible `gen2player.png` strip. These three strips are bundled
and do not require Battle Art Voxel Fork. Missing Pokemon art still falls back
to the ROM sprite.

## Source and attribution notes

The adapted Battle Art asset-library/layout convention is credited above. The image collections
themselves retain their separate source credits in each generation directory;
these include Bulbagarden Archives, Pokémon Database, PKMN.NET and Blue Moon
Falls where indicated by the corresponding `README.md` files. The included
files are used as authored and are not claimed as original artwork by this
project.
