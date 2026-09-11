pragma Singleton

// THE PRAGMA MUST COME BEFORE THE COMMENT, NOT AFTER IT - see Brightness.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  FLOORS - the current floor and its desktops for the HUD.
//
//  NOTHING IS COMPUTED HERE. All floor logic lives in config/hypr/floors.lua:
//  after every desktop change it writes floors-stan.json in the Hyprland
//  instance directory, and this service only reads it. Thanks to this the HUD
//  cannot show a different floor than the one you are standing on, and there
//  is no second place where the floor -> workspace mapping
//  would need fixing.
//
//  The file is replaced via rename. FileView with watchChanges also watches
//  the directory, so it catches such a replacement without any signal - checked
//  in src/io/fileview.cpp of Quickshell 0.3.1.
//
//  Actions (click on a desktop, wheel on the emblem) go through floors.lua functions,
//  the same way they went from Waybar: Hyprland.dispatch() sends "dispatch X",
//  and with a Lua config that is shorthand for hl.dispatch(X).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property int pietro: 1

    // Current desktop 1..10; 0 = active workspace outside the floor grid.
    property int pulpit: 0

    // Existing desktops of the floor in the order 1..9, 0:
    //     [{ n: 1, aktywny: true, pilny: false }, ...]
    property var pulpity: []

    // Whether the state has arrived at all. Until floors.lua writes the first file
    // (session start), the HUD shows the emblem without the desktop row.
    property bool gotowe: false

    readonly property string sciezka: {
        const runtime = Quickshell.env("XDG_RUNTIME_DIR");
        const podpis = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        return runtime && podpis
            ? runtime + "/hypr/" + podpis + "/floors-stan.json"
            : "";
    }

    FileView {
        path: root.sciezka
        watchChanges: true

        // At the moment of the event FileView still has the old content - see
        // services/Brightness.qml.
        onFileChanged: reload()

        onLoaded: {
            let stan;
            try {
                stan = JSON.parse(text());
            } catch (e) {
                // rename replaces the file as a whole, so half a JSON
                // will not show up here - but an empty file left by a crash can.
                return;
            }
            root.pietro = stan.pietro;
            root.pulpit = stan.pulpit;
            root.pulpity = stan.pulpity;
            root.gotowe = true;
        }
    }

    // The emblem shows the floor as a Roman numeral. The tenth floor is "X" -
    // key 0 in the code, but the emblem has no zero, because the Romans did not
    // know it, and "F0" from Waybar would not fit the rest.
    readonly property list<string> rzymskie:
        ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    function rzymska(n: int): string {
        return n >= 1 && n <= rzymskie.length ? rzymskie[n - 1] : String(n);
    }

    function naPulpit(n: int): void {
        Hyprland.dispatch("floors.desktop(" + n + ")");
    }

    function krokPietra(kierunek: int): void {
        Hyprland.dispatch("floors.floor_step(" + kierunek + ")");
    }

    function krokPulpitu(kierunek: int): void {
        Hyprland.dispatch("floors.desktop_step(" + kierunek + ")");
    }
}
