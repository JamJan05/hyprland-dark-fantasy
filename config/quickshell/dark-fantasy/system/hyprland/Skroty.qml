// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  HYPRLAND -> SHORTCUTS - view only.
//
//  The list comes from "hyprctl binds": these are the shortcuts Hyprland
//  REALLY has, including those from loops (desktops 1..0). Descriptions come
//  from hyprland.lua ("description" on each hl.bind). No editing -
//  shortcuts are changed in hyprland.lua.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    Repeater {
        model: UstawieniaHyprlanda.skroty

        delegate: WierszOpcji {
            required property var modelData

            width: root.width
            etykieta: modelData.opis
            typ: "info"
            tekst: modelData.klawisze
        }
    }
}
