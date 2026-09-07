# Elm starter front animation

These are the Generation VI-style animated front sprites used only by the
starter Poképic in Elm's Lab (`CHIKORITA`, `CYNDAQUIL` and `TOTODILE`). Each
frame is a 64×64 RGBA PNG with nearest-neighbour rendering; the source pixels
are not palette-reduced or smoothed.

The frame sequences were converted from Pokémon Showdown's XY animated sprite
endpoints:

- `https://play.pokemonshowdown.com/sprites/xyani/chikorita.gif`
- `https://play.pokemonshowdown.com/sprites/xyani/cyndaquil.gif`
- `https://play.pokemonshowdown.com/sprites/xyani/totodile.gif`

The runtime advances the frame sequence while Elm's starter Poképic is open.
The Pokémon registry is not changed, so Pokédex, summary, battle and other
Poképic displays continue to use their existing assets.
