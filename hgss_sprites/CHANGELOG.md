# Changelog

## 1.0.0

- Replaced the baked seated visitor in every Pokémon Center and the Celadon
  Hotel with the full-color HGSS Little Boy overworld sprite, while retaining
  the original sofa scene and Voxel presentation.
- Preserved the original bench-guy interaction and dialogue by keeping the
  visual replacement separate from the hidden event cell.
- Added the cleaned Pokémon Center tileset/block patch so the old baked figure
  cannot reappear as a duplicate 2D or Voxel object.
- Applied the active world-lighting tint to custom overworld cards so trainers
  and followers react consistently to day/night shading.
- Kept the complete HGSS trainer, Pokémon, shiny, party and PC icon options
  available with `TRAINERS ONLY` as the default battle scope.

## 0.6.4

- Fixed Leaf and Brendan overworld and bicycle sheets being sampled as 32x32
  frames even though their authored assets are 256x1536. Full 256x256 frames
  are now used without resampling, preserving proportions and walking poses in
  the flat renderer.
- Added the dedicated Fearow overworld sheet for the Celadon Fly House while
  keeping ordinary bird objects unchanged.
- Corrected the Victory Road Blackbelt map object and kept the modern selected
  front/back artwork in the Hall of Fame, including the player trainer choice.

## 0.6.3

- Fixed the three Viridian Gym Blackbelt map objects, which were incorrectly
  inheriting the Hiker charset because Yellow names them `HIKER1` through
  `HIKER3` despite their Blackbelt trainer class.
- Fixed the Power Plant Zapdos map object to use the dedicated animated HGSS
  Zapdos sheet. Its redirect was being lost when the Power Plant object-fix
  table was redeclared for the Voltorb and Electrode objects.
- Verified the dedicated Articuno, Moltres and Mewtwo map-object redirects and
  preserved their full-color six-frame sheets.

## 0.6.2

- Adjusted the default Voxel grounding offset from `-4` to `-1` for a closer
  match between overworld character feet and the ground plane.
- Raised the mod manifest priority to `150` so its visual overrides are applied
  deterministically alongside other graphics mods.

## 0.6.1

- Fixed Leaf and Brendan battle player selection so their dedicated battle
  portraits are used instead of falling back to Red.
- Verified the corrected trainer artwork in battles with the Voxel renderer
  enabled.

## 0.6.0

- Added the updated Brendan overworld charset and bicycle charset.
- Added the updated Leaf bicycle charset and synchronized the available player
  bicycle assets for the supported player selections.
- Preserved six-direction walking animation, transparent backgrounds and the
  existing voxel grounding/scale behavior for the new sheets.

## 0.5.9

- Fixed real-time option responsiveness for `SPRITE SIZE`, prioritizing active Mod Manager slider values over stale save states so scale changes apply immediately without restarting the game.

## 0.5.8

- Major overworld render loop performance optimizations: converted animation frame mapping tables to module constants and eliminated `pcall(require, "Pipelines")` from `SpriteRenderer.draw`, reducing heap allocation to zero bytes per entity frame.
- Implemented global alpha-bound caching (`hgssFrameBottomsCache`) for sprite sheets, speeding up NPC instantiation and map transitions by over 45x.
- Added cached option reads for `overworldSpriteScale` with clean invalidation on option changes.
- Cached Party and PC Box icon Quad instances, removing per-frame quad allocations in menus.

## 0.5.7

- Corrected overworld sprite orientations across all character sheets to match the standard 6-frame layout (`red.png`), fixing inverted back-standing/back-walking frames and removing extraneous right-facing profile frames.
- Updated `silph_worker_f` overworld sprite with authentic female trainer artwork.
- Expanded engine compatibility range (`>=0.1.75 <10.0.0`) in `manifest.json` ensuring seamless support for g1recomp v0.2.1+ and future engine releases.

## 0.5.6

- Added full-color shiny battle artwork for the supported Gen 1 through Gen 5
  front collections, with animated or static shiny backs where available.
- Made the custom Surfing Pikachu sprite the default for every overworld Surf
  ride, so it no longer depends on having the event-only Surf move on Pikachu.
- Kept the normal `TRAINERS ONLY` battle scope as the default.

## 0.5.5

- Updated the full-color animated surfing Pikachu overworld sprite.
- Kept `BATTLE ART SCOPE` at `TRAINERS ONLY` by default; Pokémon battle art
  remains opt-in through the existing `COMPLETE` choice.

## 0.5.4

- Corrected the SS Anne Wigglytuff map object with a full directional HGSS
  overworld sheet and proper voxel grounding.
- Grounded both Route 12 and Route 16 Snorlax map obstructions at 2x scale so
  they cover their entrances without floating or sinking into the floor.
- Verified the updated overworld objects with Battle Art Voxel Fork 1.9.0.

## 0.5.3

- Fixed the evolution movie to use the selected bundled front-generation
  artwork for both forms instead of always loading the original Yellow
  sprites.
- Cropped animated battle atlases to one native frame during evolution while
  preserving full-color rendering.
- Fixed the HGSS party cursor to navigate the two-column layout with left,
  right, up and down instead of treating it as a single vertical list.

## 0.5.2

- Corrected Cerulean's Electrode and the Fuchsia/Power Plant Voltorb map
  objects, which were still using the generic Poké Ball artwork.
- Added dedicated full-color HGSS Electrode and Voltorb overworld sheets for
  those map objects without changing ordinary Poké Ball item sprites.

## 0.5.1

- Fixed level-100 party status placement so `PAR` and `FNT` no longer overlap
  the level text.
- Fixed the post-capture Summary screen to show one selected animated front
  frame instead of rendering the complete sprite atlas repeatedly.
- Refined the compact party-list `I` and `T` glyphs so their stems use the
  same weight as the other letters.

## 0.5.0

- Updated battle asset loading for the current g1recomp mod sandbox; battle
  artwork no longer relies on the removed `love.filesystem` API.
- Added public voxel-provider integration for HGSS billboard scaling and
  ground alignment with Battle Art Voxel Fork 1.9.0 and PotatoVoxel 1.6.0.
- Verified the portable mod with both voxel renderers on g1recomp 0.1.88,
  including an overworld capture and a 3D battle capture.

## 0.4.5

- Fixed the Pallet Town Oak Pikachu catch battle crashing when the scripted
  demo has no player battler yet.
- Routed Oak's catch-scene back sprite to the full-color HGSS Oak artwork.
- Reused the approved Jessie/James battle sprite for generation 4 and 5.

## 0.4.4

- Added animated full-color HGSS icons to the PC withdraw, deposit and release
  lists, with an option to disable the customization and restore the original
  game layout.
- Kept PC list icons aligned with their names and selection cursor at native
  32px resolution.

## 0.4.3

- Updated the Viridian Old Man overworld charset with the corrected authored
  sheet and preserved its front, back and side movement cells.
- Kept bundled battle back artwork in true color instead of passing it through
  the four-shade Game Boy palette.

## 0.4.2

- Corrected the normal party icons for Articuno, Zapdos and Moltres. Their
  two-frame HGSS sheets no longer contain the shiny sparkle overlay.
- Added the flat-renderer Start Menu guard so classic 2D does not show two
  menus at once; the Voxel-anchored layout remains available when Voxel is
  active.
- Reduced discarded per-frame HD draw bookkeeping while Voxel is active.

## 0.4.1

- Corrigido o charset dos Black Belts do Fighting Dojo: a folha HGSS agora
  contém as três direções usadas no mapa (baixo, cima e lateral), além dos
  quadros de caminhada, para que eles possam virar para o centro e enfrentar
  o jogador.

## 0.4.0

- Prepared a clean import archive containing only the runtime mod files.
- Verified coexistence with DRAMALESS_SHAPE 1.6.4 voxel overworld rendering.
- Replaced every map-local `SPRITE_MONSTER` placeholder with its intended
  Pokemon charset: Bill's Clefairy, Copycat's Pikachu doll, Poliwrath,
  Meowth, both Nidoran variants, Nidorino, Mewtwo, Kangaskhan, Slowpoke,
  Cubone, Psyduck, Machoke and Machop.
- Added native six-frame HGSS overworld sheets for those objects, preserving
  32px authored cells and the existing Red movement/grounding layout.
- Added explicit Battle Art Voxel Fork attribution for the adapted battle
  asset library/content, generation folders, filename slugs, animated atlas
  layout and timing conventions. The code audit found no runtime module import
  or manifest dependency; the local resolver, atlas decoder and frame-timing
  path were reimplemented from Battle Art's battle-art architecture and are
  credited as adapted code. Battle Art's HUD, trainer renderer and Voxel runtime
  are not bundled, and Battle Art remains optional only for its separate Voxel
  renderer.

## 0.3.3

- Added the animated Gen 5 Pikachu atlas used by the Yellow introduction.
- Hardened the HD intro renderer against a transient missing animation quad,
  preventing the `Quad expected, got nil` crash.
- Documented the correct g1recomp import/smoke-test identity so local tests
  reuse the populated game cache instead of opening a blank sandbox.
- Rebuilt and validated the portable ZIP through g1recomp's own importer.

## 0.3.2

- Published the verified Bill/Clefairy and map-object sprite corrections.
- Added dedicated normal-palette HGSS overworld sheets for Articuno, Zapdos
  and Moltres instead of reusing shiny artwork.
- Rebuilt the portable runtime archive and verified import through g1recomp's
  ZIP installer without stack overflow or manifest errors.

## 0.3.1

- Added verified Voxel captures for the selectable Ash and Ethan overworld
  players to the documentation.
- Prepared package metadata and documentation for the 0.3.1 release.

## 0.3.0

- Added **PLAYER SELECT** in the mod menu with RED, ASH and ETHAN choices.
  Ash and Ethan use their native 256x1536 walking sheets at a 28px logical
  footprint so they match Red on both 2D maps and Voxel billboards.
- Added **PARTY MENU** ON/OFF. OFF leaves the game's original party screen and
  icon renderer in control; ON keeps the full-color HGSS party presentation.
- Added **SPRITE SIZE** (`0.5x`–`1.0x`) for uniform overworld scaling of the
  player, NPCs and leaders without changing authored sprite pixels.
- Verified import, overworld Voxel and battle Voxel smoke tests on g1recomp
  `0.1.78`.
- Kept Battle Art Voxel Fork as the owner of battle trainer art and HUD.

## 0.2.6

- Corrected voxel grounding for HGSS overworld replacements so characters sit
  on the same ground plane as their shadows.
- Updated the Agatha and Lorelei overworld sheets with the corrected authored
  frames and preserved the existing full-resolution walking layout.
- Kept battle art, battle HUD and companion-owned battle presentation outside
  this package.

## 0.2.5

- Rebuilt the release archive with portable POSIX ZIP entry names.
- Removed Windows backslashes and synthetic directory entries that could make
  the g1recomp/PHYSFS recursive importer fail with `stack overflow`.
- Added an import validation step using g1recomp's own
  `LauncherMods.installZip` path before publishing.

## 0.2.4

- Updated Jessie, James and Officer Jenny overworld charsets with the corrected
  full-resolution sheets and standard six-frame layout.
- Added `CRYSTAL_251` as an optional compatibility companion in the manifest.

## 0.2.3

- Added verified Brock and Misty Voxel gym captures to the documentation.
- Kept Battle Art Voxel Fork optional; it is not a manifest dependency.

## 0.2.2

- Removed the global `player.sprite` hook so Battle Art Voxel Fork exclusively
  selects and renders the player battle sprite.

## 0.2.1

- Removed all custom HUD registration and battle HUD draw hooks after
  compatibility issues in 2D and 3D battles.
- The base game/Battle Art Voxel Fork now owns borders, cursors, HP bars and
  all battle presentation.

## 0.2.0

- Battle Art Voxel Fork is now a required companion and owns all battle and
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

## 0.0.28

- Mantido o tamanho/movimento estável da versão 0.0.26 e corrigidos os charsets do Centro Pokémon de Viridian.

## 0.0.27

- Corrigida a escala dos charsets HGSS no overworld 2D. Cientistas e outros
  NPCs nao ficam mais gigantes quando o Voxel esta desligado.

## 0.0.26

- O retrato HD de treinadores agora fica desativado no caminho 2D. Gary e os
  demais treinadores nao atravessam mais o HUD quando o Voxel esta desligado.

## 0.0.25

- Adicionado o campo `github` ao manifesto para habilitar a verificacao de
  novas releases diretamente pelo gerenciador do g1recomp.

## 0.0.24

- Incluidos os arquivos de fallback `redb.png`, `profoakb.png` e
  `gen1player.png`. Assim, entrar em batalha continua compativel quando o
  Voxel esta ativo, mas as batalhas 3D do DRAMALESS_SHAPE estao desligadas.

## 0.0.2

- Removida a quantizacao GB/SGB de todos os sprites true-color fornecidos pelo
  mod. Retratos da introducao (incluindo Oak), treinadores em batalha, Pokemon,
  overworld e icones agora preservam suas cores HGSS originais.
- Efeitos posteriores de paleta, fade e modo monocromatico nao reprocessam mais
  os retratos HGSS de treinadores; assets vanilla continuam usando o caminho
  normal do jogo.

## 0.0.1

- Jessie agora usa o charset mais fiel enviado pelo usuario, preservando o
  cabelo magenta longo, o uniforme e as passadas completas da referencia.
  A folha foi limpa, reduzida para celulas nativas de 32 px, recebeu fundo
  transparente e teve a pose lateral alinhada a mesma linha de base.

## 2.4.17

- A caminhada lateral de Oak, Agatha, Lorelei, Jessie, James e Officer Jenny
  agora segue o padrão do Red: cabeça e tronco superior permanecem estáveis,
  enquanto as pernas assumem uma passada aberta em vez de deslizar no mapa.

## 2.4.16

- Agatha, Lorelei, Jessie, James e Officer Jenny passaram pela mesma auditoria
  de movimento do Professor Carvalho. Cabeça e tronco agora permanecem
  pixel a pixel estáveis; os passos são derivados dos quadros parados e alteram
  somente os sapatos quando a silhueta permite.

## 2.4.15

- Removidos os pixels soltos que apareciam abaixo do Professor Carvalho ao
  caminhar para cima ou para baixo. Os passos agora são derivados somente dos
  quadros parados confirmados, deslocando os sapatos conectados em um pixel.

## 2.4.14

- Eliminadas as piscadas e os pulos do Professor Carvalho durante a caminhada.
  Os quadros de passo agora preservam cabeça, rosto, cabelo, tronco e jaleco
  pixel a pixel, animando apenas os pés e mantendo a mesma linha de base.

## 2.4.13

- Corrigida a funcionaria Silph feminina, que por uma identificacao errada do
  arquivo `NPC 25` estava usando o mesmo personagem visual de Bill. Ela agora
  possui um charset Gen IV proprio e distinto; Bill continua exclusivo de sua casa.

## 2.4.12

- Substituídos 11 placeholders por charsets oficiais completos de Platinum/HGSS: Fisher/Fishing Guru, Guard, Gym Guide, Hiker, Link Receptionist, Nurse, Safari/Silph Worker masculino, Sailor e Waiter.
- Captain, Clerk, Cook, Game Boy Kid, Silph President e Silph Worker feminina agora usam charsets Gen IV completos encontrados na coleção creditada de Vanilla Sunshine, em vez de personagens sem relação com suas funções.
- Agatha, Lorelei, Jessie, James e Officer Jenny receberam charsets direcionais próprios gerados a partir das referências corretas e normalizados para seis frames nativos de 32×32.
- Incluída uma folha de conferência dos 22 NPCs anteriormente pendentes.

## 2.4.11

- Corrigidos 13 arquivos overworld usando somente charsets completos já presentes no atlas HGSS: Beauty, Blue, Channeler/Medium, Daisy, Lance, Little Boy, Mom, Mr. Fuji, Rocker/Guitarist, Rocket masculino, Super Nerd, Swimmer masculino e Youngster.
- Bill recebeu um registro HGSS dedicado e os dois objetos de sua casa são redirecionados localmente, evitando que o conserto global do Super Nerd altere o personagem.
- Removidos os vazamentos visuais de Eusine, Bill, Ariana, Falkner, Archer e outros personagens que estavam registrados sob IDs genéricos incorretos.
- Sprites para os quais existe apenas um retrato frontal de referência foram mantidos para uma etapa posterior; nenhum NPC recebeu animação falsa repetindo a mesma direção.

## 2.4.10

- Professor Carvalho mantém o quadro HGSS confirmado como referência e agora
  tem poses de costas, laterais e caminhada geradas em pixel art, sem trocar
  sua identidade pelo charset do Professor Elm.
- O objeto do Carvalho voltou a ser um walker para que o jogo use as seis
  células ao virar e andar.

## 2.4.9

- Corrected the identity mix-up: the former `oak_32x192` charset was Professor Elm, not Professor Oak.
- Oak now uses the verified HGSS Oak overworld raster.

## 2.4.8

- Made the overworld builder retain generated dedicated sheets when optional source sheets are absent from the workspace.

## 2.4.7

- Marked live Oak map objects as walkers so the restored six-frame charset is used when they turn and move.

## 2.4.6

- Restored Professor Oak's six-frame HGSS overworld movement charset and corrected its direction order.

## 2.4.5

- Red's animated battle back now plays its five-frame entrance sequence only once and holds the final pose.

## 2.4.4

- Fixed the Yellow Oak tutorial back sprite using the vanilla demo palette, which broke the HGSS colors and silhouette.

## 2.4.3

- Fixed the Scientist frame slicing so no hair from the next animation row leaks below the character.

## 2.4.2

- Matched the corrected Scientist charset to the regular overworld NPC scale so it no longer renders twice as tall as the player.

## 2.4.1

- Replaced the generic elderly overworld Scientist with the supplied purple-haired HGSS Scientist charset, preserving its full two-tile animation.

## 2.4.0

- Added the five-frame animated HGSS Red battle-back strip supplied for the player.

## 2.3.9

- Corrigido o Karate Master do Fighting Dojo: deixou de reutilizar o charset de Hiker e agora usa o sprite HGSS de Black Belt.

## 2.3.8

- Corrigido novamente o Super Nerd overworld: o bloco 27 era outro NPC. Agora usa o bloco 28, correspondente ao sprite HGSS de cabelo azul mostrado na referência do Bulbagarden.

## 2.3.7

- Corrigido o Super Nerd de Cerulean: o charset genérico estava apontando para o bloco de nadadora deitada (bloco 26). Agora usa o bloco HGSS correto de Super Nerd (bloco 27), eliminando o efeito de “nadar” na terra.

## 2.3.6

- Corrigidos os Cooltrainers overworld: masculino usa o bloco HGSS Ace Trainer 14 e feminino o bloco 17; os blocos 37 (Koga) e 35 (NPC feminino especial) não são mais reutilizados por NPCs genéricos.

## 2.3.5

- Adicionados os IDs overworld HGSS de Blackbelt e Burglar para que as correções locais dos mapas não caiam de volta em Hiker/Super Nerd.

## 2.3.4

- Corrigidos objetos com charset fallback incorreto: Beauty de Vermilion, lutadores do Fighting Dojo e Burglar da Pokémon Mansion agora usam seus sprites HGSS correspondentes.

## 2.3.3

- Limitados os redirects de overworld dos líderes aos objetos exatos de cada ginásio; Oak, rivais e Giovanni de Rocket/Silph não recebem mais charset de líder por coincidência no nome.

## 2.3.2

- Corrigido o charset overworld do Red: frente/trás e esquerda/direita agora usam os blocos HGSS corretos; a coluna do personagem de roupa preta foi removida do atlas usado pelo Red.

## 2.3.1

- Corrigido o carregamento no Mod Manager: os ícones dos 151 Pokémon agora usam `patch` sobre os registros base, evitando o erro “icons already registered”.

## 2.3.0

- Restaurados os retratos de batalha dos treinadores em 80×80 nativos; o renderer apenas centraliza o retrato, sem redução 80→40.

## 2.2.0

- Corrigidos os charsets overworld dos líderes de ginásio com os blocos HGSS corretos, sem trocar NPCs genéricos.
- Gary/Blue e Professor Oak receberam aliases dedicados; Oak preserva a referência HGSS nativa de 17×25 sem upscale.
- Os objetos reais dos ginásios, rivais e eventos de Oak são redirecionados em `map.entered`, inclusive após reload.

## 2.1.0

- Restored the original 80x80 HGSS battle PNGs and switched Pokemon battle sides to 1:1 nearest rendering.
- Restored authored 32x32 overworld cells in 32x192 sheets with a narrow renderer adapter, eliminating the GBC-sized 16px crop.
- Rebuilt party icons as full-color 32x64 sheets and added a trueColor/native-density PartyMenu adapter with a two-column HGSS-style grid.
- Repaired the six 8x8 text-border glyphs so corners and repeated rails join without gaps.
- Rebuilt the Red overworld sheet from the authored HGSS 4x4 source, restoring the cap pixels at native 32x32 density; verified Yellow's follower resolves to the six-frame true-color `SPRITE_PIKACHU` sheet.
- Routed all 46 trainer classes through the mod trainer registry and applied the same crisp integer scale.

## 2.0.0

- Migrated the mod to g1recomp Mod API 2 and removed all silent `pcall` wrappers.
- Removed private `SpriteRenderer`, `BattleState`, `Sprites`, and `PaletteFX` monkey-patches.
- Converted overworld art to native 16×96, 16×48, and 16×16 sheets.
- Added mapped HGSS-style art for every character/Pokémon sprite path used by Yellow.
- Fixed the bicycle sheet and supplied the real Yellow Pikachu/surfing-Pikachu paths.
- Pre-rendered Pokémon and trainer battle art at 56×56 with runtime scale 1.
- Added all 46 trainer portrait paths plus ghost/fossil battle variants.
- Added two-frame 16×32 party icons for all 151 species.
- Added reusable DS-like border/cursor glyphs, HGSS-like HP palettes, Trainer Card chrome/badges, and a crisp-display option while preserving the native 8×8 text metrics.
- Normalized party icons to the engine's supported four-shade UI path and fixed Mew's seam-crossing source frame.
- Added a deterministic asset builder, verifier, and lean release packager.
