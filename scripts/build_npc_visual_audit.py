from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
MOD_DIR = ROOT / "hgss_sprites" / "overrides" / "sprites"
REF_DIR = ROOT / "tools" / "reports" / "bulbapedia_gen4"
REPORT_DIR = ROOT / "tools" / "reports"
SIMILARITY = REPORT_DIR / "npc_bulbapedia_similarity.json"


# Only entries with a visually demonstrable wrong identity are included here.
# None means that the character/class has no canonical Gen-IV overworld sprite
# in the Bulbapedia reference set and therefore needs a purpose-built HGSS-style
# sprite instead of borrowing another named character.
AUDIT = [
    ("agatha.png", None, "Agatha não aparece em HGSS; precisa de sprite próprio"),
    ("beauty.png", "Beauty_HGSS_OD.png", "Classe Beauty"),
    ("blue.png", "Blue_IV_OD.png", "Blue/Gary"),
    ("captain.png", None, "Capitão do S.S. Anne; precisa de sprite próprio"),
    ("channeler.png", "Medium_OD.png", "Channeler / Medium"),
    ("clerk.png", None, "Balconista; precisa de sprite próprio"),
    ("cook.png", None, "Cozinheiro; precisa de sprite próprio"),
    ("daisy.png", "Daisy_Oak_OD.png", "Daisy Oak"),
    ("fisher.png", "Fisherman_IV_OD.png", "Fisherman"),
    ("fishing_guru.png", "Fisherman_IV_OD.png", "Fishing Guru"),
    ("gameboy_kid.png", None, "Game Boy Kid; precisa de sprite próprio"),
    ("guard.png", "Policeman_IV_OD.png", "Guarda / policial"),
    ("gym_guide.png", "Gym_guide_IV_OD.png", "Gym Guide"),
    ("hiker.png", "Hiker_IV_OD.png", "Hiker"),
    ("james.png", None, "James não possui overworld canônico de HGSS"),
    ("jessie.png", None, "Jessie não possui overworld canônico de HGSS"),
    ("lance.png", "Lance_IV_OD.png", "Lance"),
    ("link_receptionist.png", "Teala_OD.png", "Recepcionista de comunicação"),
    ("little_boy.png", "Youngster_HGSS_OD.png", "Menino / Youngster"),
    ("lorelei.png", None, "Lorelei não aparece em HGSS; precisa de sprite próprio"),
    ("mom.png", "Mom_Kanto_OD.png", "Mãe de Red em Kanto"),
    ("mr_fuji.png", "Mr_Fuji_OD.png", "Mr. Fuji"),
    ("nurse.png", "Pokémon_Center_lady_IV_OD.png", "Enfermeira do Centro Pokémon"),
    ("officer_jenny.png", None, "Officer Jenny; precisa de sprite próprio"),
    ("rocker.png", "Guitarist_IV_OD.png", "Rocker / Guitarist"),
    ("rocket.png", "Rocket_Grunt_M_OD.png", "Rocket genérico masculino"),
    ("safari_zone_worker.png", "Worker_IV_OD.png", "Funcionário da Safari Zone"),
    ("sailor.png", "Sailor_OD.png", "Sailor"),
    ("silph_president.png", None, "Presidente da Silph; precisa de sprite próprio"),
    ("silph_worker_f.png", "NPC 06.png", "Funcionária Silph; charset Gen IV distinto de Bill"),
    ("silph_worker_m.png", "Worker_IV_OD.png", "Funcionário Silph"),
    ("super_nerd.png", "Super_Nerd_OD.png", "Super Nerd"),
    ("swimmer.png", "Swimmer_m_HGSS_OD.png", "Swimmer masculino"),
    ("waiter.png", "Waiter_IV_OD.png", "Waiter"),
    ("youngster.png", "Youngster_HGSS_OD.png", "Youngster"),
]


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    windir = Path("C:/Windows/Fonts")
    candidates = (
        [windir / "arialbd.ttf", windir / "segoeuib.ttf"]
        if bold
        else [windir / "arial.ttf", windir / "segoeui.ttf"]
    )
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


FONT_TITLE = load_font(38, True)
FONT_HEAD = load_font(23, True)
FONT_NAME = load_font(21, True)
FONT_BODY = load_font(18)
FONT_SMALL = load_font(15)


def first_frame(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    # Runtime walker sheets are 32 px wide and stack frames vertically.
    if image.height > 32 and image.width <= 32:
        image = image.crop((0, 0, image.width, min(32, image.height)))
    return image


def sprite_box(sprite: Image.Image, size: int = 116) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (246, 248, 252, 255))
    alpha = sprite.getchannel("A")
    bbox = alpha.getbbox()
    if bbox:
        sprite = sprite.crop(bbox)
    scale = min((size - 14) // max(1, sprite.width), (size - 14) // max(1, sprite.height))
    scale = max(1, scale)
    sprite = sprite.resize((sprite.width * scale, sprite.height * scale), Image.Resampling.NEAREST)
    x = (size - sprite.width) // 2
    y = size - sprite.height - 7
    canvas.alpha_composite(sprite, (x, y))
    return canvas


def wrap(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if draw.textbbox((0, 0), candidate, font=font)[2] <= width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def render_page(rows: list[tuple[str, str | None, str]], page_no: int, total_pages: int) -> Path:
    width = 1900
    header_h = 205
    row_h = 176
    height = header_h + row_h * len(rows) + 72
    canvas = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(canvas)

    draw.rectangle((0, 0, width, 128), fill="#16243b")
    draw.text((42, 25), "AUDITORIA VISUAL DE NPCs — HGSS SPRITES 2.4.10", font=FONT_TITLE, fill="white")
    draw.text(
        (44, 80),
        f"Página {page_no}/{total_pages} · comparação com a galeria Gen IV/HGSS da Bulbapedia",
        font=FONT_BODY,
        fill="#d8e7ff",
    )
    headers = [(42, "ARQUIVO DO MOD"), (600, "O QUE ELE É HOJE"), (1130, "O QUE DEVERIA SER")]
    for x, label in headers:
        draw.text((x, 154), label, font=FONT_HEAD, fill="#26364d")

    similarity = {entry["mod"]: entry["top"][0] for entry in json.loads(SIMILARITY.read_text(encoding="utf-8"))}

    for index, (mod_name, expected_name, description) in enumerate(rows):
        y = header_h + index * row_h
        fill = "#fff7f6" if index % 2 == 0 else "#fffdfc"
        draw.rectangle((0, y, width, y + row_h), fill=fill)
        draw.line((0, y, width, y), fill="#d9dee7", width=2)

        detected = similarity[mod_name]
        detected_name = detected["ref"]
        score = float(detected["score"])

        mod_sprite = sprite_box(first_frame(MOD_DIR / mod_name))
        canvas.paste(mod_sprite.convert("RGB"), (42, y + 25))
        draw.text((176, y + 37), mod_name, font=FONT_NAME, fill="#16243b")
        draw.text((176, y + 74), "sprite atual", font=FONT_SMALL, fill="#5e6878")

        detected_path = REF_DIR / detected_name
        if detected_path.exists():
            detected_sprite = sprite_box(first_frame(detected_path))
            canvas.paste(detected_sprite.convert("RGB"), (600, y + 25))
        draw.text((734, y + 32), detected_name, font=FONT_NAME, fill="#9d2017")
        draw.text((734, y + 68), f"similaridade visual: {score * 100:.1f}%", font=FONT_BODY, fill="#7c2b25")
        verdict = "CÓPIA/IDENTIDADE CONFIRMADA" if score >= 0.985 else "CORRESPONDÊNCIA VISUAL MAIS PRÓXIMA"
        draw.text((734, y + 99), verdict, font=FONT_SMALL, fill="#b13b32")

        if expected_name:
            expected_path = REF_DIR / expected_name
            if expected_path.exists():
                expected_sprite = sprite_box(first_frame(expected_path))
                canvas.paste(expected_sprite.convert("RGB"), (1130, y + 25))
            draw.text((1264, y + 32), expected_name, font=FONT_NAME, fill="#14643c")
            for line_no, line in enumerate(wrap(draw, description, FONT_BODY, 570)[:2]):
                draw.text((1264, y + 69 + line_no * 25), line, font=FONT_BODY, fill="#325544")
            draw.text((1264, y + 123), "SUBSTITUIR", font=FONT_SMALL, fill="#147a48")
        else:
            draw.rectangle((1130, y + 25, 1246, y + 141), fill="#fff0ce", outline="#e4a82a", width=3)
            draw.text((1162, y + 60), "SEM", font=FONT_HEAD, fill="#875d00")
            draw.text((1146, y + 90), "CANÔNICO", font=FONT_SMALL, fill="#875d00")
            for line_no, line in enumerate(wrap(draw, description, FONT_BODY, 570)[:3]):
                draw.text((1264, y + 35 + line_no * 25), line, font=FONT_BODY, fill="#72530f")
            draw.text((1264, y + 123), "CRIAR EM ESTILO HGSS", font=FONT_SMALL, fill="#9b6800")

    footer_y = height - 52
    draw.text(
        (42, footer_y),
        "Fonte visual: Bulbapedia — List of game characters by overworld sprite (Gen IV/HGSS).",
        font=FONT_SMALL,
        fill="#5e6878",
    )
    path = REPORT_DIR / f"npc_bulbapedia_visual_audit_2.4.10_p{page_no}.png"
    canvas.save(path, optimize=True)
    return path


def write_markdown() -> Path:
    similarity = {entry["mod"]: entry["top"][0] for entry in json.loads(SIMILARITY.read_text(encoding="utf-8"))}
    lines = [
        "# Auditoria visual de NPCs — HGSS SPRITES 2.4.10",
        "",
        "Comparação do primeiro frame de cada arquivo do mod com a galeria Gen IV/HGSS da Bulbapedia.",
        "Correspondências acima de 98,5% são tratadas como identidade visual confirmada.",
        "",
        "| Arquivo do mod | Identidade visual atual | Similaridade | Esperado |",
        "|---|---|---:|---|",
    ]
    for mod_name, expected_name, description in AUDIT:
        detected = similarity[mod_name]
        expected = expected_name or f"Sem canônico — {description}"
        lines.append(f"| `{mod_name}` | `{detected['ref']}` | {float(detected['score']) * 100:.1f}% | `{expected}` |")
    lines += [
        "",
        "Fonte: https://bulbapedia.bulbagarden.net/wiki/User:Team_Rocket_Grunt/List_of_game_characters_by_overworld_sprite",
        "",
    ]
    path = REPORT_DIR / "npc_bulbapedia_visual_audit_2.4.10.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def main() -> None:
    per_page = 18
    pages = [AUDIT[i : i + per_page] for i in range(0, len(AUDIT), per_page)]
    for number, page_rows in enumerate(pages, start=1):
        print(render_page(page_rows, number, len(pages)))
    print(write_markdown())


if __name__ == "__main__":
    main()
