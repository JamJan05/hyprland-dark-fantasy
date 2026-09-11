// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  MEDIA PANEL - the player, opened from the "now" frame on the bar
//  or with SUPER+O.
//
//  Same language as the rest of the interface: a sharp stone slab with
//  grain and a faded gold border, a small-caps header, the cover as an
//  "item" (desaturated, vignetted), progress as the 6 px HUD bar and
//  bare glyphs instead of pill buttons. It only fades - no sliding.
//
//  Keys: Left/Right - previous/next, Enter or Space - play/pause,
//  Esc - close. Clicking outside the slab closes it too.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services

PanelWindow {
    id: root

    property bool open: false
    signal closeRequested()

    WlrLayershell.namespace: "quickshell-media"
    WlrLayershell.layer: WlrLayer.Top

    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: true

    // Closed = empty input mask, so the window never eats clicks.
    mask: Region {
        x: 0
        y: Theme.panelMarginTop
        width: root.open ? root.width : 0
        height: root.open ? root.height - Theme.panelMarginTop : 0
    }

    readonly property var gracz: Player.active
    readonly property bool jest: gracz !== null

    readonly property int margines: Theme.spacingLg

    Item {
        anchors.fill: parent
        focus: root.open

        Keys.onPressed: function (zdarzenie) {
            switch (zdarzenie.key) {
            case Qt.Key_Escape:
                root.closeRequested();
                break;
            case Qt.Key_Left:
                if (root.jest && root.gracz.canGoPrevious) Player.previous();
                break;
            case Qt.Key_Right:
                if (root.jest && root.gracz.canGoNext) Player.next();
                break;
            case Qt.Key_Space:
            case Qt.Key_Return:
            case Qt.Key_Enter:
                if (root.jest && root.gracz.canTogglePlaying) Player.toggle();
                break;
            default:
                return;
            }
            zdarzenie.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.closeRequested()
    }

    // MPRIS does not announce position changes while playing - ask once
    // a second, and only while the panel is actually visible.
    Timer {
        interval: 1000
        repeat: true
        running: root.open && Player.playing && root.jest
        onTriggered: root.gracz.positionChanged()
    }

    function czas(sekundy: real): string {
        if (!isFinite(sekundy) || sekundy < 0) return "0:00";
        const calk = Math.floor(sekundy);
        const s = calk % 60;
        const m = Math.floor(calk / 60) % 60;
        const h = Math.floor(calk / 3600);
        const ss = s < 10 ? "0" + s : "" + s;
        if (h > 0) return h + ":" + (m < 10 ? "0" + m : "" + m) + ":" + ss;
        return m + ":" + ss;
    }

    // A bare glyph: iron when unavailable, muted at rest, gold under the
    // cursor. The middle one (play/pause) is larger and brighter.
    component Glif: Item {
        id: glif

        property string znak: ""
        property bool duzy: false
        property bool dostepny: true
        signal uzyty()

        implicitWidth: duzy ? 48 : 36
        implicitHeight: 44
        opacity: dostepny ? 1 : Theme.disabledOpacity

        Label {
            anchors.centerIn: parent
            text: glif.znak
            font.pixelSize: glif.duzy ? 30 : 20
            color: !glif.dostepny ? Theme.iron
                 : myszGlifu.containsMouse ? Theme.accent
                 : glif.duzy ? Theme.text : Theme.textMuted

            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }

        MouseArea {
            id: myszGlifu
            anchors.fill: parent
            hoverEnabled: true
            enabled: glif.dostepny
            cursorShape: Qt.PointingHandCursor
            onClicked: glif.uzyty()
        }
    }

    Item {
        id: plyta

        anchors.top: parent.top
        anchors.topMargin: Theme.panelMarginTop + Theme.spacingSm
        anchors.horizontalCenter: parent.horizontalCenter

        width: 460
        height: tresc.implicitHeight + 2 * root.margines

        opacity: root.open ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? Theme.animPanelIn : Theme.animPanelOut
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.easeOutQuint
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Theme.background, Theme.panelOpacity)
            border.width: Theme.borderWidth
            border.color: Theme.border

            // Clicks on the slab must not reach the "click outside" catcher.
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
            id: tresc

            x: root.margines
            y: root.margines
            width: plyta.width - 2 * root.margines
            spacing: Theme.spacingSm

            Item {
                width: parent.width
                height: naglowek.implicitHeight

                Tytul {
                    id: naglowek
                    anchors.left: parent.left
                    text: Tr.t("Now playing", "Teraz gra")
                }

                Text {
                    anchors.right: parent.right
                    anchors.baseline: naglowek.baseline
                    width: Math.min(implicitWidth, parent.width - naglowek.implicitWidth - Theme.spacingLg)
                    visible: root.jest
                    text: Player.name
                    elide: Text.ElideRight
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeNormal
                    font.capitalization: Font.SmallCaps
                    font.letterSpacing: Theme.displayLetterSpacing
                    color: Theme.iron
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                width: parent.width
                visible: !root.jest
                topPadding: Theme.spacingLg
                bottomPadding: Theme.spacingLg
                horizontalAlignment: Text.AlignHCenter
                text: Tr.t("Silence. Nothing is playing.", "Cisza. Nic nie gra.")
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fontSizeLarge + 2
                font.italic: true
                color: Theme.textMuted
            }

            // Cover on the left, the "item description" on the right.
            Item {
                width: parent.width
                height: visible ? Math.max(okladka.height, opisy.implicitHeight) + Theme.spacingSm : 0
                visible: root.jest

                AlbumArt {
                    id: okladka
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacingSm
                    width: 112
                    height: 112
                    source: root.jest ? root.gracz.trackArtUrl : ""
                }

                Column {
                    id: opisy
                    anchors.left: okladka.right
                    anchors.leftMargin: Theme.spacingLg
                    anchors.right: parent.right
                    anchors.top: okladka.top
                    spacing: Theme.spacingXs

                    Text {
                        width: parent.width
                        text: !root.jest ? ""
                            : root.gracz.trackTitle !== "" ? root.gracz.trackTitle
                            : Tr.t("Unknown track", "Nieznany utwór")
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fontSizeLarge + 5
                        font.capitalization: Font.SmallCaps
                        font.features: { "lnum": 1 }
                        font.letterSpacing: Theme.displayLetterSpacing
                        color: Player.playing ? Theme.text : Theme.textMuted

                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: root.jest ? root.gracz.trackArtist : ""
                        elide: Text.ElideRight
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fontSizeLarge
                        font.capitalization: Font.SmallCaps
                        font.letterSpacing: Theme.displayLetterSpacing
                        color: Theme.textMuted
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: root.jest ? root.gracz.trackAlbum : ""
                        elide: Text.ElideRight
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fontSizeNormal + 1
                        font.italic: true
                        color: Theme.iron
                    }
                }
            }

            Item {
                id: postep

                width: parent.width
                visible: root.jest && root.gracz.lengthSupported
                height: visible ? pasek.height + czasy.height + Theme.spacingSm + Theme.spacingXs : 0

                readonly property real dlugosc: root.jest ? root.gracz.length : 0
                readonly property real pozycja: root.jest ? root.gracz.position : 0
                readonly property bool przewijalny:
                    root.jest && root.gracz.canSeek && root.gracz.positionSupported

                StatBar {
                    id: pasek
                    y: Theme.spacingSm
                    width: parent.width
                    length: parent.width
                    fillColor: Theme.accent
                    value: postep.dlugosc > 0 ? postep.pozycja / postep.dlugosc : 0
                }

                MouseArea {
                    anchors.fill: pasek
                    anchors.topMargin: -8
                    anchors.bottomMargin: -8
                    enabled: postep.przewijalny
                    cursorShape: postep.przewijalny ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: function (zdarzenie) {
                        const udzial = Math.max(0, Math.min(1, zdarzenie.x / width));
                        Player.seekTo(udzial * postep.dlugosc);
                    }
                }

                Item {
                    id: czasy
                    anchors.top: pasek.bottom
                    anchors.topMargin: Theme.spacingXs
                    width: parent.width
                    height: uplynelo.implicitHeight

                    Label {
                        id: uplynelo
                        anchors.left: parent.left
                        text: root.czas(postep.pozycja)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textMuted
                    }

                    Label {
                        anchors.right: parent.right
                        text: root.czas(postep.dlugosc)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.iron
                    }
                }
            }

            Item {
                width: parent.width
                height: visible ? 48 : 0
                visible: root.jest

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacingLg

                    Glif {
                        anchors.verticalCenter: parent.verticalCenter
                        znak: Icons.mediaPrevious
                        dostepny: root.jest && root.gracz.canGoPrevious
                        onUzyty: Player.previous()
                    }

                    Glif {
                        anchors.verticalCenter: parent.verticalCenter
                        duzy: true
                        znak: Player.playing ? Icons.mediaPause : Icons.mediaPlay
                        dostepny: root.jest && root.gracz.canTogglePlaying
                        onUzyty: Player.toggle()
                    }

                    Glif {
                        anchors.verticalCenter: parent.verticalCenter
                        znak: Icons.mediaNext
                        dostepny: root.jest && root.gracz.canGoNext
                        onUzyty: Player.next()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                visible: root.jest
            }

            Label {
                width: parent.width
                visible: root.jest
                topPadding: Theme.spacingXs
                horizontalAlignment: Text.AlignRight
                text: Tr.t("← →  track      Enter  play / pause      Esc  close",
                           "← →  utwór      Enter  graj / pauza      Esc  zamknij")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.iron
            }
        }
    }
}
