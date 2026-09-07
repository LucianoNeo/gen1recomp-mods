# Gen 2 Pokémon overworld sheets

These six-frame sheets replace the Pokémon-specific overworld slots present in
the Gold/Silver/Crystal map registry.  The source is the original HGSS
follow-sprite collection shipped by the Wilds of Kanto companion mod
(YoDrehDenSwagAuf); the PNGs here were prepared from that collection by
nearest-neighbour crop/append only.

The source sheets are four-by-four atlases with 32×32 cells (64×64 for Lugia
and Ho-Oh). Source rows are down, left, right and up; source columns 0 and 2
are the standing and walking poses used here. The runtime sheet order is
`(column 0,row 0)`, `(0,3)`, `(0,1)`, then `(2,0)`, `(2,3)`, `(2,1)` — standing
down/up/side followed by walking down/up/side. The renderer mirrors the side
cell when it needs a right-facing pose. The original source pixels are kept at
their native cell size; 64px legendary cells are reduced only at draw time to
the same 32px logical map footprint.

The 0.2.45 Crystal pass covers the 78 Pokémon map objects represented by 40
species and every one of Crystal's 35 canonical overworld-Pokémon registry
slots. When Crystal reuses a generic `BIRD`, `MONSTER` or other slot, the mod
redirects only that map/object index to the species sheet; unrelated uses of
the generic slot, Wilds of Kanto `OW_WILD_*` records and all Gen 1 records
remain unchanged.

The Lake of Rage object is the scripted Red Gyarados (`RedGyarados`,
`EVENT_LAKE_OF_RAGE_RED_GYARADOS`).  It uses the private `130-shiny.png` sheet
made from the native 32px HGSS `rgyaradosu` field-animation cells; ordinary
Gyarados objects continue to use `130-normal.png`.

`131-surf.png` is the separate HGSS swimming-Lapras atlas used by Crystal's
`SPRITE_SURF` state and the Union Cave Lapras. Its original 64px frame canvases
and waterline pixels are preserved; the renderer applies the normal 32px
logical footprint only at draw time.

`185-normal.png` covers the Route 36 Sudowoodo resolved dynamically through
`SPRITE_VARS`, outside the sequential 35-slot Pokémon registry.

`095-normal.png` and `131-normal.png` also supply the optional large Onix and
Lapras bedroom dolls. A scoped Gen2 draw adapter presents the full HGSS frame
instead of feeding it through Crystal's GSC half-sheet mirroring routine.
