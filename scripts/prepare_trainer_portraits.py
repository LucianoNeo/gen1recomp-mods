"""Prepare full-color trainer portraits from the audited official sources."""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "hgss_sprites"
SOURCE = MOD / "source/trainer_official"
HD = MOD / "assets/graphics/trainers/front_hd"
RUNTIME = MOD / "overrides/battle/trainers"
REALESRGAN = ROOT / "tools/realesrgan/realesrgan-ncnn-vulkan.exe"
MODEL_DIR = ROOT / "tools/realesrgan/models"
WORK = ROOT / "tools/realesrgan/trainer_official"

NAMES = [
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


def rgba(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    # A few archived sprites use an opaque white canvas.
    pix = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = pix[x, y]
            if a and r >= 248 and g >= 248 and b >= 248:
                pix[x, y] = (r, g, b, 0)
    return im


def fit(im: Image.Image, size: int, margin: int, resample: int) -> Image.Image:
    box = im.getchannel("A").getbbox()
    if not box:
        raise ValueError("empty portrait")
    crop = im.crop(box)
    scale = min((size - margin * 2) / crop.width, (size - margin * 2) / crop.height)
    dims = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    crop = crop.resize(dims, resample)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.alpha_composite(crop, ((size - dims[0]) // 2, size - margin - dims[1]))
    return out


def composite_jessie_james(size: int, margin: int, sources: dict[str, Image.Image]) -> Image.Image:
    left = fit(sources["jessie"], size, margin, Image.Resampling.LANCZOS)
    right = fit(sources["james"], size, margin, Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # Two distinct, full-resolution Masters renders share the trainer slot.
    each = int(size * 0.69)
    for image, x in ((left, -int(size * 0.13)), (right, int(size * 0.43))):
        box = image.getchannel("A").getbbox()
        crop = image.crop(box)
        crop.thumbnail((each, size - margin * 2), Image.Resampling.LANCZOS)
        out.alpha_composite(crop, (x, size - margin - crop.height))
    return out


def main() -> None:
    HD.mkdir(parents=True, exist_ok=True)
    RUNTIME.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(parents=True, exist_ok=True)

    sources = {p.stem: rgba(p) for p in SOURCE.glob("*.png")}
    low_names = [name for name in NAMES if name != "jessie_james" and max(sources[name].size) <= 100]
    input_dir, output_dir = WORK / "input", WORK / "output"
    shutil.rmtree(input_dir, ignore_errors=True)
    shutil.rmtree(output_dir, ignore_errors=True)
    input_dir.mkdir(parents=True)
    output_dir.mkdir(parents=True)
    for name in low_names:
        sources[name].save(input_dir / f"{name}.png")
    if low_names:
        subprocess.run([
            str(REALESRGAN), "-i", str(input_dir), "-o", str(output_dir),
            "-n", "realesrgan-x4plus-anime", "-s", "4", "-f", "png",
            "-m", str(MODEL_DIR),
        ], check=True)
        for name in low_names:
            sources[name] = rgba(output_dir / f"{name}.png")

    for name in NAMES:
        if name == "jessie_james":
            hd = composite_jessie_james(320, 10, sources)
            runtime = composite_jessie_james(80, 3, sources)
        else:
            source = sources[name]
            resample = Image.Resampling.LANCZOS
            hd = fit(source, 320, 10, resample)
            runtime = fit(source, 80, 3, resample)
        hd.save(HD / f"{name}.png", optimize=False)
        runtime.save(RUNTIME / f"{name}.png", optimize=False)
        print(f"prepared {name}")

    # Red is also shown during Oak's introduction and on the trainer card.
    # Both now derive from the same 1024px official render as the battle set.
    intro = MOD / "assets/graphics/intro_hd"
    card = MOD / "overrides/trainer_card"
    intro.mkdir(parents=True, exist_ok=True)
    card.mkdir(parents=True, exist_ok=True)
    fit(sources["red"], 320, 10, Image.Resampling.LANCZOS).save(
        intro / "red.png", optimize=False
    )
    fit(sources["red"], 56, 2, Image.Resampling.LANCZOS).save(
        card / "red.png", optimize=False
    )


if __name__ == "__main__":
    main()
