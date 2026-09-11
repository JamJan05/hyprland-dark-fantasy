#!/usr/bin/env python3
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
#  SLOT VIGNETTE - dark edges of the square under a program icon.
#
#  The program grid in the Arsenal tile (kafle/SlotAplikacji.qml) looks
#  like an inventory: each icon sits in a square slot. Colorful icons
#  from the theme (Papirus, breeze, apps' own icons) would scream against the
#  stone background, so they go through a filter: desaturation and slight contrast
#  are done by MultiEffect, and the dark vignette by this texture, laid over the icon.
#
#  WHY A FILE AND NOT A GRADIENT IN QML
#
#  QtQuick has no rectangle with a radial gradient without the Shapes module
#  and one shape per slot. A 96 x 96 px image loaded once and shared
#  by all slots (Image.cache) costs next to nothing, and GridView
#  only creates the slots visible on screen anyway.
#
#  The color is the theme background #0b0b0c. Opacity grows from zero in the center to 70 %
#  in the corners, with the squared distance - the center of the icon stays untouched,
#  only the edges are darkened, like on an old engraving.
#
#  Run from the repository root:
#      python3 tools/generuj-winiete.py
#
#  Requires Pillow (dev-python/pillow).
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

from pathlib import Path

from PIL import Image

BOK = 96
CEL = Path("config/quickshell/dark-fantasy/assets/winieta.png")
KRYCIE_W_ROGU = 0.70


def main() -> None:
    obraz = Image.new("RGBA", (BOK, BOK))
    piksele = []
    srodek = (BOK - 1) / 2
    for y in range(BOK):
        for x in range(BOK):
            # Distance on a scale of 0 (center) .. 1 (corner) - divided by 2,
            # because in the corner the sum of squares of both axes is 2.
            d = (((x - srodek) / srodek) ** 2 + ((y - srodek) / srodek) ** 2) / 2
            alfa = int(255 * KRYCIE_W_ROGU * min(1.0, d))
            piksele.append((11, 11, 12, alfa))
    obraz.putdata(piksele)
    CEL.parent.mkdir(parents=True, exist_ok=True)
    obraz.save(CEL, optimize=True)
    print(f"saved {CEL}")


if __name__ == "__main__":
    main()
