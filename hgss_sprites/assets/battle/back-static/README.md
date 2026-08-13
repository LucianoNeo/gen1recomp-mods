# Back static battle art

Drop `<species>.png` player back sprites into a generation subfolder. Art is
used as authored and is not mirrored; it should face right toward the
opponent. Files may use 96x96 pixel dimensions and require no Lua or metadata.

These local PNGs are ignored by Git. Missing or invalid files fall back to the
ROM sprite.

## Generation sets

`BACK ART SET` selects one of these generation subfolders:

- `back-static/gen1/<species>.png`
- `back-static/gen2/<species>.png`
- `back-static/gen3/<species>.png`
- `back-static/gen4/<species>.png`
- `back-static/gen5/<species>.png`

Under `BATTLE ART: STATIC`, all five choices read only these ordinary PNGs.
Static GEN5 never loads or decodes the similarly named animated GEN5 atlas.

Under `BATTLE ART: ANIMATED`, GEN 3 and GEN 5 use atlases from their
`back-animated` folders. GEN 1, GEN 2 and GEN 4 use these same single-frame
PNGs. If the selected file is absent or invalid, the ROM backsprite is used
instead. An absent `gen1` directory does
not remove GEN 1 from the menu; it is an intentional empty slot for ROM-hack
artwork to be dropped or other user-supplied artwork.

For a complete Gen 1 set with prepared transparency, the optional importer
downloads the 151 Pokemon Yellow Super Game Boy back sprites from
[Bulbagarden Archives](https://archives.bulbagarden.net/wiki/Category:Yellow_back_sprites_(Super_Game_Boy)):

```powershell
python tools/import_yellow_sgb_back_sprites.py --root .
```

It writes the source PNG bytes unchanged into `back-static/gen1`. The artwork
remains ignored by Git but is included by `tools/package_mod.ps1` in local test
ZIPs.

For Gen 3, `python tools/import_emerald_back_sprites.py --root .` copies the
151 Emerald `Spr b 3r` source PNGs byte-for-byte into `back-static/gen3` while
also preparing the separate animated `Spr b 3e` collection.

For Gen 2, `python tools/import_crystal_back_sprites.py --root .` queries the
[Crystal back-sprite category](https://archives.bulbagarden.net/wiki/Category:Crystal_back_sprites)
and copies its first 151 ordinary PNGs unchanged into `back-static/gen2`. The
importer discovers each species' mixed `Spr b 2c`, `Spr b 2g`, or `Spr b 2s`
archive prefix and excludes shiny and Japanese variants automatically.

For Gen 4, `python tools/import_platinum_back_sprites.py --root .` imports the
first 151 ordinary backs from the
[Platinum category](https://archives.bulbagarden.net/wiki/Category:Platinum_back_sprites).
It discovers both Platinum `Spr b 4p` files and reused Diamond/Pearl `Spr b
4d` files. When the archive provides a male/female pair, the male image is the
predictable Gen 1 default, matching the animated Gen 4 front importer.

For Gen 5, `python tools/import_black_white_static_back_sprites.py --root .`
copies the first 151 Black/White `back-normal` PNGs unchanged into
`back-static/gen5`. These files are used only by STATIC mode; ANIMATED + GEN 5
continues to read atlases from `back-animated/gen5`.

`BACK PLACEMENT` can override the layer for comparison. AUTO uses supplied
generation PNGs in the world and keeps a missing ANIMATED fallback on OG UI;
WORLD and OG UI force either presentation.

## Gen 1 filename exceptions

Most species use their ordinary lowercase name (`pikachu.png`). These four
engine names need the following exact filenames:

| Species | Expected filename | Do not use |
| --- | --- | --- |
| Mr. Mime | `mr-mime.png` | `mrmime.png`, `mr.mime.png` |
| Farfetchâ€™d | `farfetchd.png` | `farfetched.png`, `farfetch-d.png` |
| Nidoranâ™€ | `nidoran-f.png` | `nidoran.png`, `nidoran-female.png` |
| Nidoranâ™‚ | `nidoran-m.png` | `nidoran.png`, `nidoran-male.png` |

Filenames are lowercase. The same names apply in every battle-art folder.

## Static player-side trainer backs

This folder supplies the static player-side portraits used by the intro and as
fallbacks when a selected `PLAYER SELECT` battle strip is unavailable.
Professor Oak and Old Man remain static and always resolve here:

| Battle role | Expected filename |
|---|---|
| `PLAYER SELECT: RED` fallback | `player.png` |
| `PLAYER SELECT: ASH` fallback | `ashplayer.png` |
| `PLAYER SELECT: ETHAN` fallback | `gen2player.png` |
| Professor Oak in Yellow's opening battle | `oak.png` |
| Old Man catching tutorial | `old-man.png` |

These are intro trainer cards, not Pokemon species. A missing selected player strip tries the corresponding static fallback, then retains the ROM trainer backsprite. The player choice is independent of the Pokemon front/back generation selectors. Opponent trainers never read from a back folder.

When forced onto `BACK PLACEMENT: OG UI`, supplied player PNGs use their native
1x logical size at the normal left-side UI slot. Only the ROM player portrait
receives the engine's legacy 2x back-picture scale.
