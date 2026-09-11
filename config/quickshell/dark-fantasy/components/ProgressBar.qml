// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  PROGRESS BAR - for display, not for dragging.
//
//  Trough and fill like the former panel slider (ValueSlider.qml),
//  just without a handle and without mouse handling. This way the OSD looks
//  like a slice of a panel rather than a separate widget:
//
//      trough     rgba(215, 208, 197, .12)   height 6, sharp corners
//      fill        old gold
//      muted       cold iron
//
//  The same color pair carries the same meaning here as everywhere
//  else in the theme: gold = active, iron = off.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs

Rectangle {
    id: root

    // 0.0 - 1.0
    property real value: 0
    property bool muted: false

    implicitHeight: 6
    radius: Theme.radiusSmall
    color: Theme.trough

    Rectangle {
        width: Math.max(0, Math.min(1, root.value)) * parent.width
        height: parent.height
        radius: parent.radius
        color: root.muted ? Theme.iron : Theme.accent

        // The fill glides to the new value instead of jumping.
        // With a volume key held down this gives one smooth motion
        // instead of a series of 5% jumps.
        Behavior on width {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
    }
}
