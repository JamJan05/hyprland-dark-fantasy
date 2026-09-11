pragma ComponentBehavior: Bound

// Pragma on the first line, before the comment - reason in Icons.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  BONFIRE - the session menu above the tile row.
//
//      ┌────────────────────────────────┐
//      │ Rest by the fire               │
//      │ ─────────────────────────────  │
//      │ ▌Lock screen          SUPER+L  │
//      │  Suspend                       │
//      │  Log out                       │
//      │  Restart                       │
//      │  Shut down                     │
//      └────────────────────────────────┘
//
//  At a bonfire in the game you either rest or set out again - here you end
//  work or suspend it. Replaces the session menu from the power button on
//  the bar (the former config/waybar/menu-sesja.xml).
//
//  CONFIRMATION. Lock and suspend happen immediately - they destroy nothing,
//  you just come back. Log out, restart and shut down close all windows
//  with unsaved work, so the first Enter (or click) only asks: the entry
//  turns ember - ember means "warning" in this theme - and "Are you sure?"
//  appears below the list. A second Enter executes, Esc or moving to
//  another entry cancels.
//
//  The keyboard comes from kafle/RzadKafli.qml (klawisz() below), same as
//  in the Arsenal: ↑ ↓ select, Enter execute, Esc go back.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

    property bool widoczny: false
    property bool aktywny: false

    // The command went out - the tile row closes the pause.
    signal wykonano()

    readonly property var opcje: [
        { klucz: "blokada",  nazwa: Tr.t("Lock screen", "Zablokuj ekran"),   skrot: "SUPER+L", potwierdz: false },
        { klucz: "uspienie", nazwa: Tr.t("Suspend", "Uśpij"),                skrot: "",        potwierdz: false },
        { klucz: "wyloguj",  nazwa: Tr.t("Log out", "Wyloguj"),              skrot: "SUPER+M", potwierdz: true },
        { klucz: "restart",  nazwa: Tr.t("Restart", "Uruchom ponownie"),     skrot: "",        potwierdz: true },
        { klucz: "wylacz",   nazwa: Tr.t("Shut down", "Wyłącz komputer"),    skrot: "",        potwierdz: true }
    ]

    property int wybrany: 0

    // Index of the entry awaiting confirmation; -1 = none.
    property int potwierdzany: -1

    onWybranyChanged: potwierdzany = -1

    onWidocznyChanged: {
        if (widoczny) {
            wybrany = 0;
            potwierdzany = -1;
        }
    }

    readonly property int margines: Theme.spacingLg
    readonly property int wysokoscWiersza: 36

    implicitWidth: 440
    implicitHeight: margines + naglowek.implicitHeight + Theme.spacingSm + 1
        + Theme.spacingSm + opcje.length * wysokoscWiersza
        + Theme.spacingSm + pytanie.implicitHeight + margines

    opacity: widoczny ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.widoczny ? Theme.animPanelIn : Theme.animPanelOut
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.easeOutQuint
        }
    }

    function wykonaj(i: int): void {
        const o = opcje[i];
        if (o.potwierdz && potwierdzany !== i) {
            wybrany = i;
            potwierdzany = i;
            return;
        }

        // Close the pause first, then run the command: the dimming must not
        // stay above the lock screen or flash on suspend.
        root.wykonano();
        switch (o.klucz) {
        case "blokada":  Sesja.zablokuj(); break;
        case "uspienie": Sesja.uspij(); break;
        case "wyloguj":  Sesja.wyloguj(); break;
        case "restart":  Sesja.uruchomPonownie(); break;
        case "wylacz":   Sesja.wylacz(); break;
        }
    }

    function klawisz(zdarzenie: var): bool {
        switch (zdarzenie.key) {
        case Qt.Key_Up:
            wybrany = Math.max(0, wybrany - 1);
            return true;
        case Qt.Key_Down:
            wybrany = Math.min(opcje.length - 1, wybrany + 1);
            return true;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            wykonaj(wybrany);
            return true;
        case Qt.Key_Escape:
            if (potwierdzany === -1) return false;
            potwierdzany = -1;
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

    Column {
        x: root.margines
        y: root.margines
        width: root.width - 2 * root.margines
        spacing: Theme.spacingSm

        Tytul {
            id: naglowek
            width: parent.width
            text: Tr.t("Rest by the fire", "Odpocznij przy ognisku")
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        Column {
            width: parent.width

            Repeater {
                model: root.opcje

                delegate: Item {
                    id: wiersz

                    required property var modelData
                    required property int index

                    readonly property bool zaznaczony: root.wybrany === index
                    readonly property bool pyta: root.potwierdzany === index

                    width: parent.width
                    height: root.wysokoscWiersza

                    // Background of the selected entry - gold wash, ember while asking.
                    Rectangle {
                        anchors.fill: parent
                        color: wiersz.pyta ? Theme.emberWash : Theme.accentWash
                        opacity: wiersz.zaznaczony ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    // 2 px marker at the left edge of the selected entry.
                    Rectangle {
                        width: 2
                        height: parent.height
                        color: wiersz.pyta ? Theme.ember : Theme.accent
                        opacity: wiersz.zaznaczony ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        text: wiersz.modelData.nazwa
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fontSizeLarge + 3
                        font.capitalization: Font.SmallCaps
                        font.features: { "lnum": 1 }
                        font.letterSpacing: Theme.displayLetterSpacing
                        color: wiersz.pyta ? Theme.ember
                             : wiersz.zaznaczony ? Theme.text
                             : Theme.textMuted

                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    Label {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        visible: wiersz.modelData.skrot !== ""
                        text: wiersz.modelData.skrot
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.iron
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onContainsMouseChanged: if (containsMouse) root.wybrany = wiersz.index
                        onClicked: root.wykonaj(wiersz.index)
                    }
                }
            }
        }

        Label {
            id: pytanie
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            opacity: root.potwierdzany !== -1 ? 1 : 0
            color: Theme.ember
            font.pixelSize: Theme.fontSizeSmall
            text: Tr.t("Are you sure? Enter or click - yes,  Esc - no.",
                       "Na pewno? Enter albo kliknięcie - tak,  Esc - nie.")

            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        }
    }
}
