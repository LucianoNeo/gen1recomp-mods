# Changelog

## 0.2.2

- Removed the global `player.sprite` hook so Battle Art Voxel Fork exclusively
  selects and renders the player battle sprite.

## 0.2.1

- Removed all custom HUD registration and battle HUD draw hooks after
  compatibility issues in 2D and 3D battles.
- The base game/Battle Art Voxel Fork now owns borders, cursors, HP bars and
  all battle presentation.

## 0.2.0

- Battle Art Voxel Fork is now a recommended companion and owns all battle and
  voxel artwork.
- HGSS battle Pokemon, trainer portraits, party icons and player battle backs
  are no longer patched by this mod, preventing duplicate or oversized art.
- Kept the intro portraits, HGSS overworld charsets and the flat 2D HUD as
  this mod's supported visual scope.

## 0.1.0

- Jessie e James agora preservam os charsets em alta densidade, mantendo a
  caixa lógica, a escala e os movimentos do Red no overworld 2D e Voxel.
- Corrigidos os sprites do cientista e dos personagens dos Centros Pokémon,
  sem alterar globalmente a escala dos demais NPCs.
- Mantidas as correções de transparência, interface HGSS, barras de HP e
  compatibilidade com o `DRAMALESS_SHAPE`.
- Pacote runtime enxuto, sem fontes, ferramentas ou capturas de desenvolvimento.
