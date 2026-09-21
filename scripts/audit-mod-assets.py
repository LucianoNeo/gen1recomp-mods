"""Read-only asset reachability audit for the current HGSS runtime.

Run from any directory. Optional JSON output records every decision; this
script never deletes assets. Dynamic paths are expanded from the runtime's
registries, not inferred from filenames containing a generation number.
"""
import argparse
import collections
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "hgss_sprites"


def audit():
    sources = [MOD / "main.lua", *sorted((MOD / "lib").glob("*.lua"))]
    code = "\n".join(p.read_text(encoding="utf-8-sig") for p in sources)
    # Comments do not establish runtime usage.
    code = re.sub(r"--\[\[.*?\]\]", "", code, flags=re.S)
    code = re.sub(r"--[^\n]*", "", code)
    used = {}

    def keep(path, reason):
        used[path] = reason

    for path in re.findall(r'["\']((?:assets|overrides)/[^"\'\n]+\.(?:png|jpg))["\']', code):
        keep(path, "literal runtime asset path")
    for path in re.findall(r'["\']((?:assets|overrides)/[^"\'\n]+)["\']', code):
        if (MOD / (path + ".png")).is_file():
            keep(path + ".png", "Gen2 sprite path with .png appended by loader")

    # Both normal and shiny tables can be queried by species, including
    # companion-provided species. Preserve all referenced Gen5 records.
    for suffix in ("", "_shiny"):
        registry = f"assets/battle/animated_battle_sprites_gen5{suffix}.lua"
        keep(registry, "active Gen5 animation registry")
        text = (MOD / registry).read_text(encoding="utf-8-sig")
        for path in re.findall(r'image\s*=\s*"([^"]+)"', text):
            if (MOD / path).is_file():
                keep(path, "active Gen5 animation record")
            elif "/back-animated/" in path:
                fallback = path.replace("/back-animated/", "/back-static/")
                if (MOD / fallback).is_file():
                    keep(fallback, "required missing-atlas fallback")

    # Party, PC and Day-Care icons use National Dex names, not battle slugs.
    for table in ("SPECIES", "GEN2_SPECIES"):
        block = re.search(r"local " + table + r" = \[\[(.*?)\]\]", code, re.S).group(1)
        for species in block.split():
            name = {"NIDORAN_F": "nidoranf", "NIDORAN_M": "nidoranm", "MR_MIME": "mr.mime"}.get(species, species.lower())
            keep(f"assets/icons/{name}.png", "party/PC/Day-Care species registry")

    for file in re.findall(r'"(\d{3}-(?:normal|shiny))"', code):
        keep(f"assets/gen2/pokemon-overworld/{file}.png", "Gen2 map Pokemon registry")
    for directory, count in re.findall(r'dir = "([^"]+)",\s*count = (\d+)', code):
        for index in range(1, int(count) + 1):
            keep(f"{directory}/{index:02}.png", "Elm starter animation frame")

    players = ("red", "ash", "ethan", "lyra", "kris", "kris_v2", "leaf", "brendan")
    for player in players:
        keep(f"assets/townmap/{player}.png", "selected player Fly marker")
        for stage in range(4):
            keep(f"overrides/sprites/{player}_fish_{stage}.png", "Gen2 fishing stage")
    for frames in (1, 3, 6):
        keep(f"assets/voxel/frame_layout_{frames}_32.png", "runtime sprite geometry proxy")

    # Player battle tables store basenames; NPC tables and Gen1 WALKERS /
    # STANDING store short IDs. Match whole names, never substrings.
    for path in (MOD / "overrides/sprites").glob("*.png"):
        stem = re.escape(path.stem)
        if re.search(r'(?<![\w])' + stem + r'(?![\w])', code, re.I):
            keep(path.relative_to(MOD).as_posix(), "overworld sprite registry / player table")
    for directory in ("back-static", "back-animated"):
        for path in (MOD / "assets/battle" / directory).glob("*.png"):
            if f'"{path.name}"' in code:
                keep(path.relative_to(MOD).as_posix(), "player battle strip/static table")

    # TRAINER ART resolves arbitrary engine class IDs by slug, including
    # classes not explicitly listed in the Gen2 alias table.
    for path in (MOD / "assets/battle/front-static/hgss").glob("*.png"):
        keep(path.relative_to(MOD).as_posix(), "HGSS trainer class slug resolver")
    for path in (MOD / "assets/graphics/pokemon/front_hd").glob("*.png"):
        keep(path.relative_to(MOD).as_posix(), "OakSpeech demoSpecies dynamic portrait")

    decisions = []
    for root in (MOD / "assets", MOD / "overrides"):
        for path in sorted(root.rglob("*")):
            if not path.is_file():
                continue
            rel = path.relative_to(MOD).as_posix()
            reason = used.get(rel)
            if path.suffix.lower() == ".md":
                # Attribution stays with retained collections. Documentation
                # in a wholly retired collection is removed with that set.
                if any(p.startswith(path.parent.relative_to(MOD).as_posix() + "/")
                       and (MOD / p).is_file() for p in used):
                    reason = "documentation/attribution for active collection"
            decisions.append(dict(path=rel, bytes=path.stat().st_size,
                                  action="keep" if reason else "remove",
                                  reason=reason or "unreachable from current runtime asset resolvers"))
    return decisions


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", type=Path)
    args = parser.parse_args()
    result = audit()
    for action in ("keep", "remove"):
        rows = [r for r in result if r["action"] == action]
        print(f"{action}: {len(rows)} files, {sum(r['bytes'] for r in rows) / 1048576:.2f} MiB")
    groups = collections.Counter()
    for row in result:
        if row["action"] == "remove":
            groups[str(Path(row["path"]).parent).replace('\\', '/')] += 1
    for directory, count in sorted(groups.items()):
        print(f"  {directory}: {count}")
    if args.json:
        args.json.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
