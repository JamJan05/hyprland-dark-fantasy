// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  TIDINGS - notification history above the tile row.
//
//  The former notification center (bell on the bar, panel below the right
//  end of the bar) moved under the Tidings tile. The content - header with "Clear",
//  "do not disturb" and the card list - is the same component the center
//  used: notifications/HistoriaPowiadomien.qml.
//
//  Opening Tidings hides any popups currently showing: they sit on the
//  Overlay layer, so they would draw above the pause, and showing the same
//  notification twice at once makes no sense. The center did the same.
//
//  Keyboard from kafle/RzadKafli.qml: ↑ ↓ scroll the list, Delete clears
//  the whole history, Esc returns to the row. Cards, "Clear" and the
//  "do not disturb" toggle are handled by the mouse.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.notifications
import qs.services

Item {
    id: root

    property bool widoczny: false
    property bool aktywny: false

    readonly property int margines: Theme.spacingLg

    // SwayNC panel width (440) plus margin - the list needs more room
    // than sliders. Height grows with the content up to 540 px, beyond that
    // the list scrolls; any taller and the panel would run under the HUD and bar.
    implicitWidth: 460
    implicitHeight: Math.min(540, historia.implicitHeight + 2 * margines)

    opacity: widoczny ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.widoczny ? Theme.animPanelIn : Theme.animPanelOut
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeOutQuint
        }
    }

    onWidocznyChanged: {
        if (widoczny) {
            Notifications.hideAllPopups();
            lista.contentY = 0;
        }
    }

    function przewin(o: real): void {
        lista.contentY = Math.max(0, Math.min(lista.contentHeight - lista.height, lista.contentY + o));
    }

    function klawisz(zdarzenie: var): bool {
        switch (zdarzenie.key) {
        case Qt.Key_Up:       przewin(-60); return true;
        case Qt.Key_Down:     przewin(60); return true;
        case Qt.Key_PageUp:   przewin(-lista.height); return true;
        case Qt.Key_PageDown: przewin(lista.height); return true;
        case Qt.Key_Delete:
            Notifications.clearAll();
            return true;
        }
        return false;
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.background, Theme.panelOpacity)
        border.width: Theme.borderWidth
        border.color: Theme.border

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Szum {
            anchors.fill: parent
            anchors.margins: Theme.borderWidth
        }
    }

    Flickable {
        id: lista

        x: root.margines
        y: root.margines
        width: root.width - 2 * root.margines
        height: root.height - 2 * root.margines

        contentHeight: historia.implicitHeight
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 6000
        clip: true

        HistoriaPowiadomien {
            id: historia
            width: lista.width
            tytul: Tr.t("Tidings", "Wieści")
        }
    }
}
