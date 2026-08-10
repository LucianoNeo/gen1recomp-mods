"""Fetch distinct official trainer sprites from Bulbagarden Archives.

This intentionally keeps provenance separate from generated/runtime assets.
Named characters prefer Pokemon Masters artwork when available; trainer
classes use their HGSS sprite, falling back to FRLG only when HGSS has no
matching class.
"""

from __future__ import annotations

import json
import ssl
import urllib.parse
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "hgss_sprites/source/trainer_official"
API = "https://archives.bulbagarden.net/w/api.php"
HEADERS = {"User-Agent": "HGSS-Sprites-Mod/0.0.8 (asset provenance audit)"}

FILES = {
    "agatha": "Spr Masters Agatha.png",
    "beauty": "Spr Masters Beauty.png",
    "biker": "Spr HGSS Biker.png",
    "birdkeeper": "Spr HGSS Bird Keeper.png",
    "blackbelt": "Spr Masters Black Belt.png",
    "blaine": "Spr Masters Blaine.png",
    "brock": "Spr Masters Brock.png",
    "bruno": "Spr Masters Bruno.png",
    "bugcatcher": "Spr HGSS Bug Catcher.png",
    "burglar": "Spr HGSS Burglar.png",
    "channeler": "Spr FRLG Channeler.png",
    "cooltrainerf": "Spr Masters Ace Trainer F.png",
    "cooltrainerm": "Spr Masters Ace Trainer M.png",
    "cueball": "Spr FRLG Cue Ball.png",
    "engineer": "Spr FRLG Engineer.png",
    "erika": "Spr Masters Erika.png",
    "fisher": "Spr FRLG Fisherman.png",
    "gambler": "Spr FRLG Gamer.png",
    "gentleman": "Spr HGSS Gentleman.png",
    "giovanni": "Spr Masters Giovanni.png",
    "hiker": "Spr Masters Hiker.png",
    "jr.trainerf": "Spr FRLG Picnicker.png",
    "jr.trainerm": "Spr Masters Camper.png",
    "juggler": "Spr HGSS Juggler.png",
    "koga": "Spr Masters Koga.png",
    "lance": "Spr Masters Lance.png",
    "lass": "Spr Masters Lass.png",
    "lorelei": "Spr Masters Lorelei.png",
    "lt.surge": "Spr Masters Lt Surge.png",
    "misty": "Spr Masters Misty.png",
    "pokemaniac": "Spr HGSS Poké Maniac.png",
    "prof.oak": "Spr Masters Oak.png",
    "psychic": "Spr FRLG Psychic M.png",
    "rival1": "Spr Masters Blue Classic.png",
    "rival2": "Spr Masters Blue Classic.png",
    "rival3": "Spr Masters Blue Classic.png",
    "rocker": "Spr FRLG Rocker.png",
    "rocket": "Spr Masters Team Rocket Grunt M.png",
    "sabrina": "Spr Masters Sabrina.png",
    "sailor": "Spr FRLG Sailor.png",
    "scientist": "Spr Masters Scientist.png",
    "supernerd": "Spr HGSS Super Nerd.png",
    "swimmer": "Spr Masters Swimmer M.png",
    "tamer": "Spr FRLG Tamer.png",
    "youngster": "Spr Masters Youngster.png",
    "jessie": "Spr Masters Jessie.png",
    "james": "Spr Masters James.png",
    "red": "Spr Masters Red.png",
}


def fetch_json(params: dict[str, str]) -> dict:
    url = API + "?" + urllib.parse.urlencode(params)
    ctx = ssl._create_unverified_context()
    request = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(request, context=ctx, timeout=60) as response:
        return json.load(response)


def resolve(filename: str) -> str:
    data = fetch_json({
        "action": "query",
        "format": "json",
        "prop": "imageinfo",
        "iiprop": "url|size",
        "titles": "File:" + filename,
    })
    page = next(iter(data["query"]["pages"].values()))
    if "missing" in page or not page.get("imageinfo"):
        raise FileNotFoundError(filename)
    return page["imageinfo"][0]["url"]


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    ctx = ssl._create_unverified_context()
    failures = []
    for name, filename in FILES.items():
        try:
            url = resolve(filename)
            request = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(request, context=ctx, timeout=120) as response:
                payload = response.read()
            (OUT / f"{name}.png").write_bytes(payload)
            print(f"{name:16} {filename:34} {len(payload):8} bytes")
        except Exception as exc:
            failures.append((name, filename, str(exc)))
            print(f"FAILED {name}: {filename}: {exc}")
    (OUT / "sources.json").write_text(
        json.dumps(FILES, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    if failures:
        raise SystemExit(f"{len(failures)} downloads failed: {failures}")


if __name__ == "__main__":
    main()
