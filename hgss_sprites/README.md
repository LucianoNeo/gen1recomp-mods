# HGSS Visual Overhaul

![Versão](https://img.shields.io/badge/versão-0.0.19-gold)
![g1recomp](https://img.shields.io/badge/g1recomp-0.1.75-blue)
![Jogo](https://img.shields.io/badge/Pokémon-Yellow-yellow)

Mod visual para **Pokémon Yellow no g1recomp**, inspirado em Pokémon
HeartGold e SoulSilver. Ele substitui sprites de batalha, personagens no
mapa, ícones do time e elementos da interface, preservando cores RGB e a
densidade dos assets de Nintendo DS sempre que o motor permite.

## O núcleo do mod

O foco principal é levar a identidade visual de **HeartGold e SoulSilver**
para os elementos que permanecem visíveis durante toda a aventura: personagens,
NPCs do mapa e Pokémon.

### Personagens e Pokémon no overworld

Red, o Pikachu seguidor, líderes, rivais e NPCs usam charsets coloridos em
densidade de Nintendo DS, com direções e quadros próprios de caminhada.

![Red, Pikachu e NPC no overworld](docs/media/core-red-pikachu.png)

### NPCs nos interiores

Os personagens dos mapas internos também recebem sprites HGSS dedicados. A
captura abaixo mostra Daisy em sua casa, renderizada pelo mapa real do jogo.

![Daisy com sprite HGSS no interior](docs/media/core-overworld-npcs.png)

### Pokémon e personagens em batalha

Os 151 Pokémon têm sprites frontais e traseiros coloridos. Red, Oak, Blue,
líderes, Elite Four e as demais classes de treinador usam retratos em resolução
completa, sem redução para a paleta do Game Boy.

![Red e Pikachu em batalha](docs/media/core-pokemon-battle.png)

## Capturas dentro do jogo

Estas imagens foram extraídas de frames apresentados pelo próprio g1recomp
com o mod carregado. Não são montagens, grades de sprites ou simulações.

### Batalha em layout WIDE

O retrato HD acompanha o deslocamento de entrada do treinador e substitui a
imagem de baixa resolução na mesma posição, sem duplicação.

![Batalha contra Brock dentro do jogo](docs/media/gameplay-battle-still.png)

### Tela Pokémon

Os seis ícones são desenhados e animados pelo menu real do jogo.

![Tela Pokémon dentro do jogo](docs/media/gameplay-party-still.png)

### Interface DS e barras de HP

As caixas agora são desenhadas em RGB verdadeiro, com contorno azul-marinho,
rebaixo azul-cinza e interior branco. Cursores ativos usam vermelho e não são
reconvertidos para a paleta do Game Boy.

As barras de HP também são RGB: verde para HP alto, amarelo para HP
intermediário e vermelho para HP baixo. O estilo é compartilhado pelas telas
de batalha, time e resumo.

![Interface HGSS e barras amarela e vermelha dentro do jogo](docs/media/gameplay-hgss-ui-hp.png)

![Interface HGSS e barras verdes na tela Pokémon](docs/media/gameplay-hgss-ui-party.png)

## Vídeos de gameplay

Os vídeos abaixo foram montados exclusivamente com frames PNG capturados pela
função de screenshot do próprio g1recomp durante a execução.

### Entrada de batalha contra Brock

![Gameplay da batalha contra Brock](docs/media/gameplay-battle.gif)

[Abrir vídeo MP4](docs/media/gameplay-battle.mp4)

### Ícones animados na tela Pokémon

![Gameplay da tela Pokémon](docs/media/gameplay-party.gif)

[Abrir vídeo MP4](docs/media/gameplay-party.mp4)

## Principais modificações

- 151 sprites frontais e 151 sprites traseiros de Pokémon em batalha;
- 151 ícones coloridos e animados para a tela do time;
- 46 classes de treinadores com retratos distintos;
- retratos HD de Oak, Red, Blue, Jessie, James, líderes e Elite Four;
- retratos de batalha com transparência real, compatíveis com cenários voxel;
- charsets overworld em 32×32 para Red, Blue, Oak, líderes, NPCs e Pokémon;
- Pikachu seguidor e Surfing Pikachu nos registros corretos;
- animação do Red de costas executada uma única vez ao iniciar a batalha;
- sprite dedicado do Oak de costas no tutorial de captura;
- Trainer Card com Red, moldura, selos e oito insígnias de Kanto;
- bordas e cursores globais em estilo DS;
- barras de HP verdes, amarelas e vermelhas em estilo HGSS;
- correções específicas para o layout de batalha WIDE;
- opção `CRISP DISPLAY` para evitar escala fracionária e deformações.

## Instalação

1. Baixe `HGSS_SPRITES-0.0.19.zip` na página de releases.
2. Copie o ZIP para a pasta `mods` do g1recomp ou extraia-o como
   `mods/HGSS_SPRITES/`.
3. Habilite **HGSS Visual Overhaul** no gerenciador de mods.
4. Reinicie o jogo depois de atualizar uma versão anterior.

Compatibilidade: g1recomp `>=0.1.75 <0.2.0`, Pokémon Yellow e Mod API 2.

## Formatos utilizados

| Asset | Formato runtime |
|---|---|
| Overworld com caminhada | `32×192`, seis frames |
| NPC parado | `32×96` |
| Objeto parado | `32×32` |
| Ícone do time | `32×64`, dois frames |
| Pokémon em batalha | `80×80` |
| Retrato HD de treinador | `320×320` |
| Chrome da interface | glyphs de `8×8` |

O adaptador interno é limitado às folhas deste mod e está declarado pela
permissão `engine_internals`. Ele não modifica os sprites vanilla de outros
mods.

## Verificação

O pacote é validado por contagem, dimensões e capturas determinísticas geradas
diretamente pelo motor:

```powershell
python scripts/build_mod_assets.py --check
python scripts/build_mod_assets.py --package
```

Os testes atuais verificam 151 pares de batalha, 151 ícones, todos os sprites
overworld mapeados, tela inicial, menu do time, tutorial do Oak e retratos de
treinadores nos layouts clássico e WIDE.

## Referências

- [Art Pipeline do g1recomp](https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Art-Pipeline)
- [Referência de manifests](https://github.com/bryanthaboi/gen1recomp/wiki/Reference-Manifest)
- [Referência de registries](https://github.com/bryanthaboi/gen1recomp/wiki/Reference-Registries)
- [Trainers HGSS — The Spriters Resource](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26955/)
- [Galeria de personagens — Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/User:Team_Rocket_Grunt/List_of_game_characters_by_overworld_sprite)

Pokémon e os designs de HeartGold/SoulSilver pertencem à Nintendo, Game Freak
e The Pokémon Company. Este é um projeto visual não comercial.
