// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  ICON-ONLY BUTTON.
//
//  Counterpart of "button.cisza" from panel-audio.css and the media
//  remote buttons from waybar/style.css. Traits shared by both:
//      no background at rest,
//      surface-alt background under the cursor,
//      corner 6-10 px,
//      icon larger than adjacent text (15-16 px with a 13 px base).
//
//  The "destructive" variant (close, power off) highlights in ember -
//  just like "#custom-sesja:hover" and ".close-button:hover".
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs

Item {
    id: root

    property string icon: ""
    property color accentColor: Theme.accent

    // true = this is a button that closes or turns something off.
    // The hover is then in the ember color.
    property bool destructive: false

    // "enabled" is NOT declared here. Item already has it from QQuickItem
    // and additionally propagates it down to children - so disabling this
    // button also disables its MouseArea. Declaring
    // our own "enabled" would shadow that one, and the state would have
    // to be distributed by hand to every descendant.
    property alias hovered: mouse.containsMouse

    signal clicked()

    implicitWidth: 28
    implicitHeight: 28
    opacity: enabled ? 1.0 : Theme.disabledOpacity

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: {
            if (!root.enabled) return "transparent";
            if (mouse.pressed) return Theme.pressWash;
            if (mouse.containsMouse)
                return root.destructive ? Theme.emberWash
                                        : Qt.alpha(Theme.surfaceAlt, 0.95);
            return "transparent";
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    Label {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: Theme.fontSizeIcon
        color: root.destructive && mouse.containsMouse
            ? Theme.ember
            : root.accentColor

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
