pragma Singleton

// THE PRAGMA MUST COME BEFORE THE COMMENT, NOT AFTER IT - see Brightness.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  SHELL SETTINGS - what is toggled within the shell itself
//  and has to survive its restart.
//
//  Two things:
//    hudBars         - whether the HUD shows the stat bars (Theme.hudBars is
//                      the default value for a fresh install). Toggled by
//                      the Cogwheel or "qs ipc call hud przelaczPaski".
//    limitLadowania  - the last battery charge limit chosen in the Cogwheel,
//                      restored at startup (services/Ladowanie.qml).
//                      0 = never set, nothing is restored.
//
//  ---------------------------------------------------------------
//  WHY ~/.local/state AND NOT THE REPOSITORY
//
//  This is the state of this computer, not desktop configuration - just like
//  clipboard history. In the repo every click of a toggle would be a change
//  in git. Directory per XDG: $XDG_STATE_HOME or ~/.local/state.
//  The path is explicit rather than Quickshell.statePath(): that one depends on
//  the configuration identifier, i.e. on the path the shell started from,
//  so the test stand and the live shell would have two different files.
//
//  Writing via JsonAdapter: a property change in QML triggers
//  adapterUpdated, which writes the file (FileView creates missing
//  directories itself). A missing file on first run is not an error -
//  the default values remain.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell
import Quickshell.Io
import qs

Singleton {
    id: root

    readonly property bool hudBars: dane.hudBars

    function ustawPaski(wlaczone: bool): void {
        dane.hudBars = wlaczone;
    }

    function przelaczPaski(): void {
        dane.hudBars = !dane.hudBars;
    }

    readonly property int limitLadowania: dane.limitLadowania

    function ustawLimitLadowania(procent: int): void {
        dane.limitLadowania = procent;
    }

    // Interface language: "en" (default) or "pl". Read through Tr.
    readonly property string jezyk: dane.jezyk

    function ustawJezyk(kod: string): void {
        const nowy = kod === "pl" ? "pl" : "en";
        if (nowy === dane.jezyk) return;
        dane.jezyk = nowy;
        JezykZewnetrzny.zmieniono();
    }

    readonly property string sciezka: {
        const stan = Quickshell.env("XDG_STATE_HOME");
        const baza = stan ? stan : Quickshell.env("HOME") + "/.local/state";
        return baza + "/dark-fantasy/powloka.json";
    }

    FileView {
        path: root.sciezka
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        adapter: JsonAdapter {
            id: dane
            property bool hudBars: Theme.hudBars
            property int limitLadowania: 0
            property string jezyk: "en"
        }
    }
}
