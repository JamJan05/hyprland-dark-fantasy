// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  ROW WITH A TOGGLE.
//
//      [icon]   Title                    [====o]
//               subtitle with state
//
//  The same layout used by the Bluetooth and Wi-Fi headers:
//  an icon carrying state through color, a name, a subtitle saying in words
//  what is currently happening, and a toggle on the right.
//
//  The subtitle matters more here than it seems. An icon on the bar can
//  say "something is on", but it will not say WHAT WILL HAPPEN -
//  and that is exactly why these toggles ended up in the panel instead of
//  staying bare glyphs.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components

Card {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false

    // Transitional state - the toggle does not accept clicks then.
    property bool busy: false

    // Icon color in the on state. Gold by default, because that is how
    // "active" looks in this theme; an alarm toggle can
    // pass ember.
    property color activeColor: Theme.accent

    signal toggled()

    implicitHeight: tresc.implicitHeight + 2 * Theme.spacingMd

    Item {
        id: tresc
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        implicitHeight: Math.max(glif.implicitHeight, teksty.implicitHeight,
                                 przelacznik.implicitHeight)

        Label {
            id: glif
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            font.pixelSize: Theme.fontSizeIcon
            text: root.icon
            color: root.checked ? root.activeColor : Theme.iron

            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }

        Column {
            id: teksty
            anchors.left: glif.right
            anchors.leftMargin: Theme.spacingSm
            anchors.right: przelacznik.left
            anchors.rightMargin: Theme.spacingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Label {
                width: parent.width
                text: root.title
                font.weight: Theme.fontWeightMedium
            }

            Label {
                width: parent.width
                visible: root.subtitle !== ""
                text: root.subtitle
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textMuted
            }
        }

        Toggle {
            id: przelacznik
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: root.checked
            busy: root.busy
            onToggled: root.toggled()
        }
    }
}
