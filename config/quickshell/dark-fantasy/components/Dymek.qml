// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  TOOLTIP - a hint with numbers below a HUD element.
//
//  HUD bars have no digits (just like in the game), so the numbers - battery
//  level, used memory, load - are shown by a tooltip on hover.
//
//  A separate popup window (PopupWindow), not a rectangle in the HUD window.
//  The HUD window is 38 px tall, like the bar; a tooltip drawn inside it
//  would have to enlarge it, and an enlarged window would cover the windows
//  beneath (or require a mask, as in the former dock and today in the tile
//  row). A Wayland popup hangs above everything and disappears with the tooltip.
//
//  Position: 6 px below the element, from its left edge. Quickshell computes
//  the position relative to the element only when shown, so when the
//  target changes we call anchor.updateAnchor().
//
//  One tooltip per window. Elements call pokaz(item, tekst)
//  and schowaj(item) from their own HoverHandler.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import Quickshell
import qs

PopupWindow {
    id: root

    property Item cel: null
    property string tekst: ""

    // The tooltip appears after a moment, not immediately - sweeping the mouse across the HUD
    // must not light up a series of tooltips one after another.
    property Item oczekujacy: null
    property string oczekujacyTekst: ""

    function pokaz(element: Item, tresc: string): void {
        if (cel !== null) {
            // The tooltip is already shown - moving to a neighbouring element without delay.
            tekst = tresc;
            cel = element;
            anchor.updateAnchor();
            return;
        }
        oczekujacy = element;
        oczekujacyTekst = tresc;
        zwloka.restart();
    }

    function schowaj(element: Item): void {
        if (oczekujacy === element) {
            zwloka.stop();
            oczekujacy = null;
        }
        if (cel === element) cel = null;
    }

    Timer {
        id: zwloka
        interval: 350
        onTriggered: {
            root.tekst = root.oczekujacyTekst;
            root.cel = root.oczekujacy;
            root.oczekujacy = null;
        }
    }

    anchor.item: cel
    anchor.rect.x: 0
    anchor.rect.y: cel ? cel.height + 6 : 0

    visible: cel !== null && tekst !== ""
    color: "transparent"

    implicitWidth: podpis.implicitWidth + 2 * Theme.spacingSm + 2
    implicitHeight: podpis.implicitHeight + 2 * Theme.spacingXs + 2

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.surface, Theme.popupOpacity)
        border.width: Theme.borderWidth
        border.color: Theme.border

        Label {
            id: podpis
            anchors.centerIn: parent
            text: root.tekst
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.text
            elide: Text.ElideNone
            lineHeight: 1.15
        }
    }
}
