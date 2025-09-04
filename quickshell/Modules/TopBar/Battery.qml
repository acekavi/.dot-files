import QtQuick
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: battery

    property bool batteryPopupVisible: false
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property real widgetHeight: 30
    property real barHeight: 48
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal toggleBatteryPopup

    width: batteryContent.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground)
            return "transparent";
        const baseColor = batteryArea.containsMouse || batteryPopupVisible ? Theme.surfaceButtonHover : Theme.surfaceButton;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    visible: true

    Row {
        id: batteryContent
        anchors.centerIn: parent
        spacing: 3

        DankIcon {
            name: {
                if (!BatteryService.batteryAvailable)
                    return "power";

                if (BatteryService.isCharging) {
                    return "battery_android_bolt";
                }

                // Check if plugged in but not charging (like at 80% charge limit)
                if (BatteryService.isPluggedIn) {
                    return "battery_android_frame_shield";
                }

                // On battery power
                if (BatteryService.batteryLevel >= 95)
                    return "battery_android_full";
                if (BatteryService.batteryLevel >= 85)
                    return "battery_android_5";
                if (BatteryService.batteryLevel >= 70)
                    return "battery_android_4";
                if (BatteryService.batteryLevel >= 55)
                    return "battery_android_3";
                if (BatteryService.batteryLevel >= 40)
                    return "battery_android_2";
                if (BatteryService.batteryLevel >= 25)
                    return "battery_android_1";
                return "battery_android_0";
            }
            size: Theme.iconSize - 2
            color: {
                if (!BatteryService.batteryAvailable)
                    return Theme.surfaceText;

                if (BatteryService.isLowBattery && !BatteryService.isCharging)
                    return Theme.error;

                if (BatteryService.isCharging || BatteryService.isPluggedIn)
                    return Theme.primary;

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: BatteryService.batteryLevel + "%"
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            color: {
                if (!BatteryService.batteryAvailable)
                    return Theme.surfaceText;

                if (BatteryService.isLowBattery && !BatteryService.isCharging)
                    return Theme.error;

                if (BatteryService.isCharging)
                    return Theme.primary;

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
            visible: BatteryService.batteryAvailable
        }
    }

    MouseArea {
        id: batteryArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                var globalPos = mapToGlobal(0, 0);
                var currentScreen = parentScreen || Screen;
                var screenX = currentScreen.x || 0;
                var relativeX = globalPos.x - screenX;
                popupTarget.setTriggerPosition(relativeX, barHeight + Theme.spacingXS, width, section, currentScreen);
            }
            toggleBatteryPopup();
        }
    }

    Rectangle {
        id: batteryTooltip

        width: Math.max(120, tooltipText.contentWidth + Theme.spacingM * 2)
        height: tooltipText.contentHeight + Theme.spacingS * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.color: Theme.surfaceVariantAlpha
        border.width: 1
        visible: batteryArea.containsMouse && !batteryPopupVisible
        anchors.bottom: parent.top
        anchors.bottomMargin: Theme.spacingS
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: batteryArea.containsMouse ? 1 : 0

        Column {
            anchors.centerIn: parent
            spacing: 2

            StyledText {
                id: tooltipText

                text: {
                    if (!BatteryService.batteryAvailable) {
                        if (typeof PowerProfiles === "undefined")
                            return "Power Management";

                        switch (PowerProfiles.profile) {
                        case PowerProfile.PowerSaver:
                            return "Power Profile: Power Saver";
                        case PowerProfile.Performance:
                            return "Power Profile: Performance";
                        default:
                            return "Power Profile: Balanced";
                        }
                    }
                    let status = BatteryService.batteryStatus;
                    let level = BatteryService.batteryLevel + "%";
                    let time = BatteryService.formatTimeRemaining();
                    if (time !== "Unknown")
                        return status + " • " + level + " • " + time;
                    else
                        return status + " • " + level;
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }
}
