// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
//  ALBUM ART - a square cover treated like the app icons in Arsenal:
//  desaturated, a touch of contrast, a dark vignette inside a 1 px
//  border. A colourful cover would otherwise be the loudest thing on
//  the desktop. No art = a dim glyph on stone.
// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

import QtQuick
import QtQuick.Effects
import Quickshell
import qs
import qs.components

Item {
    id: root

    property string source: ""

    readonly property bool loaded:
        source !== "" && obraz.status === Image.Ready

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
    }

    Label {
        anchors.centerIn: parent
        visible: !root.loaded
        text: Icons.application
        font.pixelSize: Math.round(root.height * 0.36)
        color: Theme.iron
    }

    Image {
        id: obraz
        anchors.fill: parent
        anchors.margins: Theme.borderWidth
        source: root.source
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: Math.round(root.width * Screen.devicePixelRatio)
        sourceSize.height: Math.round(root.height * Screen.devicePixelRatio)
        visible: false
    }

    MultiEffect {
        anchors.fill: obraz
        source: obraz
        visible: root.loaded
        saturation: -0.7
        contrast: 0.12
        brightness: -0.04
    }

    Image {
        anchors.fill: obraz
        visible: root.loaded
        source: "file://" + Quickshell.shellPath("assets/winieta.png")
        fillMode: Image.Stretch
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: Theme.borderWidth
        border.color: Theme.border
    }
}
