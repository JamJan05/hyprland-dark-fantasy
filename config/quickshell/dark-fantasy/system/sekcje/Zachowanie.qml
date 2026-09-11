// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  BEHAVIOR - idle inhibit and HUD bars.
//
//  HUD bars are here, not in the Hyprland section: it is a shell setting
//  (~/.local/state/dark-fantasy/powloka.json), Hyprland knows nothing about it.
//  With the bars off, CPU, memory and battery are shown by Waybar
//  as numbers (custom/zasoby).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Keep screen on", "Nie wygaszaj ekranu")
        typ: "przelacznik"
        wlaczony: Idle.inhibited
        onZmieniono: function (v) { if (v !== Idle.inhibited) Idle.toggle(); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("HUD bars", "Paski HUD-u")
        typ: "przelacznik"
        wlaczony: UstawieniaPowloki.hudBars
        onZmieniono: function (v) { UstawieniaPowloki.ustawPaski(v); }
    }

    Label {
        width: root.width
        topPadding: Theme.spacingMd
        leftPadding: Theme.spacingMd
        wrapMode: Text.Wrap
        elide: Text.ElideNone
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        text: Idle.inhibited
            ? Tr.t("The screen will not turn off and the computer will not sleep while this is on.",
                   "Ekran nie zgaśnie i komputer nie uśnie, dopóki blokada jest włączona.")
            : Tr.t("Screen off after 5 min, lock after 10, sleep after 30.",
                   "Ekran gaśnie po 5 min, blokada po 10, uśpienie po 30.")
    }
}
