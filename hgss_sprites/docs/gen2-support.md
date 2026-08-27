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

The native female slot is named `SPRITE_KRIS` in Crystal and uses the matching
female player slot in the other Gen 2 builds, but the intro artwork is always
the HeartGold/SoulSilver Lyra equivalent. No original Gen 2 or Kris artwork is
copied into the mod. The four PNGs use transparency, nearest filtering, and
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
`Bug Catcher`, `Bugsy`, `Captain`, `Chuck`, `Clair`, `Clerk`, `Cooltrainer M`,
`Daisy`, `Dragon Clan Elder`, `Elm`, `Erika`, `Falkner`, `Fishing Guru`,
`Gameboy Kid`, `Gentleman`, `Gramps`, `Granny`, `Gym Guide`, `Janine`,
`Jasmine`, `Karen`, `Kimono Girl`, `Koga`, `Kurt` (including the outside
slot), `Lance`, `Lass`, `Link Receptionist`, `Misty`, `Morty`, `Nurse`, `Oak`,
`Officer`, `Pokéfan M`, `Pryce`, `Red`, `Red's Mom`, `Rocker`, `Rocket` and
`Rocket Girl`, `Sabrina`, `Sage`, `Sailor`, `Super Nerd`, `Lt. Surge`,
`Swimmer F/M`, `Twin`, `Whitney`, `Will`, and both Youngster slots.

The player, Mom, female Pokéfan, female Cooltrainer, Scientist, Fisher and
Rival mappings remain the explicit user-curated overrides installed by the
Gen 2 player slice.  No Pokémon or map-object slot is redirected: `BIRD`,
`MONSTER`, the fossil/legendary/object IDs, and encounter sprites retain the
Crystal registry.  `PHARMACIST` and the generic `RECEPTIONIST` are also left
native because no unambiguous HGSS archive equivalent was found; substituting
a nurse or clerk there would create the wrong character in several maps.

The archive's 256×256 four-row sheets are converted to the six-cell walker
contract without palette reduction: standing down/up/side followed by walking
down/up/side.  Each selected 64×64 source cell is nearest-neighbour expanded
into a 256×256 frame, preserving the authored HGSS pixels and transparency.
No frame is populated by repeating a single facing.  The resulting files are
listed in `overrides/sprites/` with a `_gen2` suffix where they coexist with a
Yellow asset.  The visual audit contact sheet is kept local at
`.local/gen2-missing-official-contact.jpg`.

## Still intentionally deferred

- Johto tilesets and map geometry replacement.
- Gen 2 battle trainer portraits and battle UI replacements.
- Gen 2 party/PC icon presentation and Pokédex/Hall of Fame screens.
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
