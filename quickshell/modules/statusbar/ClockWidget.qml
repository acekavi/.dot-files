import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: root

    implicitWidth: timeText.implicitWidth + dateText.implicitWidth + (showDate ? spacing : 0)
    implicitHeight: WhiteSurTheme.barHeight

    property bool showDate: true
    property int spacing: WhiteSurTheme.spacing

    RowLayout {
        anchors.centerIn: parent
        spacing: root.spacing

        Text {
            id: timeText
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatTime(new Date(), "h:mm AP")
            color: WhiteSurTheme.textPrimary
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        Text {
            id: dateText
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatDate(new Date(), "MMM d")
            color: WhiteSurTheme.textSecondary
            font.pixelSize: 13
            visible: showDate
        }
    }

    // Hover effect for better interactivity
    Rectangle {
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius
        color: mouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) : "transparent"
        opacity: mouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            animation: WhiteSurTheme.colorAnimation.createObject(this)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Optional: Add click functionality for date format toggle
        onClicked: {
            // Could toggle between different date formats
            console.log("Clock widget clicked")
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Force time update
            timeText.text = Qt.formatTime(new Date(), "h:mm AP")
            dateText.text = Qt.formatDate(new Date(), "MMM d")
        }
    }
}
