# Gen 2 NPC sprite inventory

This is the research inventory for the Gold/Silver/Crystal support branch. It
does not change the runtime registry yet and it does not claim that the Gen 2
NPC set is ready for release.

## Canonical sprite IDs

The Gen 2 extractor exposes 95 shared Gold/Silver overworld records (IDs
`SPRITE_CHRIS` through `SPRITE_SILVER_TROPHY`) and Crystal adds seven records:
`SPRITE_KRIS`, `SPRITE_KRIS_BIKE`, `SPRITE_KURT_OUTSIDE`, `SPRITE_SUICUNE`,
`SPRITE_ENTEI`, `SPRITE_RAIKOU`, and `SPRITE_STANDING_YOUNGSTER`.

The canonical source table is `rom_manifest_gold.json` plus the Crystal-only
tail in `rom_manifest_crystal.json`. These files define IDs and slot topology
only. The original Gen 2 graphics are reference material and must not be used
as runtime art. Runtime replacements must use the corresponding
HeartGold/SoulSilver overworld artwork.

### Shared Gold/Silver records

| ID | Source file |
|---:|---|
| 00 | `chris.png` |
| 01 | `chris_bike.png` |
| 02 | `gameboy_kid.png` |
| 03 | `rival.png` |
| 04 | `oak.png` |
| 05 | `red.png` |
| 06 | `blue.png` |
| 07 | `bill.png` |
| 08 | `elder.png` |
| 09 | `janine.png` |
| 10 | `kurt.png` |
| 11 | `mom.png` |
| 12 | `blaine.png` |
| 13 | `reds_mom.png` |
| 14 | `daisy.png` |
| 15 | `elm.png` |
| 16 | `will.png` |
| 17 | `falkner.png` |
| 18 | `whitney.png` |
| 19 | `bugsy.png` |
| 20 | `morty.png` |
| 21 | `chuck.png` |
| 22 | `jasmine.png` |
| 23 | `pryce.png` |
| 24 | `clair.png` |
| 25 | `brock.png` |
| 26 | `karen.png` |
| 27 | `bruno.png` |
| 28 | `misty.png` |
| 29 | `lance.png` |
| 30 | `surge.png` |
| 31 | `erika.png` |
| 32 | `koga.png` |
| 33 | `sabrina.png` |
| 34 | `cooltrainer_m.png` |
| 35 | `cooltrainer_f.png` |
| 36 | `bug_catcher.png` |
| 37 | `twin.png` |
| 38 | `youngster.png` |
| 39 | `lass.png` |
| 40 | `teacher.png` |
| 41 | `beauty.png` |
| 42 | `super_nerd.png` |
| 43 | `rocker.png` |
| 44 | `pokefan_m.png` |
| 45 | `pokefan_f.png` |
| 46 | `gramps.png` |
| 47 | `granny.png` |
| 48 | `swimmer_guy.png` |
| 49 | `swimmer_girl.png` |
| 50 | `big_snorlax.png` |
| 51 | `surfing_pikachu.png` |
| 52 | `rocket.png` |
| 53 | `rocket_girl.png` |
| 54 | `nurse.png` |
| 55 | `link_receptionist.png` |
| 56 | `clerk.png` |
| 57 | `fisher.png` |
| 58 | `fishing_guru.png` |
| 59 | `scientist.png` |
| 60 | `kimono_girl.png` |
| 61 | `sage.png` |
| 62 | `unused_guy.png` |
| 63 | `gentleman.png` |
| 64 | `black_belt.png` |
| 65 | `receptionist.png` |
| 66 | `officer.png` |
| 67 | `cal.png` |
| 68 | `slowpoke.png` |
| 69 | `captain.png` |
| 70 | `big_lapras.png` |
| 71 | `gym_guide.png` |
| 72 | `sailor.png` |
| 73 | `biker.png` |
| 74 | `pharmacist.png` |
| 75 | `monster.png` |
| 76 | `fairy.png` |
| 77 | `bird.png` |
| 78 | `dragon.png` |
| 79 | `big_onix.png` |
| 80 | `n64.png` |
| 81 | `sudowoodo.png` |
| 82 | `surf.png` |
| 83 | `poke_ball.png` |
| 84 | `pokedex.png` |
| 85 | `paper.png` |
| 86 | `virtual_boy.png` |
| 87 | `old_link_receptionist.png` |
| 88 | `rock.png` |
| 89 | `boulder.png` |
| 90 | `snes.png` |
| 91 | `famicom.png` |
| 92 | `fruit_tree.png` |
| 93 | `gold_trophy.png` |
| 94 | `silver_trophy.png` |

### Crystal-only records

| ID | Source file |
|---:|---|
| 95 | `lyra.png` (HGSS replacement for native `SPRITE_KRIS`) |
| 96 | `lyra_bike.png` (HGSS replacement for native `SPRITE_KRIS_BIKE`) |
| 97 | `kurt_outside.png` |
| 98 | `suicune.png` |
| 99 | `entei.png` |
| 100 | `raikou.png` |
| 101 | `standing_youngster.png` |

### Non-NPC sprite records that still need a policy

The Gen 2 sprite table continues at `SPRITE_POKEMON` with 35 overworld-mon
slots (`SPRITE_UNOWN` through `SPRITE_HO_OH`). The event engine also resolves
day-care monsters and the `SPRITE_VARS` slots (console, dolls, Sudowoodo,
Copycat, and other map-specific aliases) at runtime. These must not be
replaced by a generic NPC sheet.

## HGSS source quality and conversion notes

- The primary downloaded collection is `.local/Gen4-OWs-v1.5/`. It contains
  HGSS and DPPt sheets with 32-pixel cells arranged in 256×256 sheets (plus
  larger/special sheets), with true-color RGBA art and directional walk
  frames. Only visually identified HGSS sheets may be selected.
- Individually named HGSS candidates are in `.local/bulbagarden-hgss/`.
- The eventual Gen 2 adapter must crop each selected HGSS sheet into the
  engine's true-color format (normally 32×192 with six 32×32 frames), preserve
  frame order, and set `spriteType`, `walker`, and anchors per record. Special
  objects must keep their non-walker type.
- No HGSS NPC source image has been copied into the tracked mod yet. The
  downloaded sheets remain local until each mapping is visually reviewed.

## Current mod coverage

The tracked Yellow/HGSS override directory currently has **34 exact filename
matches out of the 102 canonical Gen 2 overworld IDs**. Examples include
`SPRITE_OAK`, `SPRITE_RED`, `SPRITE_BLUE`, `SPRITE_ROCKET`, `SPRITE_SCIENTIST`,
and `SPRITE_BIKER`. Other files are close candidates with a different naming or
role (`blackbelt` vs `black_belt`, `gym_*` vs a canonical Gym Leader, or a
generic `swimmer` sheet where Gen 2 has separate male/female IDs), but they
must be reviewed visually and assigned deliberately. A matching filename is
not proof that the art, frame order, or dimensions are correct.

The visual review sheets are local-only:

- `.local/gen2-npc-contact-sheet.png` — the complete original Gen 2 source
  sheet set, retained for ID reference only; never use it as runtime art.
- `.local/gen2-current-candidates.png` — the current HGSS candidates and
  aliases that may be considered later.
- `.local/hgss-npc-hgss-collection-contact-sheet.png` — visual check of the
  downloaded HGSS overworld collection.

## Visual verification

The complete source contact sheet (84 walking/standing sheets, with the still
objects catalogued above) is generated locally at:

`.local/gen2-npc-contact-sheet.png`

The reference checkout is local-only and ignored by Git:

`.local/pokecrystal/gfx/sprites/`

## Next implementation slice

1. Map each canonical Gen 2 ID to a visually matching HGSS sheet.
2. Convert and visually review the shared trainer/NPC sheets in batches.
3. Register one canonical ID at a time through the Gen 2 sprite registry.
4. Validate Gold, Silver, and Crystal separately, including event-variable
   sprites and the 35 overworld Pokémon slots.
5. Only after visual and runtime checks should the assets move from `.local`
   into `hgss_sprites/assets/gen2/` and be considered for a commit.
