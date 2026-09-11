pragma Singleton

// THE PRAGMA MUST COME BEFORE THE COMMENT, NOT AFTER IT - see Brightness.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  CPU - load and thread count for the stamina bar.
//
//  The source is /proc/stat, read every 2 s via FileView - no processes,
//  no "top" and no bash in a loop. Load is the share of NON-idle time
//  between two reads, computed from the first "cpu" row (the sum
//  of all cores):
//
//      cpu  user nice system idle iowait irq softirq steal ...
//
//  Idle = idle + iowait. Waiting for the disk is not CPU work -
//  without this, copying files would show the stamina as exhausted.
//
//  The thread count is the number of "cpuN" rows - it determines the LENGTH of the stamina
//  bar (Theme.hudPxPerThread), like a character's maximum endurance.
//
//  /proc has zero-size files, yet FileView still reads them
//  in full - checked before writing this service (25 rows).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Load 0.0 - 1.0.
    property real uzycie: 0

    property int watki: 0

    // Counters from the previous read. The first read only stores them -
    // load is a difference, and a single read has nothing to subtract from.
    property real poprzedniaSuma: -1
    property real poprzedniaBezczynnosc: 0

    function przelicz(tekst: string): void {
        const wiersze = tekst.split("\n");

        const pola = wiersze[0].trim().split(/\s+/).slice(1).map(Number);
        // user nice system idle iowait irq softirq steal - guest
        // is already included in user, so we do not add it a second time.
        const suma = pola.slice(0, 8).reduce((a, b) => a + (b || 0), 0);
        const bezczynnosc = pola[3] + (pola[4] || 0);

        let n = 0;
        for (const w of wiersze) {
            if (/^cpu\d+/.test(w)) n++;
        }
        watki = n;

        if (poprzedniaSuma >= 0) {
            const ds = suma - poprzedniaSuma;
            const di = bezczynnosc - poprzedniaBezczynnosc;
            if (ds > 0) uzycie = Math.max(0, Math.min(1, 1 - di / ds));
        }
        poprzedniaSuma = suma;
        poprzedniaBezczynnosc = bezczynnosc;
    }

    FileView {
        id: plik
        path: "/proc/stat"
        onLoaded: root.przelicz(text())
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: plik.reload()
    }
}
