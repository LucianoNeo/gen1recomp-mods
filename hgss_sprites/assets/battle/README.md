# Optional Battle Art collections

This directory follows the Battle Art Voxel Fork layout. The generation
selectors in the HGSS mod are opt-in and fall back to the ROM/companion sprite
when a file is missing.

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
