pragma Singleton

// THE PRAGMA MUST COME BEFORE THE COMMENT, NOT AFTER IT - see Brightness.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  RAM - usage and size for the FP bar.
//
//  /proc/meminfo every 2 s via FileView. Used memory is
//  MemTotal - MemAvailable, not MemTotal - MemFree: the kernel counts
//  as "free" only completely unused memory, and hands the file cache
//  back to programs on demand. Usage computed from MemFree after an hour
//  of work always sat just under 90 %, even though nothing was short - Waybar's "memory"
//  module computes the same thing, so the numbers match.
//
//  The memory size determines the LENGTH of the FP bar (Theme.hudPxPerGiB).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real calkowitaKiB: 0
    property real dostepnaKiB: 0

    readonly property real uzycie:
        calkowitaKiB > 0 ? Math.max(0, Math.min(1, 1 - dostepnaKiB / calkowitaKiB)) : 0

    readonly property real calkowitaGiB: calkowitaKiB / 1048576
    readonly property real uzytaGiB: (calkowitaKiB - dostepnaKiB) / 1048576

    function przelicz(tekst: string): void {
        const razem = /^MemTotal:\s+(\d+)/m.exec(tekst);
        const dostepna = /^MemAvailable:\s+(\d+)/m.exec(tekst);
        if (razem) calkowitaKiB = Number(razem[1]);
        if (dostepna) dostepnaKiB = Number(dostepna[1]);
    }

    FileView {
        id: plik
        path: "/proc/meminfo"
        onLoaded: root.przelicz(text())
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: plik.reload()
    }
}
