pragma ComponentBehavior: Bound

// Pragma on the first line, before the comment - reason in Icons.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  SETTINGS CENTER - contents of the Cogwheel tile, laid out like Dark Souls options.
//
//      Cogwheel         │  Appearance                        hyprland
//      ──────────       │  ───────────────────────────────────────────
//      SYSTEM           │ ▌Gap between windows    ▐████░░░░░░    5 px
//      ▌Sound           │  Blur                            On   Off
//       Display         │  Inactive opacity       ▐████████░░   92 %
//       ...             │
//      HYPRLAND         │
//       Appearance      │
//
//  Successor of System Control Center (the former SystemControlCenter.qml).
//  That one was a drawer under the cogwheel on the bar, mouse only. Here the
//  left column holds sections, the right one "label ... value" rows, and the
//  whole thing is navigable by keyboard alone (keys come from kafle/RzadKafli.qml):
//
//      section list   ↑ ↓ select, → / Enter into options, Esc - back to the tile row
//      options        ↑ ↓ row, ← → value, Enter; Esc - back to the
//                     list (← too, if the row has no value to change)
//
//  Network and Bluetooth are the same sections as in the quick panel under the
//  bar (QuickPanel.qml). Device lists with passwords and pairing do not fit
//  "label ... value", so they stayed mouse-driven cards; the keyboard only
//  scrolls them.
//
//  A section is created only when selected (Loader): Shortcuts is dozens of
//  rows, and the network section scans while its list is shown.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system
import qs.system.sekcje as Pulpit
import qs.system.hyprland as Hypr

Item {
    id: root

    property bool widoczny: false
    property bool aktywny: false

    // Clicking or hovering an option - the tile row then hands the
    // keyboard to the Cogwheel (level 1), even if the cursor was on the row.
    signal dotknieto()

    readonly property var sekcje: [
        { klucz: "dzwiek",     nazwa: Tr.t("Sound", "Dźwięk"),          grupa: "System" },
        { klucz: "jasnosc",    nazwa: Tr.t("Display", "Ekran"),         grupa: "System" },
        { klucz: "zasilanie",  nazwa: Tr.t("Power", "Zasilanie"),       grupa: "System" },
        { klucz: "zachowanie", nazwa: Tr.t("Behavior", "Zachowanie"),   grupa: "System" },
        { klucz: "siec",       nazwa: Tr.t("Network", "Sieć"),          grupa: "System" },
        { klucz: "bluetooth",  nazwa: "Bluetooth",                      grupa: "System" },
        { klucz: "jezyk",      nazwa: Tr.t("Language", "Język"),        grupa: "System" },
        { klucz: "wyglad",     nazwa: Tr.t("Appearance", "Wygląd"),     grupa: "Hyprland" },
        { klucz: "ruch",       nazwa: Tr.t("Motion", "Ruch"),           grupa: "Hyprland" },
        { klucz: "tapeta",     nazwa: Tr.t("Wallpaper", "Tapeta"),      grupa: "Hyprland" },
        { klucz: "wejscie",    nazwa: Tr.t("Input", "Wejście"),         grupa: "Hyprland" },
        { klucz: "monitor",    nazwa: Tr.t("Monitor", "Ekran"),         grupa: "Hyprland" },
        { klucz: "pietra",     nazwa: Tr.t("Floors", "Piętra"),         grupa: "Hyprland" },
        { klucz: "skroty",     nazwa: Tr.t("Shortcuts", "Skróty"),      grupa: "Hyprland" },
        { klucz: "przywroc",   nazwa: Tr.t("Restore defaults", "Przywróć domyślne"), grupa: "Hyprland" }
    ]

    property int wybrana: 0
    readonly property var sekcja: sekcje[wybrana]

    // 0 = section list, 1 = options of the selected section.
    property int kolumna: 0

    onWybranaChanged: przewijanie.contentY = 0
    onAktywnyChanged: if (!aktywny) kolumna = 0

    // Hyprland values are read on every open: they may have changed
    // through a config reload or a manual "hyprctl eval".
    onWidocznyChanged: {
        if (!widoczny) return;
        kolumna = 0;
        UstawieniaHyprlanda.odswiez();
    }

    readonly property bool sekcjaOpcji: loader.item !== null && loader.item.klawisz !== undefined

    // ---------------------------------------------------------------
    //  KEYBOARD
    // ---------------------------------------------------------------
    function klawisz(zdarzenie: var): bool {
        if (kolumna === 0) {
            switch (zdarzenie.key) {
            case Qt.Key_Up:
                wybrana = Math.max(0, wybrana - 1);
                return true;
            case Qt.Key_Down:
                wybrana = Math.min(sekcje.length - 1, wybrana + 1);
                return true;
            case Qt.Key_Right:
            case Qt.Key_Return:
            case Qt.Key_Enter:
                kolumna = 1;
                return true;
            }
            return false;
        }

        if (sekcjaOpcji) {
            if (loader.item.klawisz(zdarzenie)) return true;
        } else if (zdarzenie.key === Qt.Key_Up || zdarzenie.key === Qt.Key_Down) {
            przewin(zdarzenie.key === Qt.Key_Up ? -80 : 80);
            return true;
        }

        if (zdarzenie.key === Qt.Key_Escape || zdarzenie.key === Qt.Key_Left) {
            kolumna = 0;
            return true;
        }
        return false;
    }

    function przewin(o: real): void {
        const maks = Math.max(0, przewijanie.contentHeight - przewijanie.height);
        przewijanie.contentY = Math.max(0, Math.min(maks, przewijanie.contentY + o));
    }

    // The row selected with arrows is always kept in view - Shortcuts and
    // floor names are longer than the column.
    function pokaz(w: var): void {
        if (!w) return;
        const zapas = 8;
        const maks = Math.max(0, przewijanie.contentHeight - przewijanie.height);
        if (w.y - zapas < przewijanie.contentY)
            przewijanie.contentY = Math.max(0, w.y - zapas);
        else if (w.y + w.height + zapas > przewijanie.contentY + przewijanie.height)
            przewijanie.contentY = Math.min(maks, w.y + w.height + zapas - przewijanie.height);
    }

    function komponent(klucz: string): var {
        switch (klucz) {
        case "dzwiek":     return kDzwiek;
        case "jasnosc":    return kJasnosc;
        case "zasilanie":  return kZasilanie;
        case "zachowanie": return kZachowanie;
        case "siec":       return kSiec;
        case "bluetooth":  return kBluetooth;
        case "jezyk":      return kJezyk;
        case "wyglad":     return kWyglad;
        case "ruch":       return kRuch;
        case "tapeta":     return kTapeta;
        case "wejscie":    return kWejscie;
        case "monitor":    return kMonitor;
        case "pietra":     return kPietra;
        case "skroty":     return kSkroty;
        case "przywroc":   return kPrzywroc;
        }
        return null;
    }

    Component { id: kDzwiek;     Pulpit.Dzwiek {} }
    Component { id: kJasnosc;    Pulpit.Jasnosc {} }
    Component { id: kZasilanie;  Pulpit.Zasilanie {} }
    Component { id: kZachowanie; Pulpit.Zachowanie {} }
    Component { id: kSiec;       NetworkSection { panelOpen: root.widoczny } }
    Component { id: kBluetooth;  BluetoothSection { panelOpen: root.widoczny } }
    Component { id: kJezyk;      Pulpit.Jezyk {} }
    Component { id: kWyglad;     Hypr.Wyglad {} }
    Component { id: kRuch;       Hypr.Ruch {} }
    Component { id: kTapeta;     Hypr.Tapeta {} }
    Component { id: kWejscie;    Hypr.Wejscie {} }
    Component { id: kMonitor;    Hypr.Ekran {} }
    Component { id: kPietra;     Hypr.ListaPieter {} }
    Component { id: kSkroty;     Hypr.Skroty {} }
    Component { id: kPrzywroc;   Hypr.Przywroc {} }

    // ---------------------------------------------------------------
    //  LEFT COLUMN - SECTIONS
    // ---------------------------------------------------------------
    Column {
        id: lewa
        width: 210
        height: parent.height
        spacing: Theme.spacingSm

        Tytul {
            width: parent.width
            text: Tr.t("Cogwheel", "Zębatka")
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        Column {
            width: parent.width

            Repeater {
                model: root.sekcje

                delegate: Column {
                    id: pozycja

                    required property var modelData
                    required property int index

                    readonly property bool zaznaczona: root.wybrana === index
                    readonly property bool nowaGrupa:
                        index === 0 || root.sekcje[index - 1].grupa !== modelData.grupa

                    width: parent.width

                    SectionLabel {
                        visible: pozycja.nowaGrupa
                        rawText: pozycja.modelData.grupa
                        leftPadding: Theme.spacingMd
                        topPadding: pozycja.index === 0 ? 2 : Theme.spacingLg
                        bottomPadding: 4
                    }

                    Item {
                        width: parent.width
                        height: 28

                        // With the cursor in the options the selected section dims -
                        // it still shows whose options are on the right.
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.accentWash
                            opacity: pozycja.zaznaczona ? (root.kolumna === 0 ? 1 : 0.45) : 0
                            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                        }

                        Rectangle {
                            width: 2
                            height: parent.height
                            color: root.kolumna === 0 ? Theme.accent : Theme.iron
                            opacity: pozycja.zaznaczona ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingMd
                            anchors.verticalCenter: parent.verticalCenter
                            text: pozycja.modelData.nazwa
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fontSizeLarge + 2
                            font.capitalization: Font.SmallCaps
                            font.features: { "lnum": 1 }
                            font.letterSpacing: 1.25
                            color: pozycja.zaznaczona ? Theme.text : Theme.textMuted
                            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.wybrana = pozycja.index;
                                root.kolumna = 0;
                                root.dotknieto();
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: przegroda
        x: lewa.width + Theme.spacingLg
        width: 1
        height: parent.height
        color: Theme.border
    }

    // ---------------------------------------------------------------
    //  RIGHT COLUMN - OPTIONS OF THE SELECTED SECTION
    // ---------------------------------------------------------------
    Item {
        id: prawa
        x: przegroda.x + 1 + Theme.spacingLg
        width: parent.width - x
        height: parent.height

        Tytul {
            id: tytulSekcji
            width: parent.width
            text: root.sekcja.nazwa
        }

        Label {
            anchors.right: parent.right
            anchors.baseline: tytulSekcji.baseline
            text: root.sekcja.grupa === "Hyprland" ? "hyprland" : ""
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.iron
        }

        Rectangle {
            id: kreskaSekcji
            y: tytulSekcji.height + Theme.spacingSm
            width: parent.width
            height: 1
            color: Theme.border
        }

        Flickable {
            id: przewijanie

            y: kreskaSekcji.y + 1 + Theme.spacingSm
            width: parent.width
            height: podpowiedz.y - Theme.spacingSm - y

            contentHeight: loader.height
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 6000
            clip: true

            Loader {
                id: loader
                // Width only: height comes from the content.
                width: przewijanie.width - 8
                sourceComponent: root.komponent(root.sekcja.klucz)

                onLoaded: {
                    if (item.aktywna !== undefined)
                        item.aktywna = Qt.binding(() => root.kolumna === 1);
                }
            }

            Connections {
                target: loader.item
                ignoreUnknownSignals: true

                function onDotknieto() {
                    root.kolumna = 1;
                    root.dotknieto();
                }

                function onZaznaczonyWierszChanged() {
                    if (root.kolumna === 1) root.pokaz(loader.item.zaznaczonyWiersz);
                }
            }
        }

        // Scroll position - a thin line at the right edge, only
        // when the content is longer than the column.
        Rectangle {
            visible: przewijanie.contentHeight > przewijanie.height
            x: parent.width - 2
            y: przewijanie.y + przewijanie.visibleArea.yPosition * przewijanie.height
            width: 2
            height: Math.max(20, przewijanie.visibleArea.heightRatio * przewijanie.height)
            color: Theme.accent
            opacity: 0.5
        }

        Label {
            id: podpowiedz
            anchors.bottom: parent.bottom
            width: parent.width
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.iron
            text: root.kolumna === 0
                ? Tr.t("↑ ↓ section     → options     Esc exit",
                       "↑ ↓ sekcja     → opcje     Esc wyjście")
                : root.sekcjaOpcji
                    ? Tr.t("↑ ↓ option     ← → change     Enter     Esc back",
                           "↑ ↓ opcja     ← → zmiana     Enter     Esc powrót")
                    : Tr.t("↑ ↓ scroll     Esc back",
                           "↑ ↓ przewijanie     Esc powrót")
        }
    }
}
