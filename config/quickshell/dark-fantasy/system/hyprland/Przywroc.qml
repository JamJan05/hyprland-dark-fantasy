// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  HYPRLAND -> RESTORE DEFAULTS.
//
//  Removes ~/.config/hypr/ustawienia.lua and reloads Hyprland - everything
//  returns to the values from hyprland.lua. The wallpaper is not affected:
//  changing it rewrites hyprpaper.conf, not the settings file.
//
//  The first Enter asks, the second executes - just like the dangerous Bonfire entries.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    property bool pyta: false

    onVisibleChanged: pyta = false

    Label {
        width: root.width
        wrapMode: Text.Wrap
        elide: Text.ElideNone
        color: Theme.textMuted
        bottomPadding: Theme.spacingMd
        text: Tr.t("Gaps, border, blur, animations, touchpad, keyboard layout, "
                 + "monitor and floors will return to the values from hyprland.lua.",
                 "Odstępy, ramka, rozmycie, animacje, touchpad, układ klawiatury, "
                 + "ekran i piętra wrócą do wartości z hyprland.lua.")
    }

    WierszOpcji {
        width: root.width
        etykieta: root.pyta ? Tr.t("Are you sure? Enter - yes", "Na pewno? Enter - tak")
                             : Tr.t("All Hyprland settings", "Wszystkie ustawienia Hyprlanda")
        typ: "przycisk"
        tekst: root.pyta ? Tr.t("Restore", "Przywróć") : Tr.t("Restore defaults", "Przywróć domyślne")
        onUzyto: {
            if (!root.pyta) { root.pyta = true; return; }
            root.pyta = false;
            UstawieniaHyprlanda.przywrocDomyslne();
        }
    }
}
