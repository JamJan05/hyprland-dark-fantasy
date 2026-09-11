// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  STAT BAR - HP, FP, stamina in the top-left corner HUD.
//
//      ┌──────────────────────────────┐
//      │▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▒▒▒▒           │   6 px
//      └──────────────────────────────┘
//        fill         loss trail
//
//  Look faithful to the game, in the repository's palette:
//    - Theme.surface background and a 1 px Theme.border frame - like every frame in the theme;
//    - flat fill, WITHOUT a gradient, with a lighter 1 px line on the
//      top edge - the only "relief" 6 px of height allows;
//    - beneath the fill a lighter "loss trail": when the value drops,
//      the fill glides in 180 ms, and the trail catches up only after 700 ms.
//      The eye then sees not only how much there is, but also how much was just lost.
//      When the value rises, the trail has nothing to show and jumps
//      immediately - that is how healing works in the game too.
//
//  No digits. Numbers are shown by the tooltip (hud/Hud.qml) - the bar is meant to be
//  glanced at from the corner of the eye, not read.
//
//  "alarm" paints the outline in ember. In the HUD only the HP bar uses it,
//  while charging - in this theme ember means alarm or charging
//  and nothing else.
//
//  The same component, only lower (4 px), draws the build-up status
//  bars (hud/StatusNarastajacy.qml).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs

Item {
    id: root

    // Fill 0.0 - 1.0.
    property real value: 0

    // Full bar length in pixels - "max HP". Computed by the
    // caller from hardware stats (see Theme.hudPxPerWh and its neighbours).
    property real length: 200

    property color fillColor: Theme.hudHp

    // Ember outline - see the header.
    property bool alarm: false

    property int barHeight: Theme.hudBarHeight

    implicitWidth: length
    implicitHeight: barHeight

    readonly property real wartosc: Math.max(0, Math.min(1, value))

    // The fill follows the value in 180 ms. A curve without overshoot -
    // Theme.easeOutQuint does not go above 1.0.
    property real wypelnienie: wartosc
    Behavior on wypelnienie {
        NumberAnimation {
            duration: 180
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeOutQuint
        }
    }

    // Loss trail. Driven by hand, not by a Behavior: a Behavior
    // would also animate increases, while on an increase the trail must jump.
    property real slad: 0

    Component.onCompleted: slad = wartosc

    onWartoscChanged: {
        sladAnim.stop();
        if (wartosc >= slad) {
            slad = wartosc;
            return;
        }
        sladAnim.from = slad;
        sladAnim.to = wartosc;
        sladAnim.start();
    }

    NumberAnimation {
        id: sladAnim
        target: root
        property: "slad"
        duration: 700
        easing.type: Easing.InOutQuad
    }

    // Background and frame.
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        border.width: Theme.borderWidth
        border.color: root.alarm ? Theme.ember : Theme.border

        Behavior on border.color {
            ColorAnimation { duration: Theme.animNormal }
        }
    }

    // Inside the frame - the trail and the fill live here.
    Item {
        anchors.fill: parent
        anchors.margins: Theme.borderWidth

        Rectangle {
            height: parent.height
            width: parent.width * root.slad
            color: Qt.lighter(root.fillColor, 1.9)
            opacity: 0.45
        }

        Rectangle {
            height: parent.height
            width: parent.width * root.wypelnienie
            color: root.fillColor

            // Lighter top edge - light falling from above.
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.lighter(root.fillColor, 1.5)
            }
        }
    }
}
