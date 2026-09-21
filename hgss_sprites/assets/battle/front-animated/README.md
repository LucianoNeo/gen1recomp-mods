# Front animated battle art

Only the Gen 5 animated opponent atlases are bundled here. They are split
into ordinary and shiny collections under `gen5/`; the current menu exposes
this set as `GEN 5 ANIMATED`. Gen 1 and Gen 2 battles use the native artwork
when this set does not apply, and no retired Gen1–Gen4 collection is shipped.

GIF decoding is authoring-only. The game reads PNG atlases, extracts every
cell at its native logical resolution, and uses nearest-neighbour filtering.
The importer creates the Gen 5 atlas and its shared metadata; users do not
write one Lua file per Pokémon. From the repository root, run
`python tools/import_animated_sprites.py --set gen5` to regenerate it from
the credited Black/White source artwork.

## Gen 1 filename exceptions

Most species use their ordinary lowercase name (`pikachu.png`). These four
engine names need the following exact filenames:

| Species | Expected filename | Do not use |
| --- | --- | --- |
| Mr. Mime | `mr-mime.png` | `mrmime.png`, `mr.mime.png` |
| Farfetch’d | `farfetchd.png` | `farfetched.png`, `farfetch-d.png` |
| Nidoran♀ | `nidoran-f.png` | `nidoran.png`, `nidoran-female.png` |
| Nidoran♂ | `nidoran-m.png` | `nidoran.png`, `nidoran-male.png` |

Filenames are lowercase. These names apply to the Gen 5 battle-art folder.

Opponent trainer front pictures can never be animated and are not read from
this folder. Put every opponent trainer PNG in `../front-static/`.
