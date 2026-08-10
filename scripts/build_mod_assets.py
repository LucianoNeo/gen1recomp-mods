"""Build the runtime HGSS assets in the exact formats g1recomp expects.

The source sheets stay under ``hgss_sprites/assets`` and
``hgss_sprites/source``.  Generated runtime files are written under the
mod's ``overrides`` and ``assets/icons`` directories.  Use ``--check`` in
CI, or ``--package`` to also create a lean installable ZIP.
"""

from __future__ import annotations

import argparse
import base64
import io
import json
import shutil
import sys
import zipfile
from collections import Counter
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "hgss_sprites"
RESAMPLE = Image.Resampling.NEAREST


# Registry id, source-sheet basename, cache basename.
SPECIES = [
    ("BULBASAUR", "BULBASAUR", "bulbasaur"),
    ("IVYSAUR", "IVYSAUR", "ivysaur"),
    ("VENUSAUR", "VENUSAUR", "venusaur"),
    ("CHARMANDER", "CHARMANDER", "charmander"),
    ("CHARMELEON", "CHARMELEON", "charmeleon"),
    ("CHARIZARD", "CHARIZARD", "charizard"),
    ("SQUIRTLE", "SQUIRTLE", "squirtle"),
    ("WARTORTLE", "WARTORTLE", "wartortle"),
    ("BLASTOISE", "BLASTOISE", "blastoise"),
    ("CATERPIE", "CATERPIE", "caterpie"),
    ("METAPOD", "METAPOD", "metapod"),
    ("BUTTERFREE", "BUTTERFREE", "butterfree"),
    ("WEEDLE", "WEEDLE", "weedle"),
    ("KAKUNA", "KAKUNA", "kakuna"),
    ("BEEDRILL", "BEEDRILL", "beedrill"),
    ("PIDGEY", "PIDGEY", "pidgey"),
    ("PIDGEOTTO", "PIDGEOTTO", "pidgeotto"),
    ("PIDGEOT", "PIDGEOT", "pidgeot"),
    ("RATTATA", "RATTATA", "rattata"),
    ("RATICATE", "RATICATE", "raticate"),
    ("SPEAROW", "SPEAROW", "spearow"),
    ("FEAROW", "FEAROW", "fearow"),
    ("EKANS", "EKANS", "ekans"),
    ("ARBOK", "ARBOK", "arbok"),
    ("PIKACHU", "PIKACHU", "pikachu"),
    ("RAICHU", "RAICHU", "raichu"),
    ("SANDSHREW", "SANDSHREW", "sandshrew"),
    ("SANDSLASH", "SANDSLASH", "sandslash"),
    ("NIDORAN_F", "NIDORAN_F", "nidoranf"),
    ("NIDORINA", "NIDORINA", "nidorina"),
    ("NIDOQUEEN", "NIDOQUEEN", "nidoqueen"),
    ("NIDORAN_M", "NIDORAN_M", "nidoranm"),
    ("NIDORINO", "NIDORINO", "nidorino"),
    ("NIDOKING", "NIDOKING", "nidoking"),
    ("CLEFAIRY", "CLEFAIRY", "clefairy"),
    ("CLEFABLE", "CLEFABLE", "clefable"),
    ("VULPIX", "VULPIX", "vulpix"),
    ("NINETALES", "NINETALES", "ninetales"),
    ("JIGGLYPUFF", "JIGGLYPUFF", "jigglypuff"),
    ("WIGGLYTUFF", "WIGGLYTUFF", "wigglytuff"),
    ("ZUBAT", "ZUBAT", "zubat"),
    ("GOLBAT", "GOLBAT", "golbat"),
    ("ODDISH", "ODDISH", "oddish"),
    ("GLOOM", "GLOOM", "gloom"),
    ("VILEPLUME", "VILEPLUME", "vileplume"),
    ("PARAS", "PARAS", "paras"),
    ("PARASECT", "PARASECT", "parasect"),
    ("VENONAT", "VENONAT", "venonat"),
    ("VENOMOTH", "VENOMOTH", "venomoth"),
    ("DIGLETT", "DIGLETT", "diglett"),
    ("DUGTRIO", "DUGTRIO", "dugtrio"),
    ("MEOWTH", "MEOWTH", "meowth"),
    ("PERSIAN", "PERSIAN", "persian"),
    ("PSYDUCK", "PSYDUCK", "psyduck"),
    ("GOLDUCK", "GOLDUCK", "golduck"),
    ("MANKEY", "MANKEY", "mankey"),
    ("PRIMEAPE", "PRIMEAPE", "primeape"),
    ("GROWLITHE", "GROWLITHE", "growlithe"),
    ("ARCANINE", "ARCANINE", "arcanine"),
    ("POLIWAG", "POLIWAG", "poliwag"),
    ("POLIWHIRL", "POLIWHIRL", "poliwhirl"),
    ("POLIWRATH", "POLIWRATH", "poliwrath"),
    ("ABRA", "ABRA", "abra"),
    ("KADABRA", "KADABRA", "kadabra"),
    ("ALAKAZAM", "ALAKAZAM", "alakazam"),
    ("MACHOP", "MACHOP", "machop"),
    ("MACHOKE", "MACHOKE", "machoke"),
    ("MACHAMP", "MACHAMP", "machamp"),
    ("BELLSPROUT", "BELLSPROUT", "bellsprout"),
    ("WEEPINBELL", "WEEPINBELL", "weepinbell"),
    ("VICTREEBEL", "VICTREEBEL", "victreebel"),
    ("TENTACOOL", "TENTACOOL", "tentacool"),
    ("TENTACRUEL", "TENTACRUEL", "tentacruel"),
    ("GEODUDE", "GEODUDE", "geodude"),
    ("GRAVELER", "GRAVELER", "graveler"),
    ("GOLEM", "GOLEM", "golem"),
    ("PONYTA", "PONYTA", "ponyta"),
    ("RAPIDASH", "RAPIDASH", "rapidash"),
    ("SLOWPOKE", "SLOWPOKE", "slowpoke"),
    ("SLOWBRO", "SLOWBRO", "slowbro"),
    ("MAGNEMITE", "MAGNEMITE", "magnemite"),
    ("MAGNETON", "MAGNETON", "magneton"),
    ("FARFETCHD", "FARFETCHD", "farfetchd"),
    ("DODUO", "DODUO", "doduo"),
    ("DODRIO", "DODRIO", "dodrio"),
    ("SEEL", "SEEL", "seel"),
    ("DEWGONG", "DEWGONG", "dewgong"),
    ("GRIMER", "GRIMER", "grimer"),
    ("MUK", "MUK", "muk"),
    ("SHELLDER", "SHELLDER", "shellder"),
    ("CLOYSTER", "CLOYSTER", "cloyster"),
    ("GASTLY", "GASTLY", "gastly"),
    ("HAUNTER", "HAUNTER", "haunter"),
    ("GENGAR", "GENGAR", "gengar"),
    ("ONIX", "ONIX", "onix"),
    ("DROWZEE", "DROWZEE", "drowzee"),
    ("HYPNO", "HYPNO", "hypno"),
    ("KRABBY", "KRABBY", "krabby"),
    ("KINGLER", "KINGLER", "kingler"),
    ("VOLTORB", "VOLTORB", "voltorb"),
    ("ELECTRODE", "ELECTRODE", "electrode"),
    ("EXEGGCUTE", "EXEGGCUTE", "exeggcute"),
    ("EXEGGUTOR", "EXEGGUTOR", "exeggutor"),
    ("CUBONE", "CUBONE", "cubone"),
    ("MAROWAK", "MAROWAK", "marowak"),
    ("HITMONLEE", "HITMONLEE", "hitmonlee"),
    ("HITMONCHAN", "HITMONCHAN", "hitmonchan"),
    ("LICKITUNG", "LICKITUNG", "lickitung"),
    ("KOFFING", "KOFFING", "koffing"),
    ("WEEZING", "WEEZING", "weezing"),
    ("RHYHORN", "RHYHORN", "rhyhorn"),
    ("RHYDON", "RHYDON", "rhydon"),
    ("CHANSEY", "CHANSEY", "chansey"),
    ("TANGELA", "TANGELA", "tangela"),
    ("KANGASKHAN", "KANGASKHAN", "kangaskhan"),
    ("HORSEA", "HORSEA", "horsea"),
    ("SEADRA", "SEADRA", "seadra"),
    ("GOLDEEN", "GOLDEEN", "goldeen"),
    ("SEAKING", "SEAKING", "seaking"),
    ("STARYU", "STARYU", "staryu"),
    ("STARMIE", "STARMIE", "starmie"),
    ("MR_MIME", "MR_MIME", "mr.mime"),
    ("SCYTHER", "SCYTHER", "scyther"),
    ("JYNX", "JYNX", "jynx"),
    ("ELECTABUZZ", "ELECTABUZZ", "electabuzz"),
    ("MAGMAR", "MAGMAR", "magmar"),
    ("PINSIR", "PINSIR", "pinsir"),
    ("TAUROS", "TAUROS", "tauros"),
    ("MAGIKARP", "MAGIKARP", "magikarp"),
    ("GYARADOS", "GYARADOS", "gyarados"),
    ("LAPRAS", "LAPRAS", "lapras"),
    ("DITTO", "DITTO", "ditto"),
    ("EEVEE", "EEVEE", "eevee"),
    ("VAPOREON", "VAPOREON", "vaporeon"),
    ("JOLTEON", "JOLTEON", "jolteon"),
    ("FLAREON", "FLAREON", "flareon"),
    ("PORYGON", "PORYGON", "porygon"),
    ("OMANYTE", "OMANYTE", "omanyte"),
    ("OMASTAR", "OMASTAR", "omastar"),
    ("KABUTO", "KABUTO", "kabuto"),
    ("KABUTOPS", "KABUTOPS", "kabutops"),
    ("AERODACTYL", "AERODACTYL", "aerodactyl"),
    ("SNORLAX", "SNORLAX", "snorlax"),
    ("ARTICUNO", "ARTICUNO", "articuno"),
    ("ZAPDOS", "ZAPDOS", "zapdos"),
    ("MOLTRES", "MOLTRES", "moltres"),
    ("DRATINI", "DRATINI", "dratini"),
    ("DRAGONAIR", "DRAGONAIR", "dragonair"),
    ("DRAGONITE", "DRAGONITE", "dragonite"),
    ("MEWTWO", "MEWTWO", "mewtwo"),
    ("MEW", "MEW", "mew"),
]


# All human sprite paths in the Yellow registry.  Values are the physical
# 10-column block indexes in the 957x1101 HGSS sheet.  Dedicated Red/Blue/Oak
# sources are handled separately below.
HUMAN_SPRITES = {
    "agatha": (73, 6),
    "balding_guy": (52, 3),
    # HGSS Beauty. Block 13 is the Bird Keeper/Guitarist woman and was
    # previously assigned here by mistake.
    "beauty": (16, 6),
    "biker": (59, 6),
    "bike_shop_clerk": (71, 3),
    "brunette_girl": (11, 6),
    "bruno": (38, 6),
    "captain": (62, 3),
    # Yellow's Channeler maps most closely to HGSS's Medium class.
    "channeler": (3, 6),
    "clerk": (23, 3),
    "cook": (25, 6),
    # HGSS Ace Trainer/Cooltrainer sprites.  Blocks 35 and 37 are not the
    # generic classes: 35 is a different blue-haired NPC and 37 is Koga.
    # Keep those leader/special-character blocks isolated below.
    "cooltrainer_f": (17, 6),
    "cooltrainer_m": (14, 6),
    "daisy": (69, 6),
    "fisher": (8, 6),
    "fishing_guru": (8, 3),
    "gambler": (24, 6),
    "gameboy_kid": (5, 3),
    "gentleman": (24, 6),
    # The first pass used the generic Rocket executive and Koga blocks here.
    # These are the actual HGSS character blocks (the map objects use the
    # generic IDs, so fixing them also fixes Elite Four/Giovanni appearances).
    "giovanni": (74, 6),
    "girl": (6, 6),
    "gramps": (18, 3),
    "granny": (21, 3),
    "guard": (78, 3),
    "gym_guide": (51, 3),
    "hiker": (32, 6),
    "james": (40, 6),
    "jessie": (30, 6),
    "koga": (37, 6),
    "lance": (40, 6),
    "link_receptionist": (63, 3),
    "little_boy": (7, 3),
    "little_girl": (6, 6),
    "lorelei": (67, 6),
    "middle_aged_man": (75, 6),
    "middle_aged_woman": (16, 6),
    "mom": (70, 3),
    "mr_fuji": (20, 6),
    "nurse": (56, 3),
    "officer_jenny": (78, 6),
    # HGSS combines the Bird Keeper/Guitarist overworld design in block 13;
    # it is the complete animated counterpart available for Yellow's Rocker.
    "rocker": (13, 6),
    "rocket": (54, 6),
    "safari_zone_worker": (64, 3),
    "sailor": (3, 6),
    "scientist": (66, 6),
    "silph_president": (52, 3),
    "silph_worker_f": (45, 6),
    "silph_worker_m": (51, 3),
    # Block 23 is the complete HGSS Super Nerd charset. Block 28 is Falkner,
    # which caused every Super Nerd object to appear as the gym leader.
    "super_nerd": (23, 6),
    "swimmer": (25, 6),
    "waiter": (4, 6),
    "warden": (76, 3),
    "youngster": (7, 6),
    # Blue/Gary's complete HGSS charset. The old dedicated fallback was
    # Eusine and survived rebuilds because it bypassed this atlas.
    "blue": (49, 6),
    # Bill shares SPRITE_SUPER_NERD in Yellow. Build his own complete HGSS
    # sheet so main.lua can redirect only the two Bill objects.
    "bill": (61, 6),
}

# Full Gen IV NPC sheets recovered during the 2.4.12 visual audit.  Coordinates
# are the exact 32x32 standing-down cells in the credited Pokemon Platinum NPC
# sheet; each character then has nine vertical frames (three poses per stored
# direction).  These entries replace the placeholder trainer blocks above.
PLATINUM_NPC_SPRITES = {
    "fisher": (145, 675, 6),
    "fishing_guru": (145, 675, 3),
    "guard": (433, 675, 3),
    "gym_guide": (119, 1254, 3),
    "hiker": (209, 674, 6),
    "link_receptionist": (465, 961, 3),
    "nurse": (433, 963, 3),
    "safari_zone_worker": (369, 675, 3),
    "sailor": (177, 674, 6),
    "silph_worker_m": (369, 675, 3),
    "waiter": (241, 387, 6),
}

# Non-trainer Gen IV overworlds from Vanilla Sunshine's complete collection.
# The source is an RMXP 4x4 atlas at 2x DS size; build_overworld converts it
# back to native 32px frames.  See the bundled CREDITS.txt for attribution.
COMMUNITY_NPC_SPRITES = {
    "captain": ("NPC 12.png", 3),
    "clerk": ("NPC 20.png", 3),
    "cook": ("NPC 13.png", 6),
    "gameboy_kid": ("NPC 27.png", 3),
    "silph_president": ("NPC 21.png", 3),
    # NPC 25 is Bill, not a Silph employee.  Use the distinct Gen IV office
    # woman sheet so the generic Silph workers cannot inherit Bill's look.
    "silph_worker_f": ("NPC 06.png", 6),
}

# Yellow-only named characters have no complete official Gen IV charset.
# Their six-direction strips were generated from the correct battle/artwork
# references and normalized to the same 32px runtime contract as HGSS.
AI_NPC_SPRITES = {
    "agatha": 6,
    "james": 6,
    "jessie": 6,
    "lorelei": 6,
    "officer_jenny": 6,
}

# Walking phases for generated characters must never redraw the face or body.
# Each entry describes tiny shoe-only edits for down/up/left.  None means that
# the standing pose is intentionally reused (safer for a long dress or a pose
# whose feet form one continuous shape).
AI_WALK_SHOE_EDITS = {
    "agatha": (None, None, None),
    "lorelei": (
        (((12, 29, 15, 32), (16, 29, 19, 32)), (11, 17)),
        (((12, 29, 15, 32), (16, 29, 19, 32)), (11, 17)),
        (((13, 29, 17, 32),), (12,)),
    ),
    "jessie": (
        (((13, 31, 15, 32), (17, 31, 19, 32)), (12, 18)),
        (((13, 31, 15, 32), (17, 31, 19, 32)), (12, 18)),
        (((12, 31, 16, 32),), (11,)),
    ),
    "james": (
        (((11, 31, 15, 32), (17, 31, 20, 32)), (10, 18)),
        (((11, 31, 15, 32), (17, 31, 21, 32)), (10, 18)),
        (((12, 31, 19, 32),), (11,)),
    ),
    "officer_jenny": (
        (((13, 29, 16, 32), (17, 29, 19, 32)), (12, 18)),
        None,
        (((13, 31, 17, 32),), (12,)),
    ),
}

POKEMON_OVERWORLD = {
    "bird": ("PIDGEY", 6),
    "monster": ("RHYDON", 6),
    "fairy": ("CLEFAIRY", 6),
    "pikachu": ("PIKACHU", 6),
    "surfing_pikachu": ("PIKACHU", 6),
    "seel": ("SEEL", 6),
    "bulbasaur": ("BULBASAUR", 3),
    "chansey": ("CHANSEY", 3),
    "clefairy": ("CLEFAIRY", 3),
    "jigglypuff": ("JIGGLYPUFF", 3),
    "oddish": ("ODDISH", 3),
    "sandshrew": ("SANDSHREW", 3),
    "snorlax": ("SNORLAX", 1),
}

DEDICATED_OVERWORLD = {"red", "oak"}

# The HGSS trainer atlas is a 10x8 block sheet.  Yellow's gym maps reuse
# generic GBC IDs (SUPER_NERD, BRUNETTE_GIRL, ROCKER, ...), so those IDs
# cannot be changed globally without replacing unrelated NPCs.  These
# aliases let main.lua swap only the named leader objects at map entry.
LEADER_OVERWORLD = {
    "gym_brock": (47, 6),
    "gym_misty": (44, 6),
    "gym_lt_surge": (42, 6),
    "gym_koga": (37, 6),
    "gym_sabrina": (43, 6),
    "gym_blaine": (48, 6),
    "gym_giovanni": (74, 6),
    "gary": (49, 6),
}

# Bulbagarden's HGSS Oak reference is intentionally only 17x25 pixels (the
# original DS game does not ship Oak in the 32px trainer atlas).  Keep it at
# that native raster and pad it into the engine's 32px cell; never upscale it
# or substitute a child/scientist charset.
OAK_HGSS_PNG = (
    "iVBORw0KGgoAAAANSUhEUgAAABEAAAAZCAYAAADXPsWXAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAABp0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuMTAw9HKhAAABaUlEQVQ4T5WVLZICMRBGczSOsBKJXIlEIpEjVyJXjpwjrERyBI6AC/UCL9UZJkOt6Eom/fVLp/MzKeectJRSjhZ9a/0GMI6/Wdvvvxsg8B6oQJydwAia93tZFsBaYM8XMyuQTxksgYbhWJb7WknKDPwHhL6BWBMGmRGYwPtlagqtbxWCiEANqKA4ju4tk91mU9Z3PR8aSAyMfXToias1cZAWRy+YcfxR/9r2ZwY4SZNWkJnZ6lMnrB42ZzgfvvLtdm+Wp5hx/E5at9ijLORTXfALqXcu3gdBazWZA0ph4w1eyiZmFrNojr2H7fJ3zZjFc+0G8q1PbXPsf4axADD6FJDWINo4HrV1iwnC2DrFfA+7UzU1+NH5XSGQvRdmsQRxArXEFYg1iVkonk5T1iLcbN7Oia+WabKUCOF7toT6XDZbfNw+LyIWAfb1qeseNgRafFPjuLd3EUIQ68Xmr/uqb/4bcPal30PP9wANlFr2myrHFwAAAABJRU5ErkJggg=="
)

TRAINER_FILES = [
    "agatha", "beauty", "biker", "birdkeeper", "blackbelt", "blaine",
    "brock", "bruno", "bugcatcher", "burglar", "channeler",
    "cooltrainerf", "cooltrainerm", "cueball", "engineer", "erika",
    "fisher", "gambler", "gentleman", "giovanni", "hiker",
    "jessie_james", "jr.trainerf", "jr.trainerm", "juggler", "koga",
    "lance", "lass", "lorelei", "lt.surge", "misty", "pokemaniac",
    "prof.oak", "psychic", "rival1", "rival2", "rival3", "rocker",
    "rocket", "sabrina", "sailor", "scientist", "supernerd",
    "swimmer", "tamer", "youngster",
]

def open_rgba(path: Path) -> Image.Image:
    if not path.is_file():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGBA")


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "PNG", optimize=False, compress_level=9)


def resize_runtime(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return image.resize(size, RESAMPLE)


def four_shade(image: Image.Image) -> Image.Image:
    """Author a stable four-shade portrait for the engine's trainer palette."""
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    src = image.load()
    dst = out.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = src[x, y]
            if not a:
                continue
            lum = (2126 * r + 7152 * g + 722 * b) // 10000
            value = 255 if lum >= 216 else 170 if lum >= 136 else 85 if lum >= 56 else 0
            dst[x, y] = (value, value, value, a)
    return out


def build_battle() -> None:
    front_src = MOD / "assets/graphics/pokemon/front"
    back_src = MOD / "assets/graphics/pokemon/back"
    front_dst = MOD / "overrides/battle/front"
    back_dst = MOD / "overrides/battle/back"

    for _, source_name, cache_name in SPECIES:
        # Preserve the authored HGSS 80x80 raster. BattleState applies the
        # exact 1x scale at draw time, so no resize distorts it.
        front = open_rgba(front_src / f"{source_name}.png")
        back = open_rgba(back_src / f"{source_name}.png")
        if front.size != (80, 80) or back.size != (80, 80):
            raise ValueError(f"unexpected battle source size: {source_name}")
        save_png(front, front_dst / f"{cache_name}.png")
        save_png(back, back_dst / f"{cache_name}b.png")

    trainer_dst = MOD / "overrides/battle/trainers"
    for name in TRAINER_FILES:
        prepared = trainer_dst / f"{name}.png"
        portrait = open_rgba(prepared)
        if portrait.size != (80, 80):
            raise ValueError(f"unexpected prepared trainer size: {name}")
        if not (MOD / f"assets/graphics/trainers/front_hd/{name}.png").is_file():
            raise FileNotFoundError(f"missing audited HD trainer: {name}")

    # Non-species battle pics do not have a trueColor registry flag.
    for cache_name, source_name in {
        "ghost": "GASTLY",
        "fossilaerodactyl": "AERODACTYL",
        "fossilkabutops": "KABUTOPS",
    }.items():
        pic = resize_runtime(open_rgba(front_src / f"{source_name}.png"), (40, 40))
        save_png(four_shade(pic), front_dst / f"{cache_name}.png")

    red_back = open_rgba(MOD / "assets/graphics/trainers/back/RED_BATTLE_ANIM.png")
    if red_back.size != (400, 80):
        raise ValueError("unexpected animated Red battle back source size")
    save_png(red_back, MOD / "overrides/battle/redb.png")

    # Yellow's catch/tutorial battle puts Oak in the player's back slot.
    # This is a dedicated 80px rear-facing battle sprite, not an overworld
    # frame or the frontal trainer portrait.
    oak_back = open_rgba(MOD / "assets/graphics/trainers/back/PROF_OAK_BACK_USER_ANIM.png")
    if oak_back.size != (320, 80):
        raise ValueError("unexpected animated Professor Oak battle back source size")
    save_png(oak_back, MOD / "overrides/battle/profoakb.png")

    red_front = open_rgba(MOD / "overrides/trainer_card/red.png")
    if red_front.size != (56, 56):
        raise ValueError("unexpected prepared trainer-card Red size")


def strip_from_frames(
    frames: list[Image.Image], count: int, frame_size: int = 32
) -> Image.Image:
    """Build a DS-density strip without an intermediate resample."""
    out = Image.new("RGBA", (frame_size, frame_size * count), (0, 0, 0, 0))
    for i, frame in enumerate(frames[:count]):
        if frame.size != (frame_size, frame_size):
            raise ValueError(f"unexpected overworld frame size: {frame.size}")
        out.alpha_composite(frame, (0, i * frame_size))
    return out


def build_dedicated_overworld() -> None:
    src_dir = MOD / "source/overworld_dedicated"
    dst_dir = MOD / "overrides/sprites"
    # Dedicated sources use the old interleaved order:
    # down stand/walk, up stand/walk, left stand/walk.
    native_order = [0, 2, 4, 1, 3, 5]
    built: dict[str, list[Image.Image]] = {}
    for name in DEDICATED_OVERWORLD:
        if name == "red":
            # The authored HGSS Red sheet is a 4x4 atlas.  Its useful Red
            # columns are: 0=back poses, 1=right-facing side poses, 2=front
            # poses; column 3 is a different black-clad character and must
            # never be used for Red.  The atlas is not in the engine's final
            # direction order, so select the known standing/walking cells
            # explicitly.  Mirror column 1 once to make the stored side frame
            # face left (the renderer mirrors it back for a right-facing Red).
            # This keeps the authored DS art at native 32px density while
            # removing only the matte background.
            src = open_rgba(
                MOD / "assets/graphics/trainers/overworld/RED.png"
            )
            if src.size != (128, 128):
                raise ValueError(f"unexpected Red overworld sheet size: {src.size}")

            def clear_cell_background(cell: Image.Image) -> Image.Image:
                corners = {
                    cell.getpixel((0, 0))[:3],
                    cell.getpixel((31, 0))[:3],
                    cell.getpixel((0, 31))[:3],
                    cell.getpixel((31, 31))[:3],
                }
                pixels = cell.load()
                for y in range(32):
                    for x in range(32):
                        r, g, b, a = pixels[x, y]
                        if a and (r, g, b) in corners:
                            pixels[x, y] = (r, g, b, 0)
                return cell

            # Runtime order: stand down/up/left, walk down/up/left.
            red_cells = [(2, 1), (0, 0), (1, 0), (2, 2), (2, 0), (1, 1)]
            frames = []
            for col, row in red_cells:
                cell = clear_cell_background(
                    src.crop((col * 32, row * 32,
                              (col + 1) * 32, (row + 1) * 32))
                )
                if col == 1:
                    cell = cell.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
                frames.append(cell)
        elif name == "oak":
            # The verified Oak frame is preserved as the first cell.  The
            # remaining five cells were generated from that frame as a
            # chroma-keyed pixel-art reference: back, side and walking poses
            # in the engine's runtime order.  Keep the source as a complete
            # 32x192 sheet so every rebuild remains deterministic and does not
            # accidentally substitute Professor Elm's charset.
            source_path = MOD / "assets/graphics/trainers/overworld/oak_animated_ai.png"
            src = open_rgba(source_path)
            if src.size != (32, 192):
                raise ValueError(f"unexpected animated Oak sheet size: {src.size}")
            authored = [src.crop((0, i * 32, 32, (i + 1) * 32))
                        for i in range(6)]
            # The generated walking poses changed Oak's head, face and coat
            # between phases.  Importing their bottom rows also left detached
            # shoe pixels below the body.  Build every step exclusively from
            # its verified standing pose and move only the connected two-row
            # shoes by one pixel.  No pixel from the rejected poses survives.
            frames = authored[:3]
            shoe_edits = (
                # (source rectangles, destination x positions)
                (((10, 29, 14, 31), (17, 29, 21, 31)), (9, 18)),
                (((11, 29, 15, 31), (17, 29, 21, 31)), (10, 18)),
                (((13, 29, 19, 31),), (12,)),
            )
            for direction, (rectangles, destinations) in enumerate(shoe_edits):
                stand = authored[direction]
                walk = stand.copy()
                if direction == 2:
                    # Match Red's lateral gait: lock the head/upper body and
                    # use the authored lower-body stride with separated feet.
                    walk.paste(authored[5].crop((0, 20, 32, 32)), (0, 20))
                else:
                    for rectangle in rectangles:
                        walk.paste((0, 0, 0, 0), rectangle)
                    for rectangle, dest_x in zip(rectangles, destinations):
                        walk.alpha_composite(stand.crop(rectangle), (dest_x, 29))
                frames.append(walk)
        else:
            source_path = src_dir / f"{name}_32x192.png"
            if source_path.is_file():
                src = open_rgba(source_path)
                if src.size != (32, 192):
                    raise ValueError(f"unexpected dedicated sheet size: {name} {src.size}")
                frames = [src.crop((0, i * 32, 32, (i + 1) * 32))
                          for i in native_order]
            else:
                # Keep rebuilding deterministic if a generated workspace no
                # longer carries the optional source sheet: the previous
                # runtime output is already in engine frame order.
                fallback = dst_dir / f"{name}.png"
                src = open_rgba(fallback)
                if src.size != (32, 192):
                    raise FileNotFoundError(source_path)
                frames = [src.crop((0, i * 32, 32, (i + 1) * 32))
                          for i in range(6)]
        built[name] = frames
        save_png(strip_from_frames(frames, 6, 32), dst_dir / f"{name}.png")

    # The old mod made red_bike byte-identical to walking Red.  Build a
    # compact front/back/side bicycle behind the dedicated Red poses so the
    # player's identity and the vehicle both survive the 16px engine frame.
    bike_frames: list[Image.Image] = []
    for index, red in enumerate(built["red"]):
        layer = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        draw = ImageDraw.Draw(layer)
        outline = (32, 37, 48, 255)
        metal = (136, 152, 168, 255)
        accent = (200, 152, 56, 255)
        if index in (0, 1, 3, 4):
            draw.ellipse((12, 20, 20, 31), outline=outline, width=2)
            draw.line((12, 23, 20, 23), fill=metal, width=2)
            draw.line((16, 18, 16, 26), fill=metal, width=2)
            draw.line((12, 18, 20, 18), fill=accent, width=2)
        else:
            draw.ellipse((2, 22, 11, 31), outline=outline, width=2)
            draw.ellipse((20, 22, 29, 31), outline=outline, width=2)
            draw.line((6, 26, 16, 20, 24, 26, 6, 26), fill=metal, width=2)
            draw.line((16, 20, 19, 17), fill=accent, width=2)
        layer.alpha_composite(red)
        bike_frames.append(layer)
    save_png(strip_from_frames(bike_frames, 6, 32), dst_dir / "red_bike.png")


def transparent_block(sheet: Image.Image, block_index: int) -> Image.Image:
    cols = 10
    bx = (block_index % cols) * 96
    by = (block_index // cols) * 128
    if by + 128 > 1024 or bx >= sheet.width:
        raise ValueError(f"trainer block outside useful sheet: {block_index}")
    block = sheet.crop((bx, by, bx + 96, by + 128)).convert("RGBA")
    # The last physical block is three pixels narrower in the credited sheet.
    xr = min(90, sheet.width - 1 - bx)
    corners = [
        sheet.getpixel((bx, by))[:3],
        sheet.getpixel((bx + xr, by))[:3],
        sheet.getpixel((bx, by + 127))[:3],
        sheet.getpixel((bx + xr, by + 127))[:3],
    ]
    background = Counter(corners).most_common(1)[0][0]
    pixels = block.load()
    for y in range(block.height):
        for x in range(block.width):
            r, g, b, a = pixels[x, y]
            if a and (r, g, b) == background:
                pixels[x, y] = (r, g, b, 0)
            elif a:
                pixels[x, y] = (r, g, b, 255)
    return block


def human_frames(sheet: Image.Image, block_index: int) -> list[Image.Image]:
    block = transparent_block(sheet, block_index)
    # Native engine order: stand down/up/left, walk down/up/left.
    cells = [(1, 2), (3, 1), (2, 0), (1, 1), (0, 0), (1, 0)]

    def clear_cell_background(cell: Image.Image) -> Image.Image:
        # A few source block boundaries carry a one-pixel strip of the next
        # panel colour.  Every authored sprite has empty corners, so clearing
        # all exact opaque corner colours removes both the main matte and the
        # seam without a tolerance that could eat clothing or skin pixels.
        corners = {
            cell.getpixel((0, 0))[:3],
            cell.getpixel((31, 0))[:3],
            cell.getpixel((0, 31))[:3],
            cell.getpixel((31, 31))[:3],
        }
        pixels = cell.load()
        for y in range(32):
            for x in range(32):
                r, g, b, a = pixels[x, y]
                if a and (r, g, b) in corners:
                    pixels[x, y] = (r, g, b, 0)
        return cell

    return [
        clear_cell_background(
            block.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))
        )
        for row, col in cells
    ]


def clear_flat_background(cell: Image.Image) -> Image.Image:
    """Remove the exact flat matte used behind a native Gen IV frame."""
    cell = cell.convert("RGBA")
    corners = Counter(
        [
            cell.getpixel((0, 0))[:3],
            cell.getpixel((31, 0))[:3],
            cell.getpixel((0, 31))[:3],
            cell.getpixel((31, 31))[:3],
        ]
    )
    background = corners.most_common(1)[0][0]
    pixels = cell.load()
    for y in range(32):
        for x in range(32):
            r, g, b, a = pixels[x, y]
            if a and (r, g, b) == background:
                pixels[x, y] = (r, g, b, 0)
    return cell


def platinum_npc_frames(sheet: Image.Image, x: int, y: int) -> list[Image.Image]:
    """Extract down/up/left stand and walk poses from a vertical Pt charset."""
    # Source sequence: down stand, up stand, left stand, up walk L/R,
    # down walk L/R, left walk L/R.  The runtime needs one walk phase.
    rows = [0, 1, 2, 5, 3, 7]
    return [
        clear_flat_background(sheet.crop((x, y + row * 32, x + 32, y + (row + 1) * 32)))
        for row in rows
    ]


def rmxp_npc_frames(source: Image.Image) -> list[Image.Image]:
    """Convert a 4x4 2x-scale RMXP character atlas to engine frame order."""
    if source.size != (256, 256):
        raise ValueError(f"unexpected Gen IV community charset size: {source.size}")
    # Rows are down/left/right/up. Column 0 is idle; column 1 is a walk phase.
    cells = [(0, 0), (3, 0), (1, 0), (0, 1), (3, 1), (1, 1)]
    return [
        source.crop((col * 64, row * 64, (col + 1) * 64, (row + 1) * 64)).resize(
            (32, 32), Image.Resampling.NEAREST
        )
        for row, col in cells
    ]


def pokemon_frames(name: str) -> list[Image.Image]:
    sheet = open_rgba(MOD / f"assets/graphics/pokemon/overworld/{name}.png")
    if sheet.size != (128, 128):
        raise ValueError(f"unexpected follower sheet size: {name} {sheet.size}")
    # rows down/left/right/up; col 0 is stand and col 1 is the walk phase.
    cells = [(0, 0), (3, 0), (1, 0), (0, 1), (3, 1), (1, 1)]
    return [
        sheet.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))
        for row, col in cells
    ]


def build_overworld() -> None:
    dst = MOD / "overrides/sprites"
    build_dedicated_overworld()
    human_sheet_source = open_rgba(
        MOD / "assets/graphics/trainers/overworld/trainers_sheet.png"
    )
    # The credited PNG is 957px wide although its useful atlas is a 10x
    # 96px grid.  The three missing columns are distributed through the
    # raster, so direct x=block*96 crops leak a neighbour's background as a
    # one-pixel stripe.  Restore the authored 960px grid once, with nearest,
    # before taking any cells.  The useful vertical area is exactly 1024px.
    human_sheet = human_sheet_source.crop(
        (0, 0, human_sheet_source.width, 1024)
    ).resize((960, 1024), RESAMPLE)
    for name, (block_index, count) in HUMAN_SPRITES.items():
        if name == "scientist":
            # The supplied HGSS Scientist charset is four 32x48 poses per
            # direction (the 128x192 sheet is 4 columns x 4 rows).  Use the
            # complete 48px pose; slicing it as 32x64 leaks the next row's
            # head below the character. Fit each complete pose into the
            # engine's regular 32x32 NPC cell.
            source = open_rgba(
                MOD / "assets/graphics/trainers/overworld/SCIENTIST_HGSS.png"
            )
            if source.size != (128, 192):
                raise ValueError("unexpected HGSS scientist charset size")
            cells = []
            for col, row in ((0, 0), (0, 3), (0, 1), (1, 0), (1, 3), (1, 1)):
                cells.append(source.crop((col * 32, row * 48,
                                          (col + 1) * 32, (row + 1) * 48)))
            # Preserve every authored pixel. The runtime adapter understands
            # this character's native 32x48 cells; the previous 16x32 resize
            # halved the scientist's width and visibly deformed the sprite.
            fitted = Image.new("RGBA", (32, 48 * len(cells)), (0, 0, 0, 0))
            for frame, cell in enumerate(cells):
                fitted.alpha_composite(cell, (0, frame * 48))
            save_png(fitted, dst / "scientist.png")
            continue
        save_png(
            strip_from_frames(human_frames(human_sheet, block_index), count, 32),
            dst / f"{name}.png",
        )
    platinum_sheet = open_rgba(
        MOD / "assets/graphics/trainers/overworld/platinum_npcs.png"
    )
    for name, (x, y, count) in PLATINUM_NPC_SPRITES.items():
        save_png(
            strip_from_frames(platinum_npc_frames(platinum_sheet, x, y), count, 32),
            dst / f"{name}.png",
        )
    community_dir = MOD / "assets/graphics/trainers/overworld/gen4_community"
    for name, (filename, count) in COMMUNITY_NPC_SPRITES.items():
        save_png(
            strip_from_frames(rmxp_npc_frames(open_rgba(community_dir / filename)), count, 32),
            dst / f"{name}.png",
        )
    ai_dir = MOD / "assets/graphics/trainers/overworld/ai_generated"
    for name, count in AI_NPC_SPRITES.items():
        source_name = ("jessie_reference_32x192.png" if name == "jessie"
                       else f"{name}_32x192.png")
        source = open_rgba(ai_dir / source_name)
        if source.size != (32, 192):
            raise ValueError(f"unexpected AI charset size: {name} {source.size}")
        if name == "jessie":
            # The user-supplied 4x4 Jessie sheet already contains faithful
            # full-body walking poses. Preserve them instead of applying the
            # generic generated-character stabilizer. Only the standing-left
            # crop needs a one-pixel baseline correction after extraction.
            frames = [source.crop((0, i * 32, 32, (i + 1) * 32))
                      for i in range(6)]
            aligned_left = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
            aligned_left.alpha_composite(frames[2], (0, 1))
            frames[2] = aligned_left
            save_png(strip_from_frames(frames, count, 32), dst / f"{name}.png")
            continue
        standing = [source.crop((0, i * 32, 32, (i + 1) * 32))
                    for i in range(3)]
        frames = standing[:]
        for direction, edit in enumerate(AI_WALK_SHOE_EDITS[name]):
            walk = standing[direction].copy()
            if direction == 2:
                # Red's side step changes the complete lower-body silhouette:
                # one leg advances while the other trails. Preserve rows 0-19
                # exactly and reuse the generated stride only below the waist.
                generated_walk = source.crop((0, 5 * 32, 32, 6 * 32))
                walk.paste(generated_walk.crop((0, 20, 32, 32)), (0, 20))
            elif edit is not None:
                rectangles, destinations = edit
                for rectangle in rectangles:
                    walk.paste((0, 0, 0, 0), rectangle)
                for rectangle, dest_x in zip(rectangles, destinations):
                    walk.alpha_composite(standing[direction].crop(rectangle),
                                         (dest_x, rectangle[1]))
            frames.append(walk)
        save_png(strip_from_frames(frames, count, 32), dst / f"{name}.png")
    for name, (block_index, count) in LEADER_OVERWORLD.items():
        save_png(
            strip_from_frames(human_frames(human_sheet, block_index), count, 32),
            dst / f"{name}.png",
        )
    for name, (species, count) in POKEMON_OVERWORLD.items():
        save_png(strip_from_frames(pokemon_frames(species), count, 32), dst / f"{name}.png")

def icon_frames(name: str) -> list[Image.Image]:
    sheet = open_rgba(MOD / f"assets/graphics/pokemon/overworld/{name}.png")
    if name == "MEW":
        # This source has one centered pose per row crossing both the c1/c2
        # seam and the usual 32px row boundary.  The first complete pose is
        # y=27..51, not y=0..31 like the regular 4x4 sheets.
        return [sheet.crop((48, 24, 80, 56)),
                sheet.crop((48, 56, 80, 88))]
    return [sheet.crop((0, 0, 32, 32)), sheet.crop((32, 0, 64, 32))]


def build_icons() -> None:
    dst = MOD / "assets/icons"
    for _, source_name, cache_name in SPECIES:
        # Keep the authored DS-density frames.  PartyMenu's stock 16x16
        # object path is a Game Boy compatibility path; the mod's runtime
        # adapter draws these 32x32 frames directly and marks them trueColor
        # so the SGB shade-remap shader cannot collapse HGSS hues.
        icon = Image.new("RGBA", (32, 64), (0, 0, 0, 0))
        for frame, y in zip(icon_frames(source_name), (0, 32)):
            icon.alpha_composite(frame, (0, y))
        save_png(icon, dst / f"{cache_name}.png")


def build_ui() -> None:
    # Nine private 8x8 glyphs at base 0x200: tl, h, tr, v, bl, br, cursor,
    # hollow cursor, more arrow.  Keeping them above the ROM font ranges lets
    # field.theme reskin global chrome without replacing any text character.
    page = Image.new("RGBA", (72, 8), (0, 0, 0, 0))
    draw = ImageDraw.Draw(page)
    ink = (34, 37, 48, 255)

    # Border tiles follow the engine's established 8x8 rail positions. The
    # previous hand-built corners started their rails on rows 0/7 while the
    # repeat tiles used rows 1/3, leaving visible breaks at every corner.
    # These six joined glyphs keep the HGSS double-rail ornament while making
    # the repeated top, bottom and side segments line up pixel-perfectly.
    border_tiles = [
        [
            "........", "...##...", "..#.##.#", ".######.",
            ".#....#.", "..#..#.#", "...##.#.", "...#.#..",
        ],
        [
            "........", "........", "########", "........",
            "########", "########", "........", "........",
        ],
        [
            "........", "...##...", "#.#.##..", ".######.",
            ".#....#.", "#.#..#..", ".#.##...", "..#.#...",
        ],
        [
            "..#.#...", "..#.#...", "..#.#...", "..#.#...",
            "..#.#...", "..#.#...", "..#.#...", "..#.#...",
        ],
        [
            "...#.#..", "...##.#.", "..#.##.#", ".######.",
            ".#....#.", "..#..#.#", "...##...", "........",
        ],
        [
            "..#.#...", ".#.##...", "#.#.##..", ".######.",
            ".#....#.", "#.#..#..", "...##...", "........",
        ],
    ]
    for tile, rows in enumerate(border_tiles):
        ox = tile * 8
        for y, row in enumerate(rows):
            for x, pixel in enumerate(row):
                if pixel == "#":
                    draw.point((ox + x, y), fill=ink)

    # Compact DS-era menu markers.  These are deliberately authored as
    # one-color glyphs so every supported GBC/SGB palette treats them like
    # the native font instead of color-keying arbitrary RGB values.
    draw.polygon([(49, 1), (49, 6), (54, 3)], fill=ink)
    draw.line([(57, 1), (57, 6), (62, 3), (57, 1)], fill=ink)
    draw.polygon([(65, 2), (70, 2), (67, 6)], fill=ink)

    save_png(page, MOD / "assets/ui/hgss_border.png")

    # TrainerCard does not use Font.drawBox: it has a dedicated nine-tile
    # frame sheet.  Repack the same chrome into its unusual tile order:
    # 0 bottom, 1 right, 2 tl, 3 top, 4 tr, 5 left, 6 bl, 7 br, 8 pattern.
    trainer_frame = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    glyph = [page.crop((i * 8, 0, i * 8 + 8, 8)) for i in range(6)]
    frame_tiles = {
        0: glyph[1].transpose(Image.Transpose.FLIP_TOP_BOTTOM),
        1: glyph[3].transpose(Image.Transpose.FLIP_LEFT_RIGHT),
        2: glyph[0],
        3: glyph[1],
        4: glyph[2],
        5: glyph[3],
        6: glyph[4],
        7: glyph[5],
    }
    for index, tile in frame_tiles.items():
        trainer_frame.alpha_composite(tile, ((index % 3) * 8, (index // 3) * 8))
    save_png(trainer_frame, MOD / "overrides/trainer_card/trainer_info.png")

    # The BADGES banner's two dots become small Poké Ball seals.
    circle = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    cd = ImageDraw.Draw(circle)
    cd.ellipse((1, 1, 6, 6), outline=ink)
    cd.line((1, 3, 6, 3), fill=ink)
    cd.rectangle((3, 2, 4, 4), fill=(255, 255, 255, 255), outline=ink)
    save_png(circle, MOD / "overrides/trainer_card/circle_tile.png")

    # Eight [leader face, badge] pairs, exactly as TrainerCard.lua consumes
    # badges.png.  The leaders come from this project's HGSS portraits so
    # Yellow keeps Koga and Giovanni instead of HGSS-era Janine and Blue.
    badge_atlas = open_rgba(MOD / "assets/graphics/ui/badge_case.png")
    badge_crops = [
        (257, 383, 281, 407), (359, 383, 383, 407),
        (257, 446, 281, 470), (359, 446, 383, 470),
        (257, 509, 281, 533), (359, 509, 383, 533),
        (257, 572, 281, 596), (359, 572, 383, 596),
    ]
    leaders = [
        ("brock", 8), ("misty", 0), ("lt.surge", 0), ("erika", 2),
        ("koga", 0), ("sabrina", 0), ("blaine", 0), ("giovanni", 0),
    ]
    badges = Image.new("RGBA", (16, 256), (0, 0, 0, 0))
    for index, ((leader, y0), crop) in enumerate(zip(leaders, badge_crops)):
        portrait = open_rgba(MOD / f"source/battle_trainers_80/{leader}.png")
        face = portrait.crop((24, y0, 56, y0 + 32)).resize(
            (16, 16), Image.Resampling.NEAREST
        )
        badge = badge_atlas.crop(crop).resize((16, 16), Image.Resampling.NEAREST)
        badges.alpha_composite(face, (0, index * 32))
        badges.alpha_composite(badge, (0, index * 32 + 16))
    save_png(badges, MOD / "overrides/trainer_card/badges.png")


def generated_overworld_files() -> dict[str, int]:
    files = {name: count for name, (_, count) in HUMAN_SPRITES.items()}
    files.update({name: count for name, (_, count) in POKEMON_OVERWORLD.items()})
    files.update({name: 6 for name in DEDICATED_OVERWORLD})
    files.update({name: count for name, (_, count) in LEADER_OVERWORLD.items()})
    files["red_bike"] = 6
    return files


def verify() -> list[str]:
    errors: list[str] = []

    def expect(path: Path, size: tuple[int, int]) -> None:
        try:
            actual = Image.open(path).size
        except Exception as exc:  # pragma: no cover - emitted to CLI
            errors.append(f"{path.relative_to(ROOT)}: cannot decode ({exc})")
            return
        if actual != size:
            errors.append(f"{path.relative_to(ROOT)}: {actual}, expected {size}")

    if len(SPECIES) != 151:
        errors.append(f"species table has {len(SPECIES)}, expected 151")
    if len(set(row[0] for row in SPECIES)) != 151:
        errors.append("duplicate species registry id")

    for _, _, cache_name in SPECIES:
        expect(MOD / f"overrides/battle/front/{cache_name}.png", (80, 80))
        expect(MOD / f"overrides/battle/back/{cache_name}b.png", (80, 80))
        icon_path = MOD / f"assets/icons/{cache_name}.png"
        expect(icon_path, (32, 64))
        if icon_path.is_file():
            icon = open_rgba(icon_path)
            for frame in range(2):
                alpha = icon.crop((0, frame * 32, 32, (frame + 1) * 32)).getchannel("A")
                box = alpha.getbbox()
                if box is None or (box[2] - box[0]) * (box[3] - box[1]) < 30:
                    errors.append(
                        f"{icon_path.relative_to(ROOT)} frame {frame}: "
                        f"implausibly empty alpha bounds {box}"
                    )

    for name in TRAINER_FILES:
        expect(MOD / f"overrides/battle/trainers/{name}.png", (80, 80))
    for name in ["ghost", "fossilaerodactyl", "fossilkabutops"]:
        expect(MOD / f"overrides/battle/front/{name}.png", (40, 40))
    expect(MOD / "overrides/battle/redb.png", (400, 80))
    expect(MOD / "overrides/battle/profoakb.png", (320, 80))
    expect(MOD / "overrides/trainer_card/red.png", (56, 56))
    expect(MOD / "overrides/trainer_card/trainer_info.png", (24, 24))
    expect(MOD / "overrides/trainer_card/circle_tile.png", (8, 8))
    expect(MOD / "overrides/trainer_card/badges.png", (16, 256))

    for name, frames in generated_overworld_files().items():
        height = frames * (48 if name == "scientist" else 32)
        expect(MOD / f"overrides/sprites/{name}.png", (32, height))
    red_path = MOD / "overrides/sprites/red.png"
    if red_path.is_file():
        red = open_rgba(red_path)
        # The authored Red stand-down frame has a solid cap crown beginning
        # at y=7.  This catches the old derivative where those pixels were
        # accidentally transparent while leaving the outer cell background
        # transparent as intended.
        if red.getpixel((15, 7))[3] == 0:
            errors.append("overrides/sprites/red.png: cap crown is transparent")
    oak_path = MOD / "overrides/sprites/oak.png"
    if oak_path.is_file():
        oak = open_rgba(oak_path)
        for direction in range(3):
            stable_rows = 20 if direction == 2 else 29
            stand = oak.crop((0, direction * 32, 32,
                              direction * 32 + stable_rows))
            walk_y = (direction + 3) * 32
            walk = oak.crop((0, walk_y, 32, walk_y + stable_rows))
            if stand.tobytes() != walk.tobytes():
                errors.append(
                    f"overrides/sprites/oak.png direction {direction}: "
                    "head/torso changes between stand and walk"
                )
        baselines = []
        for frame in range(6):
            alpha = oak.crop((0, frame * 32, 32, (frame + 1) * 32)).getchannel("A")
            box = alpha.getbbox()
            baselines.append(None if box is None else box[3])
        if len(set(baselines)) != 1:
            errors.append(
                f"overrides/sprites/oak.png: inconsistent baselines {baselines}"
            )
    for name in AI_NPC_SPRITES:
        path = MOD / f"overrides/sprites/{name}.png"
        if not path.is_file():
            continue
        sheet = open_rgba(path)
        baselines = []
        for direction in range(3):
            stable_rows = 20 if direction == 2 else 29
            stand = sheet.crop((0, direction * 32, 32,
                                direction * 32 + stable_rows))
            walk_y = (direction + 3) * 32
            walk = sheet.crop((0, walk_y, 32, walk_y + stable_rows))
            if name != "jessie" and stand.tobytes() != walk.tobytes():
                errors.append(
                    f"overrides/sprites/{name}.png direction {direction}: "
                    "head/torso changes between stand and walk"
                )
        for frame in range(6):
            alpha = sheet.crop((0, frame * 32, 32, (frame + 1) * 32)).getchannel("A")
            box = alpha.getbbox()
            baselines.append(None if box is None else box[3])
        if len(set(baselines)) != 1:
            errors.append(
                f"overrides/sprites/{name}.png: inconsistent baselines {baselines}"
            )
    expect(MOD / "assets/ui/hgss_border.png", (72, 8))

    try:
        manifest = json.loads((MOD / "manifest.json").read_text(encoding="utf-8"))
        if manifest.get("api") != 2:
            errors.append("manifest api must be 2")
        if manifest.get("permissions") != ["engine_internals"]:
            errors.append("runtime must declare engine_internals for the 32px overworld adapter")
    except Exception as exc:
        errors.append(f"manifest.json: {exc}")

    main = (MOD / "main.lua").read_text(encoding="utf-8")
    if "assets/generated/" in main:
        errors.append("main.lua references the ROM-derived cache")
    return errors


def runtime_files() -> list[Path]:
    files = [
        MOD / "manifest.json",
        MOD / "main.lua",
        MOD / "mod.card",
        MOD / "README.md",
        MOD / "CHANGELOG.md",
        MOD / "assets/ui/hgss_border.png",
        MOD / "overrides/battle/redb.png",
        MOD / "overrides/battle/profoakb.png",
        MOD / "assets/graphics/intro_hd/red.png",
        MOD / "overrides/trainer_card/red.png",
        MOD / "overrides/trainer_card/trainer_info.png",
        MOD / "overrides/trainer_card/circle_tile.png",
        MOD / "overrides/trainer_card/badges.png",
    ]
    files += [MOD / f"assets/icons/{row[2]}.png" for row in SPECIES]
    files += [MOD / f"overrides/battle/front/{row[2]}.png" for row in SPECIES]
    files += [MOD / f"overrides/battle/back/{row[2]}b.png" for row in SPECIES]
    files += [MOD / f"overrides/battle/trainers/{name}.png" for name in TRAINER_FILES]
    files += [MOD / f"assets/graphics/trainers/front_hd/{name}.png" for name in TRAINER_FILES]
    files += [MOD / f"assets/graphics/pokemon/front_hd/{row[1]}.png" for row in SPECIES]
    files += [
        MOD / f"overrides/battle/front/{name}.png"
        for name in ["ghost", "fossilaerodactyl", "fossilkabutops"]
    ]
    files += [
        MOD / f"overrides/sprites/{name}.png"
        for name in generated_overworld_files()
    ]
    return files


def package() -> Path:
    dist_root = (ROOT / "tools/dist").resolve()
    stage = (dist_root / "HGSS_SPRITES").resolve()
    if stage.parent != dist_root:
        raise RuntimeError(f"unsafe staging path: {stage}")
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir(parents=True)

    for source in runtime_files():
        if not source.is_file():
            raise FileNotFoundError(source)
        target = stage / source.relative_to(MOD)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)

    archive = ROOT / "HGSS_SPRITES-0.0.9.zip"
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for source in sorted(stage.rglob("*")):
            if source.is_file():
                zf.write(source, source.relative_to(stage).as_posix())
    return archive


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="verify without rebuilding")
    parser.add_argument("--package", action="store_true", help="also create the lean release ZIP")
    args = parser.parse_args()

    if not args.check:
        build_battle()
        build_overworld()
        build_icons()
        build_ui()

    errors = verify()
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("OK: 151 battle pairs, 151 party icons, all mapped overworld sprites")
    if args.package:
        archive = package()
        print(f"OK: package {archive} ({archive.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
