# HGSS Visual Overhaul 2.3

> **Native DS density:** this release keeps the source 80x80 battle sprites
> and 32x32 overworld cells intact. Battle art is drawn at 1:1 from the
> original PNGs; overworld sheets use a narrow `engine_internals` adapter because
> the stock 16px renderer would otherwise crop them into GBC-sized fragments.

Este mod converte a apresentação de **Pokémon Yellow no g1recomp 0.1.75** para uma linguagem visual inspirada em Pokémon HeartGold/SoulSilver. A maior parte usa a Mod API 2; o único acesso interno é o adaptador estreito que permite desenhar as folhas overworld DS em 32×32.

## O que realmente é substituído

- 151 sprites frontais e 151 sprites traseiros de batalha, preservados em 80×80 e desenhados a escala 1:1;
- 151 ícones de party específicos por espécie, com dois frames coloridos em folhas 32×64 na densidade nativa do DS;
- todos os charsets humanos e Pokémon que o registro overworld de Yellow expõe;
- Red (folha HGSS 4×4 preservada, com fundo removido sem perder o boné), bicicleta, Blue, Oak, Pikachu seguidor e Surfing Pikachu nos caminhos corretos;
- as 46 classes de retrato de treinador esperadas pelo cache de Yellow;
- Red de costas na batalha e Red de frente no Trainer Card/Hall of Fame;
- frame, selos, faces e oito badges Kanto do Trainer Card;
- bordas, cursores e setas globais em estilo DS, mantendo a fonte 8×8 nativa e legível;
- paletas de HP inspiradas em HGSS para batalha, party e summary;
- uma opção `CRISP DISPLAY` que usa `FIXED`, `CENTERED`, zoom FIT e remove tilt/efeitos que deformam a grade.

As telas continuam usando a geometria 160×144 do jogo recompilado. O mod troca arte, ícones e o chrome global da interface, preservando a fonte 8×8 para que as colunas continuem legíveis; ele não reimplementa Bag, Pokédex ou Trainer Card com o layout de duas telas do Nintendo DS.

Também é importante distinguir ícones de seguidores: Pokémon Yellow/g1recomp possui um sistema de seguidor para Pikachu. As outras 150 folhas são usadas como ícones animados da party; adicionar 151 seguidores ao mapa exigiria um sistema de gameplay separado.

## Instalação

Use o ZIP de release, cuja raiz já contém `manifest.json`:

1. Copie `HGSS_SPRITES-0.0.2.zip` para a pasta `mods` do g1recomp, ou extraia como `mods/HGSS_SPRITES/`.
2. Abra o gerenciador de mods do g1recomp e deixe **HGSS Visual Overhaul** habilitado.
3. Reinicie o jogo depois de atualizar uma versão anterior; a v1.x alterava módulos do renderer em memória.

O mod é direcionado a g1recomp `>=0.1.75 <0.2.0` e Pokémon Yellow.

## Build e verificação

Na raiz deste repositório:

```powershell
python scripts/build_mod_assets.py
python scripts/build_mod_assets.py --check
python scripts/build_mod_assets.py --package
```

O primeiro comando reconstrói os arquivos runtime a partir das sheets fonte. O segundo confere contagens, dimensões e o contrato do manifest. O terceiro também cria `HGSS_SPRITES-0.0.2.zip`, contendo apenas os arquivos consumidos pelo motor.

Para a validação oficial do g1recomp:

```powershell
python tools/gen1_official/tools/modkit.py --repo tools/gen1_official validate hgss_sprites --strict --base imported
python tools/gen1_official/tools/modkit.py --repo tools/gen1_official lint hgss_sprites
```

O validador dinâmico precisa que `luajit` esteja disponível no `PATH`; a validação real deste projeto também é feita iniciando o executável 0.1.75 com drivers determinísticos de captura.

## Formatos runtime

- walker overworld: 32×192, ordem `stand down/up/left`, `walk down/up/left`;
- NPC parado: 32×96;
- objeto parado: 32×32;
- party icon: 32×64 (dois frames 32×32, desenhados em uma grade de seis células);
- batalha: 80×80 a escala 1:1, filtro nearest;
- chrome da UI: nove glyphs de 8×8 a partir do código privado `0x200`;
- Trainer Card: frame 24×24, selo 8×8 e oito pares face/badge em 16×256.

O adaptador `SpriteRenderer` é intencional e limitado às folhas 32×192 deste mod; ele é declarado pela permissão `engine_internals` e não altera os sprites vanilla.

## Referências do motor

- [Art Pipeline](https://github.com/bryanthaboi/gen1recomp/wiki/Guide-Art-Pipeline)
- [Sprite and Text Tweak](https://github.com/bryanthaboi/gen1recomp/wiki/Tutorial-01-Sprite-And-Text-Tweak)
- [Manifest Reference](https://github.com/bryanthaboi/gen1recomp/wiki/Reference-Manifest)
- [Registry Reference](https://github.com/bryanthaboi/gen1recomp/wiki/Reference-Registries)

## Fontes dos charsets Gen IV

- [Trainers (Overworld) de HGSS — The Spriters Resource](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26955/)
- [NPCs de Pokémon Platinum — The Spriters Resource](https://www.spriters-resource.com/ds_dsi/pokemonplatinum/asset/25791/)
- [ALL Official Gen 4 Overworld Sprites — Vanilla Sunshine](https://www.eeveeexpo.com/resources/404/), com créditos adicionais a Neo-Spriteman, PurpleZaffre, Maicerochico e AtomicReactor conforme `assets/graphics/trainers/overworld/gen4_community/CREDITS.txt`.
- Referências visuais individuais conferidas na [galeria Gen IV da Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/User:Team_Rocket_Grunt/List_of_game_characters_by_overworld_sprite).

Pokémon e os designs de HeartGold/SoulSilver pertencem à Nintendo/Game Freak. As sheets fonte mantêm os créditos embutidos de seus respectivos ripadores; este projeto é um mod visual não comercial.
