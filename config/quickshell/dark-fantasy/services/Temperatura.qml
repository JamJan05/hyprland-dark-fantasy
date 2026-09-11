pragma Singleton

// THE PRAGMA MUST COME BEFORE THE COMMENT, NOT AFTER IT - see Brightness.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  CPU TEMPERATURE - for the status buildup in the HUD.
//
//  The sensor is searched ONCE, at shell startup, by hwmon name, not by
//  number - hwmonN numbers shuffle between reboots, depending
//  on the order in which kernel modules are loaded. Order of attempts:
//
//      k10temp      AMD Ryzen (Tctl) - this laptop
//      zenpower     AMD, alternative driver
//      coretemp     Intel (temp1 = whole package)
//      cpu_thermal  ARM, e.g. Raspberry Pi
//      acpitz       generic board sensor, when none of the above
//
//  Thanks to this the HUD works on another computer without adding anything.
//  The same rule as in local/bin/waybar-temperatura (there without Intel).
//
//  The /sys/class/hwmon directory cannot be listed from QML, so the search
//  is done by one short process; after that the read every 2 s goes through FileView,
//  without any processes.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // hwmon directory, e.g. "/sys/class/hwmon/hwmon5". Empty = no sensor.
    property string katalog: ""

    property real stopnie: 0

    readonly property bool dostepna: katalog !== "" && stopnie > 0

    // Threshold for the HUD status and for the "critical" class of the temperature module
    // on the bar (PROG_ALARMU in local/bin/waybar-temperatura).
    readonly property int progAlarmu: 70

    Process {
        running: true
        command: ["sh", "-c",
            "for n in k10temp zenpower coretemp cpu_thermal acpitz; do " +
            "for d in /sys/class/hwmon/hwmon*; do " +
            "test \"$(cat \"$d/name\" 2>/dev/null)\" = \"$n\" && test -r \"$d/temp1_input\" " +
            "&& { echo \"$d\"; exit 0; }; done; done"]
        stdout: StdioCollector { id: wynik }
        onExited: {
            const d = wynik.text.trim();
            if (d !== "") root.katalog = d;
        }
    }

    FileView {
        id: czujnik
        path: root.katalog === "" ? "" : root.katalog + "/temp1_input"
        onLoaded: {
            // The kernel reports millidegrees.
            const n = parseInt(text().trim(), 10);
            if (!isNaN(n)) root.stopnie = n / 1000;
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.katalog !== ""
        onTriggered: czujnik.reload()
    }
}
