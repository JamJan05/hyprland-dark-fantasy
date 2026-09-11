// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  TEXT TOGGLE - "ON / OFF" instead of a switch knob.
//
//  Options in the Dark Souls menu have no phone-style switches. The state is
//  a word: the active word glows gold, the other fades to iron.
//  EB Garamond small caps, like every label in the menu.
//
//      ON   OFF         <- gold "ON", iron "OFF"
//
//  Clicking either word toggles. The keyboard (← →, Enter) is handled on
//  the option row's side (components/WierszOpcji.qml), because it has focus.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.services

Item {
    id: root

    property bool checked: false

    // Transitional state (e.g. the Bluetooth adapter is powering on) - dimmed
    // and unresponsive, instead of pretending nothing is happening.
    property bool busy: false

    signal toggled()

    implicitWidth: rzad.implicitWidth
    implicitHeight: 22

    opacity: enabled && !busy ? 1.0 : Theme.disabledOpacity
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

    component Slowo: Text {
        font.family: Theme.fontDisplay
        font.pixelSize: Theme.fontSizeNormal + 3
        font.capitalization: Font.SmallCaps
        font.letterSpacing: 1.5
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    Row {
        id: rzad
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingMd

        Slowo {
            text: Tr.t("On", "Wł.")
            color: root.checked ? Theme.accent : Theme.iron
        }

        Slowo {
            text: Tr.t("Off", "Wył.")
            color: root.checked ? Theme.iron : Theme.textMuted
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        enabled: !root.busy
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
