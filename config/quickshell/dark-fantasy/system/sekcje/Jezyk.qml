// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  LANGUAGE - English or Polish.
//
//  Language names are always written in their own language, so the
//  option stays recognisable whichever one is active. The change is
//  immediate: every Tr.t() binding re-evaluates.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import qs
import qs.components
import qs.services
import qs.system

SekcjaOpcji {
    id: root

    readonly property var jezyki: [
        { kod: "en", nazwa: "English" },
        { kod: "pl", nazwa: "Polski" }
    ]

    WierszOpcji {
        width: root.width
        etykieta: Tr.t("Interface language", "Język interfejsu")
        typ: "wybor"
        opcje: root.jezyki
        indeks: Math.max(0, root.jezyki.findIndex(j => j.kod === Tr.kod))
        onZmieniono: function (i) { UstawieniaPowloki.ustawJezyk(root.jezyki[i].kod); }
    }

    Label {
        width: root.width
        topPadding: Theme.spacingMd
        leftPadding: Theme.spacingMd
        wrapMode: Text.Wrap
        elide: Text.ElideNone
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        text: Tr.t("Language / Język", "Język / Language")
    }
}
