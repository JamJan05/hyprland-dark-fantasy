#!/usr/bin/env python3
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
#  NOISE TEXTURE - "ash, not smooth black".
#
#  Generates one small noise tile that the Quickshell shell and the SDDM
#  theme lay under their surfaces at 6-8 % opacity. Hyprland and hyprlock
#  have built-in grain (blur:noise, background:noise); QtQuick and the SDDM
#  greeter do not, so they get it from a file.
#
#  WHY A FILE AND NOT A SHADER OR CANVAS
#
#  ShaderEffect in Qt 6 requires a shader compiled with the qsb tool into
#  a .qsb file - yet another build artifact that would have to be kept
#  in the repo and refreshed. Canvas would compute the noise in JavaScript on every
#  shell start, separately for each panel. A 128 x 128 px tile weighs
#  a few dozen kilobytes, and Image with fillMode: Image.Tile repeats it
#  on the GPU for free.
#
#  WHY BLACK AND WHITE GRAINS WITH RANDOM ALPHA
#
#  Gray noise at full opacity would lighten the background: an average gray of 128
#  laid at 7 % turns #0b0b0c into a clearly lighter graphite, i.e.
#  changes the palette. Grains half black, half white cancel out on average,
#  so the surface color stays the one from the README, and only the texture changes.
#
#  Fixed seed: the same texture on every run, so
#  regenerating it produces no change in git.
#
#  Run from the repository root:
#      python3 tools/generuj-szum.py
#
#  Requires Pillow (dev-python/pillow).
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import random
from pathlib import Path

from PIL import Image

ROZMIAR = 128
SEED = 1719

# Two consumers of the same texture. The SDDM greeter runs as the user
# "sddm" and cannot see the home directory, so the theme needs its own copy.
CELE = [
    Path("config/quickshell/dark-fantasy/assets/szum.png"),
    Path("sddm/dark-fantasy/szum.png"),
]


def generuj() -> Image.Image:
    los = random.Random(SEED)
    obraz = Image.new("RGBA", (ROZMIAR, ROZMIAR))
    piksele = []
    for _ in range(ROZMIAR * ROZMIAR):
        jasnosc = 255 if los.random() < 0.5 else 0
        # Alpha from a triangular distribution - most grains are barely
        # visible, a few stronger. A uniform distribution gave
        # "TV snow" instead of ash.
        alfa = int(los.triangular(0, 255, 40))
        piksele.append((jasnosc, jasnosc, jasnosc, alfa))
    obraz.putdata(piksele)
    return obraz


def main() -> None:
    obraz = generuj()
    for cel in CELE:
        cel.parent.mkdir(parents=True, exist_ok=True)
        obraz.save(cel, optimize=True)
        print(f"saved {cel}")


if __name__ == "__main__":
    main()
