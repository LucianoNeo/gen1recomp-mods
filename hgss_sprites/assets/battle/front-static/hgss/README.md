# HGSS trainer battle portraits

This directory contains the 21 named HGSS major-trainer portraits plus the
class-specific portraits used by every Crystal map/object identity corrected
by `lib/Gen2Npc.lua`.  The regular classes include Bird Keeper, Boarder, Bug
Catcher, Burglar, Camper, Cooltrainer (the HGSS Ace Trainer equivalent),
Kimono Girl, both Rocket Executive roles, Firebreather, Guitarist, Hiker,
Juggler, Medium, Picnicker, Poké Maniac, Psychic, School Kid, Skier,
Sage, Swimmer♂ and Twins, in addition to Youngster, both Pokéfan roles and
Officer.

The compact Crystal class spellings are normalized at runtime.  `EXECUTIVEM`
uses the HGSS Archer portrait and `EXECUTIVEF` uses Ariana, matching the
corresponding HGSS overworld roles.  `COOLTRAINERM` uses HGSS Ace Trainer M,
the role that replaces Crystal's Cooltrainer in HGSS.  These are identity
matches, not substitutions with unrelated classes such as Super Nerd,
Juggler, Beauty or Rocket Grunt.

The source files are used at their authored dimensions without resampling.
Most are from the Smogon / Pokémon Showdown repository, directory
`src/_uncategorized/canonical/trainers/gen4/heartgold-soulsilver`, at commit
`0e1f57f4234f20b999dbb442dac1093b445e0088`:

https://github.com/smogon/sprites

The 80×80 class sheets for Guitarist, Hiker, Picnicker and Psychic are the
official HGSS-compatible entries documented in the
[Bulbagarden Generation IV trainer archive](https://archives.bulbagarden.net/wiki/Category:Generation_IV_Trainer_sprites).
They use the same class artwork in HeartGold/SoulSilver even though the
archive keeps some files under their original DP filename.

The Crystal-only identities below were added from the same pinned Showdown
HGSS collection (`0e1f57f4234f20b999dbb442dac1093b445e0088`):

| File(s) | HGSS source / mapping |
| --- | --- |
| `blackbelt.png` | `Blackbelt.png` |
| `cal.png` | `Ethan.png` (Cal uses Ethan's HGSS trainer portrait) |
| `champion` resolver alias | `lance.png` |
| `eusine.png` | `Eusine.png` |
| `red.png` | `Red.png` |
| `rocket-grunt-f.png`, `rocket-grunt-m.png` | `Rocket_Grunt~F.png`, `Rocket_Grunt.png` |
| `swimmer-f.png` | `Swimmer~F.png` |
| `teacher.png` | `Teacher.png` |

These mappings replace the generated Crystal fallback portraits for
`BLACKBELT_T`, `CAL`, `CHAMPION`, `MYSTICALMAN`, `RED`, `GRUNTF`, `GRUNTM`,
`SWIMMERF` and `TEACHER`.  The class-specific aliases are resolved in
`main.lua` without changing the source image dimensions.

## Gen1 compatibility portraits

The Gen1 trainer-art selector now has a portrait file for every legacy
`front-static/gen1` class.  The replacement files below come from the public
[Pokémon Showdown trainer collection](https://github.com/smogon/sprites/tree/master/src/trainers),
using modern or alternate-generation artwork rather than the canonical
FireRed/LeafGreen rip signatures checked by mod-scanner.  Each file is kept at
its authored dimensions; no smoothing or resampling is applied.

| File(s) | Showdown source variant |
| --- | --- |
| `agatha.png`, `lorelei.png` | `agatha-lgpe`, `lorelei-lgpe` |
| `beauty.png`, `biker.png`, `blackbelt.png`, `gentleman.png`, `gambler.png`, `lass.png`, `oak.png`, `psychic-tr.png`, `sailor.png`, `scientist.png`, `super-nerd.png`, `unused-juggler.png` | Modern default trainer artwork |
| `channeler.png` | `channeler-lgpe` |
| `chief.png`, `rocket.png` | `rocketgrunt` (Team Rocket equivalent) |
| `cooltrainer-f.png`, `jr-trainer-f.png` | `acetrainerf` (female equivalent) |
| `jr-trainer-m.png` | `acetrainer` (male equivalent) |
| `cue-ball.png` | `roughneck` (street-trainer equivalent) |
| `engineer.png` | `worker` (industrial-trainer equivalent) |
| `fisher.png` | `fisherman` |
| `giovanni.png` | `giovanni` |
| `prof-oak.png` | `oak` |
| `rival1.png`, `rival2.png`, `rival3.png` | `blue` |
| `rocker.png` | `guitarist` |
| `tamer.png` | `dragontamer` |
| `jessie-james.png` | Custom GBA/FRLG-style Jessie and James artwork by Ody-chan, cropped from the [GBA Jessie and James sheet](https://www.deviantart.com/ody-chan/art/GBA-Jessie-and-James-353030680) |

The Showdown repository notes that its game-derived sprites remain property of
Nintendo / Creatures / GAME FREAK; these alternatives are therefore not
claimed as CC0.  Credits and source links are retained here for attribution.
For a clean-room or freely licensed build, set Trainer Art to **ROM** instead
of distributing these game-derived portraits.

Pokémon character artwork belongs to Nintendo, Creatures Inc. and GAME FREAK.
