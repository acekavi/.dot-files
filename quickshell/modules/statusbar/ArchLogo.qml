import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    property string icon: "󰣇"  // Arch Linux icon
    property bool pressed: false

    signal clicked()

    Layout.preferredWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacing
    Layout.preferredHeight: WhiteSurTheme.iconSize + WhiteSurTheme.spacing
    radius: WhiteSurTheme.borderRadius
    color: pressed ? WhiteSurTheme.backgroundSecondary :
                     mouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) :
                                               "transparent"

    Behavior on color {
        animation: WhiteSurTheme.colorAnimation.createObject(this)
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: WhiteSurTheme.textPrimary
        font.pixelSize: WhiteSurTheme.iconSize
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            root.pressed = true
            parent.scale = 0.95
        }

        onReleased: {
            root.pressed = false
            parent.scale = 1.0
            if (containsMouse) {
                root.clicked()
            }
        }

        onCanceled: {
            root.pressed = false
            parent.scale = 1.0
        }
    }

    Behavior on scale {
        animation: WhiteSurTheme.quickAnimation.createObject(this)
    }
}
