// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  HYPRLAND -> FLOORS - number of floors and their names.
//
//  The file is not called Pietra.qml, because it would shadow the singleton
//  services/Pietra (which provides rzymska() below).
//
//  The number of floors only limits which floors can be entered - the
//  workspace grid stays 10 x 10, so lowering the number does not move
//  windows (description at "SETTINGS FROM COGWHEEL" in floors.lua).
//
//  The name replaces the number in the HUD emblem's tooltip ("Piętro 2 - Praca");
//  the emblem itself keeps the Roman numeral. Enter starts editing, Enter
//  confirms, Esc cancels.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    readonly property var stan: UstawieniaHyprlanda.stan

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Number of floors", "Liczba pięter")
        typ: "suwak"; od: 1; doo: 10; krok: 1
        wartosc: root.stan.pietra
        formatuj: v => String(Math.round(v))
        onZmieniono: function (v) { UstawieniaHyprlanda.ustawPietra(Math.round(v)); }
    }

    Repeater {
        model: root.stan.pietra

        delegate: WierszOpcji {
            required property int index

            width: root.width
            etykieta: Tr.t("Floor " + Pietra.rzymska(index + 1) + " name", "Nazwa piętra " + Pietra.rzymska(index + 1))
            typ: "tekst"
            tekst: root.stan.nazwy[index] ?? ""
            onZmieniono: function (s) { UstawieniaHyprlanda.ustawNazwePietra(index, s); }
        }
    }
}
