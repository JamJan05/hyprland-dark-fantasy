// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  BUILD-UP STATUS - an icon and a short bar, like bleed or poison.
//
//      󰓡 ▀▀▀▀▀▀▒▒
//
//  Appears only when something is happening, and fades out
//  after 5 seconds of quiet - instead of blinking at every momentary dip
//  below the threshold. There are two in the HUD:
//      network transfer above 100 KiB/s     (gold)
//      CPU temperature above 70 °C          (ember - this is already an alarm)
//
//  The bar is the same StatBar as HP, FP and stamina, only lower: 40 x 4 px.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components

Row {
    id: root

    // Whether the condition is met right now (e.g. transfer above the threshold).
    property bool aktywny: false

    property string ikona: ""
    property real wartosc: 0
    property color kolor: Theme.accent

    // Tooltip text.
    property string opis: ""
    property Dymek dymek: null

    spacing: 4
    height: 10

    property bool pokazany: false

    Component.onCompleted: pokazany = aktywny

    onAktywnyChanged: {
        if (aktywny) {
            pokazany = true;
            gaszenie.stop();
        } else {
            gaszenie.restart();
        }
    }

    // 5 s of quiet - see the header.
    Timer {
        id: gaszenie
        interval: 5000
        onTriggered: root.pokazany = false
    }

    opacity: pokazany ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animPanelIn
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeOutQuint
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.ikona
        font.family: Theme.fontMono
        font.pixelSize: 10
        color: root.kolor
    }

    StatBar {
        anchors.verticalCenter: parent.verticalCenter
        length: 40
        barHeight: 4
        value: root.wartosc
        fillColor: root.kolor
    }

    HoverHandler {
        onHoveredChanged: {
            if (!root.dymek) return;
            if (hovered) root.dymek.pokaz(root, root.opis);
            else root.dymek.schowaj(root);
        }
    }
}
