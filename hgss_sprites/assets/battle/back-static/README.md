# Static battle backs

This directory contains only static player-side trainer portraits and the
special intro/tutorial portraits. Pokémon backs come from the active Gen 5
animated atlas when selected, or fall back to the original game artwork. Gen 2
Pokémon battles likewise retain their native artwork. Missing or invalid files
always fall back to the ROM sprite.

## Static player-side trainer backs

This folder supplies the static player-side portraits used by the intro and as
fallbacks when a selected `PLAYER SELECT` battle strip is unavailable.
Professor Oak and Old Man remain static and always resolve here:

| Battle role | Expected filename |
|---|---|
| `PLAYER SELECT: RED` fallback | `player.png` |
| `PLAYER SELECT: ASH` fallback | `ashplayer.png` |
| `PLAYER SELECT: ETHAN` fallback | `gen2player.png` |
| `PLAYER SELECT: LYRA` fallback | `lyraplayer.png` |
| `PLAYER SELECT: LEAF` fallback | `leafplayer.png` |
| `PLAYER SELECT: BRENDAN` fallback | `brendanplayer.png` |
| Professor Oak in Yellow's opening battle | `oak.png` |
| Crystal Ace Trainer catching tutorial | `ace-trainer.png` (five Battle Art frames in `../back-animated/ace-trainer.png`) |

These are intro trainer cards, not Pokémon species. A missing selected player
strip tries the corresponding static fallback, then retains the ROM trainer
backsprite. The player choice is independent of Pokémon artwork. Opponent
trainers never read from a back folder.

When forced onto `BACK PLACEMENT: OG UI`, supplied player PNGs use their native
1x logical size at the normal left-side UI slot. Only the ROM player portrait
receives the engine's legacy 2x back-picture scale.
