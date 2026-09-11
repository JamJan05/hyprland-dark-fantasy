// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  HYPRLAND -> INPUT - touchpad, keyboard layout, floor gestures.
//
//  Touchpad sensitivity is a device rule (hl.device with the touchpad name
//  from "hyprctl devices"), not input:sensitivity - that one would also
//  change the mouse and the TrackPoint. Without a touchpad the row is dimmed.
//
//  Floor gestures are disabled by floors.ustaw({ gesty = false }): the gesture stays
//  registered but does nothing - hl.gesture has no handle that
//  could remove it.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    readonly property var uklady: UstawieniaHyprlanda.ukladyKlawiatury

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Touchpad sensitivity", "Czułość touchpada")
        typ: "suwak"; od: -1; doo: 1; krok: 0.1
        dostepny: UstawieniaHyprlanda.nazwaTouchpada !== ""
        wartosc: UstawieniaHyprlanda.czuloscTouchpada
        formatuj: v => (v > 0 ? "+" : "") + Tr.dziesietna(v, 1)
        onZmieniono: function (v) { UstawieniaHyprlanda.ustawCzuloscTouchpada(v); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Natural scrolling", "Naturalne przewijanie")
        typ: "przelacznik"
        wlaczony: UstawieniaHyprlanda.wartosci["input:touchpad:natural_scroll"] ?? false
        onZmieniono: function (v) { UstawieniaHyprlanda.ustaw("input:touchpad:natural_scroll", v); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Keyboard layout", "Układ klawiatury")
        typ: "wybor"
        opcje: root.uklady.map(u => ({ kod: u.kod, nazwa: u.nazwa }))
        indeks: Math.max(0, root.uklady.findIndex(u => u.kod === UstawieniaHyprlanda.wartosci["input:kb_layout"]))
        onZmieniono: function (i) { UstawieniaHyprlanda.ustaw("input:kb_layout", root.uklady[i].kod); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Floor gestures (3 fingers)", "Gesty pięter (3 palce)")
        typ: "przelacznik"
        wlaczony: UstawieniaHyprlanda.stan.gesty
        onZmieniono: function (v) { UstawieniaHyprlanda.ustawGesty(v); }
    }
}
