import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: root

    implicitWidth: timeText.implicitWidth + dateText.implicitWidth + (showDate ? spacing : 0)
    implicitHeight: WhiteSurTheme.barHeight

    property bool showDate: true
    property int spacing: 8

    Row {
        anchors.centerIn: parent
        spacing: root.spacing

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(new Date(), "h:mm AP")
            color: WhiteSurTheme.textPrimary
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        Text {
            id: dateText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(new Date(), "MMM d")
            color: WhiteSurTheme.textSecondary
            font.pixelSize: 13
            visible: showDate
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
