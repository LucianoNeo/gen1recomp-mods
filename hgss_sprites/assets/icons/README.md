# HGSS party/PC icons

Every PNG in this directory is a two-frame `32x64` sheet: two original
`32x32` overworld cells stacked vertically. The 100 Johto sheets (`152`–`251`)
were cropped from the corresponding normal sheets in the Wilds of Kanto
`assets/enhanced_overworld/followsprites` pack, preserving the source pixels
without scaling or filtering. The Kanto sheets use the same HGSS icon format
already shipped with this mod.

The `shiny/` subdirectory contains the matching 251 Crystal shiny sheets.
They were prepared from Wilds of Kanto's `assets/generated/true_size/hgss`
six-frame HGSS overworld package by taking the clean standing frame twice and
using nearest-neighbour scaling to the same 32x32 logical cells. The source's
transient sparkle overlay is omitted from these static menu icons. HGSS_SPRITES
uses these real shiny pixels in the Gen2 Party and PC menus whenever a record
is shiny; it does not recolor the normal icon at runtime. Source credit: Wilds
of Kanto, YoDrehDenSwagAuf.
