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

## Still intentionally deferred

- HGSS-equivalent NPC/map object redirects and Johto tilesets.
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

Run the upstream checker from a Gen1Recomp checkout:

```powershell
python tools/modkit.py --repo . gen2check C:\path\to\hgss_sprites --notes
```

The checker must be run again after every new Gen 2 hook or registry patch.
The official migration guide is available at:
<https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Preparing-Your-Mod-For-Gen-2>.
