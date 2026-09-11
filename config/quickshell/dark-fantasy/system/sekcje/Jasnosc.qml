// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  DISPLAY - backlight brightness.
//
//  The file is called Jasnosc, not Ekran: "Ekran" also exists in the Hyprland
//  section (scale, refresh rate) and two types with the same name would have
//  to be told apart on every import.
//
//  The slider's bottom is Brightness.minimum, not zero - a black screen with
//  the slider all the way left looks like a failure, not a setting.
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
        etykieta: Tr.t("Brightness", "Jasność")
        typ: Brightness.ready ? "suwak" : "info"
        tekst: Tr.t("no backlight to control", "brak podświetlenia do sterowania")
        od: Brightness.minimum; doo: 1; krok: 0.05
        wartosc: Brightness.value
        formatuj: v => Math.round(v * 100) + " %"
        onZmieniono: function (v) { Brightness.setValue(v); }
    }

    WierszOpcji {
        width: root.width
        visible: Brightness.ready
        etykieta: Tr.t("Device", "Urządzenie")
        typ: "info"
        tekst: Brightness.device
    }
}
