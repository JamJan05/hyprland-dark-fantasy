// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  NETWORK SECTION - Wi-Fi, network list, connecting.
//
//  The backend is NetworkManager via Quickshell.Networking; all the logic
//  and all communication with it live in services/Network.qml.
//
//  Scanning runs only while the panel is open - just like
//  Bluetooth device search. NetworkManager refreshes the list
//  periodically anyway, so there is no point forcing more frequent
//  polling when nobody is looking at it.
//
//  Only one password field can be expanded at a time. This section
//  holds that state, not the rows - otherwise two rows could be expanded
//  simultaneously and it would be unclear which network the password is for.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services

Column {
    id: root

    // The panel sets this for as long as it is visible.
    property bool panelOpen: false

    // Name of the network with the expanded password field. Empty = none.
    property string rozwinieta: ""

    spacing: Theme.spacingMd
    visible: Network.available

    onPanelOpenChanged: {
        Network.setScanning(panelOpen && Network.enabled);
        if (!panelOpen) rozwinieta = "";
    }

    // Turning Wi-Fi off meanwhile collapses the password field - there is
    // nothing left to connect to.
    Connections {
        target: Network
        function onEnabledChanged() {
            Network.setScanning(root.panelOpen && Network.enabled);
            if (!Network.enabled) root.rozwinieta = "";
        }
    }

    SectionLabel { rawText: Tr.t("Network", "Sieć") }

    // ---------------------------------------------------------------
    //  POWER TOGGLE AND STATE
    // ---------------------------------------------------------------
    Card {
        width: parent.width
        implicitHeight: glowny.implicitHeight + 2 * Theme.spacingMd

        Item {
            id: glowny
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
            implicitHeight: Math.max(ikona.implicitHeight, opisy.implicitHeight,
                                     przelacznik.implicitHeight)

            Label {
                id: ikona
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                font.pixelSize: Theme.fontSizeIcon
                text: {
                    if (!Network.enabled) return Icons.wifiOff;
                    if (!Network.connected) return Icons.wifiSteps[0];
                    return Icons.step(Icons.wifiSteps,
                                      Network.current.signalStrength);
                }
                color: Network.enabled && Network.connected
                    ? Theme.accent : Theme.iron

                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }

            Column {
                id: opisy
                anchors.left: ikona.right
                anchors.leftMargin: Theme.spacingSm
                anchors.right: przelacznik.left
                anchors.rightMargin: Theme.spacingSm
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Label {
                    width: parent.width
                    text: "Wi-Fi"
                    font.weight: Theme.fontWeightMedium
                }

                Label {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    color: Network.hardwareEnabled ? Theme.textMuted : Theme.ember
                    text: {
                        if (!Network.hardwareEnabled)
                            return Tr.t("Disabled by hardware (rfkill)", "Wyłączone sprzętowo (rfkill)");
                        if (!Network.enabled) return Tr.t("Off", "Wyłączone");
                        if (Network.current === null) return Tr.t("Not connected", "Niepołączone");
                        return Network.current.name + "  ·  "
                             + Math.round(Network.current.signalStrength * 100) + "%";
                    }
                }
            }

            Toggle {
                id: przelacznik
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: Network.enabled
                // With rfkill blocking, the software toggle would change
                // nothing anyway, so we don't pretend it can be clicked.
                enabled: Network.hardwareEnabled
                onToggled: Network.setEnabled(!Network.enabled)
            }
        }
    }

    // ---------------------------------------------------------------
    //  NETWORK LIST
    // ---------------------------------------------------------------
    Column {
        width: parent.width
        spacing: Theme.spacingSm
        visible: Network.enabled

        Repeater {
            model: Network.networks

            delegate: NetworkRow {
                required property var modelData

                width: parent.width
                network: modelData
                expanded: root.rozwinieta === modelData.name

                onExpandRequested: root.rozwinieta = modelData.name
                onCollapseRequested: root.rozwinieta = ""
            }
        }

        Label {
            width: parent.width
            visible: Network.networks.length === 0
            horizontalAlignment: Text.AlignHCenter
            padding: Theme.spacingMd
            font.pixelSize: Theme.fontSizeSmall
            font.italic: true
            color: Theme.iron
            text: Tr.t("Searching for networks…", "Szukam sieci…")
        }
    }
}
