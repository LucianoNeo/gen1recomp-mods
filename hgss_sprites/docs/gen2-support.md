# Gen 2 support (feature branch)

This branch starts the Gold/Silver/Crystal compatibility work. It is not a
release claim yet: Yellow remains the fully exercised target, while Gen 2 is
being brought up in small, testable slices.

## Implemented in phase 1

- The manifest advertises `gen1` and `gen2`, so the Gen 2 loader can validate
  the package instead of treating it as a Yellow-only mod.
- Gen 2 is detected through `src.core.GameVersion` and all Yellow-only map,
  tile, party, intro, battle-state, and voxel-internals patches are skipped on
  Gold/Silver/Crystal.
- The Gen 2 sprite registry receives the authored player sheets through the
  native IDs `SPRITE_CHRIS`, `SPRITE_CHRIS_BIKE`, `SPRITE_KRIS`,
  `SPRITE_KRIS_BIKE`, and `SPRITE_SURFING_PIKACHU`.
- Six 32×32 RGBA frames are provided by the canonical `overrides/sprites/`
  charset set. Gen-2 and Gen-1 now resolve the same source files, with no
  duplicate compact overworld asset tree.
- The Gen2-native PartyMenu and BoxMenu now receive the same optional HGSS
  party/PC icon treatment as Gen1. Bundled species use animated true-colour
  icons at the native 16px menu footprint. When the option is enabled, BoxMenu
  owns the complete transfer panel, so its large native front-static preview
  and GSC icon layer are suppressed. All 251 National Dex species now have a
  two-frame HGSS icon sheet; the 100 Johto sheets are sourced from Wilds of
  Kanto's original 32x32 overworld cells without resampling. Gen1's icon
  registry remains unchanged.

## Gold / Silver / Crystal intro slice

The first shared Gen 2 visual slice replaces only the four portraits used by
the Oak opening speech in Gold, Silver and Crystal, without changing the
screen's timing, text, layout, or animation code:

| Gen 2 role | Runtime asset | Source style |
|---|---|---|
| Professor Oak | `assets/gen2/intro/oak.png` | HGSS true-colour trainer |
| Demo Pokémon (Wooper) | `assets/gen2/intro/wooper.png` | HGSS normal (non-shiny) Pokémon |
| Male player (Ethan) | `assets/gen2/intro/ethan.png` | HGSS true-colour trainer |
| Female player (Lyra) | `assets/gen2/intro/lyra.png` | HGSS true-colour trainer |
| Kris player option | `overrides/sprites/kris.png`, `kris_bike.png` | Six-frame overworld/bicycle sheets generated from the supplied Kris pack |

The native female slot is named `SPRITE_KRIS` in Crystal and uses the matching
female player slot in the other Gen 2 builds, but the intro artwork is always
the HeartGold/SoulSilver Lyra equivalent. The optional `PLAYER SELECT > KRIS`
choice uses the supplied Kris overworld sheets for the active player. The four PNGs use transparency, nearest filtering, and
the intro's 7×7-cell logical canvas (56 pixels high); the Oak image keeps its
narrower aspect ratio so the coat is not stretched.

The canonical Gen 2 sprite table is used only to identify Gold/Silver/Crystal
sprite slots. Runtime art must come from HeartGold/SoulSilver equivalents;
the original Gen 2 sheets are reference material and must not be copied into
the mod.

## Verified Gen 2 NPC redirect pass

The missing trainer/person slots were audited against the official
[Bulbagarden overworld-trainer archive](https://archives.bulbagarden.net/wiki/Category%3AOverworld_Trainer_sprites)
and then compared in a local contact sheet before being registered.  The
runtime now redirects the verified Crystal roles below to the corresponding
HGSS-quality asset (the same mapping is used by Gold and Silver):

`Beauty`, `Biker`, `Black Belt`, `Bill`, `Blaine`, `Blue`, `Brock`, `Bruno`,
`Bug Catcher`, `Bugsy`, `Cal`, `Captain`, `Chuck`, `Clair`, `Clerk`, `Cooltrainer M`,
`Daisy`, `Dragon Clan Elder`, `Elm`, `Erika`, `Falkner`, `Fishing Guru`,
`Gameboy Kid`, `Gentleman`, `Gramps`, `Granny`, `Gym Guide`, `Janine`,
`Jasmine`, `Karen`, `Kimono Girl`, `Koga`, `Kurt` (including the outside
slot), `Lance`, `Lass`, `Link Receptionist`, `Misty`, `Morty`, `Nurse`, `Oak`,
`Officer`, `Old Link Receptionist`, `Pharmacist/Burglar`, `Pokéfan M`,
`Pryce`, `Receptionist`, `Red`, `Red's Mom`, `Rocker`, `Rocket` and
`Rocket Girl`, `Sabrina`, `Sage`, `Sailor`, `Super Nerd`, `Lt. Surge`,
`Swimmer F/M`, `Twin`, `Unused Guy`, `Whitney`, `Will`, and both Youngster
slots.

The player, Mom, female Pokéfan, female Cooltrainer, Scientist, Fisher and
Rival mappings remain the explicit user-curated overrides installed by the
Gen 2 player slice.  Generic `BIRD`, `MONSTER` and `POKE_BALL` records, the
Wilds of Kanto `OW_WILD_*` follower records and encounter data remain native;
only the species-specific map slots listed in the Pokémon pass below are
redirected. The generic `RECEPTIONIST` uses the extracted official HGSS
`GSWOMAN6` receptionist sheet. Crystal's shared `PHARMACIST` record uses the
official HGSS `SUNGLASSES` character for Cianwood Pharmacy and its civilian
placements, including the three Kanto objects in Celadon. The three actual
Burglar trainers are redirected by map/object index to HGSS Burglar. Trainer
House Cal is placed through `SPRITE_CHRIS` in Crystal, so that single object is
redirected to the male HGSS Ace Trainer. The
four Battle Tower attendant objects are separately redirected to HGSS
`BFSW1`, rather than inheriting the general-purpose `GSWOMAN6` sheet.
`UNUSED_GUY` and `OLD_LINK_RECEPTIONIST` are not instantiated through their
dedicated slots by vanilla Crystal, but their registry entries are also
redirected so external scripts cannot fall back to native GSC artwork.

The archive's 256×256 four-row sheets are converted to the six-cell walker
contract without palette reduction: standing down/up/side followed by walking
down/up/side.  Each selected 64×64 source cell is nearest-neighbour expanded
into a 256×256 frame, preserving the authored HGSS pixels and transparency.
No frame is populated by repeating a single facing.  The resulting files are
listed in `overrides/sprites/` with a `_gen2` suffix where they coexist with a
Yellow asset.  The visual audit contact sheet is kept local at
`.local/gen2-missing-official-contact.jpg`.

## Verified Gen 2 Pokémon overworld pass

The 0.2.45 Crystal map audit covers 78 Pokémon objects across 40 species.  It
uses six-frame true-colour HGSS follow-sprite sheets under
`assets/gen2/pokemon-overworld/`:

`Abra`, `Ampharos`, `Bayleef`, `Big Snorlax`, `Blissey`, `Butterfree`,
`Clefairy`, `Diglett`, `Dodrio`, `Doduo`, `Dragonite`, `Dratini`, `Electrode`,
`Entei`, `Farfetch'd`, `Fearow`, `Gyarados`, `Ho-Oh`, `Jigglypuff`, `Lugia`,
`Machop`, `Meowth`, `Miltank`, `Murkrow`, `Nidoran♀`, `Nidoran♂`, `Nidorino`,
`Persian`, `Pidgey`, `Pikachu`, `Poliwrath`, `Psyduck`, `Raikou`, `Rattata`,
`Rhydon`, `Slowbro`, `Slowpoke`, `Spearow`, `Suicune` and `Zubat`.

Crystal's complete 35-slot Pokémon sprite registry (`SPRITE_UNOWN` through
`SPRITE_HO_OH`) is also replaced. This closes the direct script/`SPRITE_VARS`
path that could still resolve native GSC artwork even though every statically
placed map object was already covered. The additional HGSS sheets are
`Bulbasaur`, `Charmander`, `Squirtle`, `Weedle`, `Paras`, `Geodude`,
`Tentacool`, `Grimer`, `Shellder`, `Gengar`, `Starmie`, `Magikarp`, `Lapras`,
`Togepi` and `Unown`; the other 20 canonical slots reuse HGSS sheets that were
already bundled. This registry write remains inside the Gen2 gate.

The separate `SPRITE_SURF` state uses `131-surf.png`, generated from Wilds of
Kanto's HGSS swimming-Lapras atlas. Its six directional frames retain the
authored foam/waterline animation and are used both while the player is
mounted and by the Union Cave Lapras object.

Sudowoodo is not one of the 35 sequential Pokémon slots: Route 36 resolves it
through `SPRITE_VARS` into `SPRITE_SUDOWOODO`. That special record is also
patched to the HGSS `185-normal.png` sheet.

The optional large Onix and Lapras bedroom dolls use the same species-matched
HGSS sources. Crystal's native big-doll renderer expects a GSC half-sheet, so a
Gen2-only adapter draws one complete 32px HGSS frame for those two marked
records while leaving Snorlax and every non-Pokémon decoration unchanged.

The source cells come from Wilds of Kanto's original HGSS follow-sprite
collection and are cropped/stacked without recolouring or resampling.  The
renderer keeps the 64px source cells for Lugia and Ho-Oh and applies only the
normal 32px logical map footprint at draw time.  Shared generic slots are
redirected by map/object index, so dolls and story Pokémon get their actual
species without changing unrelated `BIRD`/`MONSTER`/`POKE_BALL` objects;
Yellow/Red/Blue sprite records and the companion `OW_WILD_*` resolver are not
modified.

## Still intentionally deferred

- Johto tilesets and map geometry replacement.
- Gen 2 battle trainer portraits and battle UI replacements.
- Full Gold/Silver/Crystal runtime capture validation beyond this intro slice.
  The static checker is a guardrail, not proof that every screen is correct.

## HGSS source collection

The downloaded HGSS references remain local-only while mappings are reviewed:

- `.local/Gen4-OWs-v1.5/` — collection containing HGSS and DPPt overworld
  sheets; only the visually identified HGSS subset is eligible for this mod.
- `.local/bulbagarden-hgss/` — individually named HGSS overworld candidates.

## Validation

### Standard overworld-sheet conversion

Use `tools/convert_hgss_overworld_sheet.py` for every new HGSS character
sheet. It recognizes the common 256×256 (4×4 cells) and 128×128 layouts and
emits the mod's 32×192 six-frame contract. The source rows are down, left,
right, up; column 0 is the standing pose and column 1 is the walking pose.
The generated order is standing down/up/side followed by walking
down/up/side. Nearest-neighbor resampling preserves hard pixel edges, and
already converted 32×192 or 256×1536 sheets are copied unchanged.

The player sources are a documented exception to the ordinary NPC atlas
layout. Use Uranium `HGSS_069` for Ethan and `HGSS_070` for Lyra on foot, and
select their six cells by visual direction (front, back, side, then the three
walking phases). Do not transpose these sheets as if every row were a single
direction. The bicycle sources are `HGSS_071` and `HGSS_072`; their special
packing is likewise mapped explicitly by the local player rebuild helper.

```powershell
python tools/convert_hgss_overworld_sheet.py \
  .local/uranium-hgss-source/hgss-characters/HGSS_058.png \
  hgss_sprites/overrides/sprites/silver.png
```

Run the upstream checker from a Gen1Recomp checkout:

```powershell
python tools/modkit.py --repo . gen2check C:\path\to\hgss_sprites --notes
```

The checker must be run again after every new Gen 2 hook or registry patch.
The official migration guide is available at:
<https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Preparing-Your-Mod-For-Gen-2>.
