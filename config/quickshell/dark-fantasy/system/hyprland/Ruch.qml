// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  HYPRLAND -> MOTION - animations and their speed.
//
//  Speed is a single multiplier for all animations: Hyprland has none,
//  so hyprland.lua keeps the durations in a table, and ustawAnimacje(tempo)
//  re-declares them with the recomputed duration (see the animations section
//  in hyprland.lua). 1× is the config durations; 2× - twice as fast.
//
//  The shell animates its own panels itself (Theme.animPanelIn/Out) - the slider
//  does not change that.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Animations", "Animacje")
        typ: "przelacznik"
        wlaczony: UstawieniaHyprlanda.wartosci["animations:enabled"] ?? true
        onZmieniono: function (v) { UstawieniaHyprlanda.ustaw("animations:enabled", v); }
    }

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Animation speed", "Tempo animacji")
        typ: "suwak"; od: 0.5; doo: 2; krok: 0.1
        dostepny: UstawieniaHyprlanda.wartosci["animations:enabled"] ?? true
        wartosc: UstawieniaHyprlanda.stan.tempo
        formatuj: v => Tr.dziesietna(v, 1) + "×"
        onZmieniono: function (v) { UstawieniaHyprlanda.ustawTempo(v); }
    }
}
