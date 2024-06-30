#!/usr/bin/env python
# -*- coding:utf-8 -*-

import argparse
from pathlib import Path

import fontforge


def rename(font_fpath: Path, out_dpath: Path, add_nerd_to_name=False):
    if not font_fpath.exists():
        raise ValueError(f"{font_fpath!s} does not exists")
    if out_dpath.mkdir(parents=True, exist_ok=True):
        raise ValueError(f"{out_dpath!s} is not a directory")
    try:
        source_font = fontforge.open(str(font_fpath))
    except Exception as e:
        raise e

    family = []
    weight = []
    pattern = []
    for name in source_font.fullname.strip().split():
        if name in ["Ricty", "Diminished", "Discord", "RictyDiminished", "RictyDiscord"]:
            family.append(name)
        elif name in ["Regular", "Bold", "Oblique", "Italic"]:
            if name == "Oblique":
                name = "Italic"
            weight.append(name)
        elif name in ["Nerd"]:
            pattern.append(name)
    if len(family) == 0:
        raise ValueError(f"Fullname looks strange: {source_font.fullname}")

    weight_suffix = ("-" + "".join(weight)) if len(weight) > 0 else ""
    if add_nerd_to_name:
        fontname = "".join(family) + "".join(pattern) + weight_suffix
        familyname = " ".join([" ".join(family), " ".join(pattern)])
    else:
        fontname = "".join(family) + weight_suffix
        familyname = " ".join(family)
    stylename = " ".join(weight)
    fullname = " ".join([familyname, stylename])

    source_font.fontname = fontname
    source_font.fullname = fullname
    source_font.familyname = familyname
    source_font.appendSFNTName("English (US)", "PostScriptName", fontname)
    source_font.appendSFNTName("English (US)", "Fullname", fullname)
    source_font.appendSFNTName("English (US)", "Family", familyname)
    source_font.appendSFNTName("English (US)", "SubFamily", stylename)
    source_font.appendSFNTName("English (US)", "Preferred Family", familyname)
    source_font.appendSFNTName("English (US)", "Compatible Full", fullname)

    path = out_dpath / f"{fontname}.ttf"
    source_font.generate(str(path), flags=("opentype", "PfEd-comments"))
    source_font.close()

    return


def main():
    parser = argparse.ArgumentParser(description="rename Ricty Font")
    parser.add_argument(
        "font_fpath",
        type=Path,
        help="The path to the Ricty font to rename",
    )
    parser.add_argument(
        "out_dpath",
        type=Path,
        help="The directory to output the renamed font file to",
    )
    parser.add_argument(
        "--add-nerd",
        action="store_true",
        help="add Nerd to font family name",
    )
    args = parser.parse_args()

    rename(args.font_fpath, args.out_dpath, args.add_nerd)

    return


if __name__ == "__main__":
    main()
