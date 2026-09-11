// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  TEXT.
//
//  Exists so that no other file has to repeat the font family
//  and the fallback list.
//
//  CSS lets you write font-family: "a", "b", "c" and the browser
//  takes the first one that exists. QML can NOT do that - the "font" type
//  exposes only a single font.family. So the fallback list is
//  resolved by Theme.qml, once at startup, via
//  Qt.fontFamilies(); a ready-made name arrives here.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs

Text {
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeNormal
    font.weight: Theme.fontWeightNormal
    color: Theme.text

    // Without this, long track titles and network names would stretch the panel
    // instead of being cut off - exactly the same problem that
    // Waybar solves with the "max-length" and "title-len" keys.
    elide: Text.ElideRight

    // Natively rendered text sticks more sharply to the pixel grid
    // at 13 px, and nearly the whole interface works at that size.
    renderType: Text.NativeRendering
}
