pragma ComponentBehavior: Bound

// Pragma on the first line, before the comment - reason in Icons.qml.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  SOUND - volume, microphone and volume of playing apps.
//
//  The same as the AudioSection and AppVolumeSection cards in the former System
//  Control Center, only as "label ... value" rows - the slider can be
//  moved with arrows, not just the mouse. Same service
//  (services/Audio.qml), so the OSD and the bar see the same values.
//
//  Step 5 % - the same as the volume keys in hyprland.lua.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    readonly property var procent: v => Math.round(v * 100) + " %"

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Output", "Wyjście")
        typ: "info"
        tekst: Audio.sinkReady ? Audio.sinkName : Tr.t("none", "brak")
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Volume", "Głośność")
        typ: "suwak"; od: 0; doo: 1; krok: 0.05
        dostepny: Audio.sinkReady
        wartosc: Audio.volume
        formatuj: root.procent
        onZmieniono: function (v) { Audio.setVolume(v); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Mute", "Wyciszenie")
        typ: "przelacznik"
        dostepny: Audio.sinkReady
        wlaczony: Audio.muted
        onZmieniono: function (v) { if (v !== Audio.muted) Audio.toggleMute(); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Microphone", "Mikrofon")
        typ: "suwak"; od: 0; doo: 1; krok: 0.05
        dostepny: Audio.sourceReady
        wartosc: Audio.micVolume
        formatuj: root.procent
        onZmieniono: function (v) { Audio.setMicVolume(v); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Mute microphone", "Wyciszenie mikrofonu")
        typ: "przelacznik"
        dostepny: Audio.sourceReady
        wlaczony: Audio.micMuted
        onZmieniono: function (v) { if (v !== Audio.micMuted) Audio.toggleMicMute(); }
    }

    // Apps that are currently playing. The subheading is not an option row - navigation
    // skips it (SekcjaOpcji takes only rows).
    SectionLabel {
        rawText: Tr.t("Apps", "Programy")
        visible: Audio.anyStream
        topPadding: Theme.spacingMd
        leftPadding: Theme.spacingMd
    }

    Repeater {
        model: Audio.streams

        delegate: WierszOpcji {
            required property var modelData

            width: root.width
            etykieta: Audio.streamName(modelData)
            typ: "suwak"; od: 0; doo: 1; krok: 0.05
            wartosc: modelData.audio ? modelData.audio.volume : 0
            formatuj: root.procent
            onZmieniono: function (v) { Audio.setStreamVolume(modelData, v); }
        }
    }
}
