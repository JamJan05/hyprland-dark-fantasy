pragma Singleton

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  TR - interface language.
//
//  English is the default; Polish is chosen in Cogwheel -> Language.
//  The choice lives in ~/.local/state/dark-fantasy/powloka.json
//  (UstawieniaPowloki.jezyk), so it survives a shell restart.
//
//  Usage in any binding:
//      text: Tr.t("Settings", "Ustawienia")
//      text: n + " " + Tr.forma(n, "device", "devices", "urządzenie", "urządzenia", "urządzeń")
//      text: Tr.dziesietna(1.5, 1) + " MiB/s"
//      text: data.toLocaleDateString(Tr.locale, "dddd, d MMMM")
//
//  Bindings re-evaluate on their own when the language changes: QML
//  records every property read while a binding runs, including the
//  reads inside these functions (checked with qml6).
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQml
import Quickshell

Singleton {
    id: root

    readonly property string kod: UstawieniaPowloki.jezyk === "pl" ? "pl" : "en"
    readonly property bool pl: kod === "pl"
    readonly property var locale: Qt.locale(pl ? "pl_PL" : "en_US")

    function t(angielski: string, polski: string): string {
        return root.pl ? polski : angielski;
    }

    // Word form for a count. Polish has three: 1 / 2-4 (except 12-14) / 5+.
    function forma(n: int, en1: string, enWiele: string,
                   pl1: string, pl24: string, pl5: string): string {
        if (!root.pl) return Math.abs(n) === 1 ? en1 : enWiele;
        const a = Math.abs(n), d = a % 10, s = a % 100;
        if (a === 1) return pl1;
        return d >= 2 && d <= 4 && (s < 12 || s > 14) ? pl24 : pl5;
    }

    // Decimal separator: dot in English, comma in Polish.
    function dziesietna(v: real, miejsca: int): string {
        const s = Number(v).toFixed(miejsca);
        return root.pl ? s.replace(".", ",") : s;
    }
}
