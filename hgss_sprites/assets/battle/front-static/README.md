# Static trainer front art

Only the HGSS trainer portraits under `hgss/` are bundled here. Both Gen 1 and
Gen 2 use this collection when `TRAINER ART: HGSS` is enabled; `ROM` restores
the original trainer picture. A missing class falls back to the ROM portrait.
Pokémon species fronts are supplied by the active Gen 5 animated collection,
not by this directory.

## Static opponent trainer fronts

Opponent trainer pictures are never animated. Both Gen 1 and Gen 2's
`TRAINER ART` option use the dedicated HGSS portraits for supported classes and
fall back to the ROM portrait when a class has no replacement. The filename is
the engine
trainer class in lowercase with underscores changed to hyphens:

youngster.png       bug-catcher.png     lass.png
sailor.png          jr-trainer-m.png    jr-trainer-f.png
pokemaniac.png      super-nerd.png      hiker.png
biker.png           burglar.png         engineer.png
fisher.png          swimmer.png         agatha.png
cue-ball.png        gambler.png         beauty.png
psychic-tr.png      rocker.png          juggler.png
tamer.png           bird-keeper.png     blackbelt.png
rival1.png          prof-oak.png        lance.png
scientist.png       giovanni.png        rocket.png
cooltrainer-m.png   cooltrainer-f.png   bruno.png
brock.png           misty.png           lt-surge.png
erika.png           koga.png            blaine.png
sabrina.png         gentleman.png       rival2.png
rival3.png          lorelei.png         channeler.png

Yellow's special Rocket pair uses `jessie-james.png`; other Rocket trainers
use `rocket.png`. A missing file in the selected set retains the ROM trainer
picture. The runtime does not borrow it from either of the retired generation
sets.

The Gen 2 HGSS class portraits are in `hgss/`.  In addition to the named Gym
Leaders and Elite Four, this directory covers every regular Crystal trainer
class whose overworld identity is redirected by `lib/Gen2Npc.lua`, including
`kimono-girl.png` and `sage.png`; battle portraits therefore no longer inherit
a different class's card when Battle Art is enabled.
