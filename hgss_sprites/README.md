# HGSS Visual Overhaul — Complete Sprite Mod for Gen1Recomp

> **O primeiro mod que substitui TUDO de uma vez**: sprites de batalha, overworld, treinadores e UI inteira no estilo HeartGold/SoulSilver.

## ✨ Features

- 🎮 **151 Pokémon** — Sprites de batalha (front + back) estilo HGSS
- 🗺️ **Overworld Completo** — Pokémon followers e NPCs no estilo DS
- ⚔️ **Treinadores** — Sprites de batalha (front + back) + overworld
- 🖥️ **UI Redesign** — Text boxes, HP bars, menus, badges, bag no estilo HGSS
- 🎨 **Palette Enhancement** — Cores mais ricas e vibrantes para assets não substituídos

## 📦 Instalação

### Método 1: ZIP Import (Recomendado)
1. Baixe o release `.zip` mais recente
2. No Gen1Recomp, vá em **MODS → Import mod .zip**
3. Selecione o arquivo `.zip`
4. Ative o mod no Mod Manager

### Método 2: Manual
1. Copie a pasta `hgss_sprites/` para `gen1recomp/mods/`
2. Reinicie o Gen1Recomp
3. Ative o mod no Mod Manager

## 🛠️ Build — Processando os Sprites

Os sprites precisam ser baixados manualmente do [Spriters Resource](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/) e processados com nosso script.

### Passo 1: Baixar as Sprite Sheets

Baixe os seguintes assets e coloque na pasta `tools/raw/`:

| Arquivo | Link | Categoria |
|---------|------|-----------|
| Pokémon Gen 1 (Batalha) | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/132565/) | Battle |
| Pokémon Gen 1 (Overworld) | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26794/) | Overworld |
| Treinadores (Front) | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/28037/) | Trainers |
| Treinadores (Back) | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/41995/) | Trainers |
| Treinadores (Overworld) | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26955/) | Overworld |
| Items | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/28036/) | UI |
| Text Boxes | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26753/) | UI |
| HP Bars | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/30540/) | UI |
| Badge Case | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/29323/) | UI |
| Bag | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26746/) | UI |
| Poké Balls | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/233231/) | UI |
| Fonts | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/27044/) | UI |
| Introduction | [Download](https://www.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/26748/) | UI |

### Passo 2: Processar os Sprites

```bash
cd tools/
pip install Pillow
python sprite_cutter.py
```

O script recorta automaticamente as sprite sheets em sprites individuais e os organiza na estrutura de pastas correta.

### Passo 3: Verificar

Confira que os sprites foram gerados em:
```
assets/graphics/pokemon/front/    → 151 PNGs
assets/graphics/pokemon/back/     → 151 PNGs
assets/graphics/pokemon/overworld/ → 151 PNGs
assets/graphics/trainers/front/   → ~45 PNGs
assets/graphics/trainers/back/    → ~45 PNGs
assets/graphics/trainers/overworld/ → ~100 PNGs
assets/graphics/ui/               → UI elements
```

## 📁 Estrutura do Mod

```
hgss_sprites/
├── manifest.json          # Metadados do mod
├── main.lua               # Entry point — registra todos os overrides
├── transforms.lua         # Transformações programáticas de assets
├── mod.card               # Preview no Mod Manager
├── README.md              # Este arquivo
├── assets/
│   └── graphics/
│       ├── pokemon/
│       │   ├── front/     # Sprites de batalha frontais
│       │   ├── back/      # Sprites de batalha traseiros
│       │   └── overworld/ # Sprites de overworld/follower
│       ├── trainers/
│       │   ├── front/     # Sprites de batalha dos treinadores
│       │   ├── back/      # Sprites traseiros dos treinadores
│       │   └── overworld/ # Sprites de overworld dos treinadores
│       └── ui/            # Elementos de UI (text boxes, HP, etc.)
└── tools/
    ├── raw/               # Sprite sheets brutas (não incluídas no release)
    └── sprite_cutter.py   # Script de processamento
```

## 🎨 Créditos

- **Sprites originais**: Game Freak / Nintendo / The Pokémon Company
- **Sprite rips**: Dazz, Dragoon, Nx-Kun, HackMew, KurainoOni, Random Talking Bush, mufasakong (via [The Spriters Resource](https://www.spriters-resource.com/))
- **Gen1Recomp**: [bryanthaboi](https://github.com/bryanthaboi/gen1recomp)
- **Mod**: Luciano

## ⚖️ Aviso Legal

Este mod não inclui sprites protegidos por copyright. Você deve baixar e processar os sprites manualmente usando as ferramentas fornecidas. Os sprites são propriedade da Nintendo/Game Freak/The Pokémon Company.
