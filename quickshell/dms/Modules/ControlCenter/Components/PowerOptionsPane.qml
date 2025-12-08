import QtQuick
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool expanded: false
    property int selectedIndex: 0
    property var visibleActions: []

    property string holdAction: ""
    property int holdActionIndex: -1
    property real holdProgress: 0
    property bool showHoldHint: false

    readonly property bool needsConfirmation: SettingsData.powerActionConfirm
    readonly property int holdDurationMs: SettingsData.powerActionHoldDuration * 1000

    signal lockRequested
    signal closeRequested

    height: expanded ? contentColumn.height : 0
    visible: expanded
    clip: true

    function actionNeedsConfirm(action) {
        return action !== "lock" && action !== "restart";
    }

    function startHold(action, actionIndex) {
        if (!needsConfirmation || !actionNeedsConfirm(action)) {
            executeAction(action);
            return;
        }
        holdAction = action;
        holdActionIndex = actionIndex;
        holdProgress = 0;
        showHoldHint = false;
        holdTimer.start();
    }

    function cancelHold() {
        if (holdAction === "")
            return;
        const wasHolding = holdProgress > 0;
        holdTimer.stop();
        if (wasHolding && holdProgress < 1) {
            showHoldHint = true;
            hintTimer.restart();
        }
        holdAction = "";
        holdActionIndex = -1;
        holdProgress = 0;
    }

    function completeHold() {
        if (holdProgress < 1) {
            cancelHold();
            return;
        }
        const action = holdAction;
        holdTimer.stop();
        holdAction = "";
        holdActionIndex = -1;
        holdProgress = 0;
        executeAction(action);
    }

    function executeAction(action) {
        switch (action) {
        case "lock":
            closeRequested();
            lockRequested();
            break;
        case "logout":
            closeRequested();
            SessionService.logout();
            break;
        case "suspend":
            closeRequested();
            SessionService.suspend();
            break;
        case "hibernate":
            closeRequested();
            SessionService.hibernate();
            break;
        case "reboot":
            closeRequested();
            SessionService.reboot();
            break;
        case "poweroff":
            closeRequested();
            SessionService.poweroff();
            break;
        case "restart":
            closeRequested();
            Quickshell.execDetached(["dms", "restart"]);
            break;
        }
    }

    Timer {
        id: holdTimer
        interval: 16
        repeat: true
        onTriggered: {
            root.holdProgress = Math.min(1, root.holdProgress + (interval / root.holdDurationMs));
            if (root.holdProgress >= 1) {
                stop();
                root.completeHold();
            }
        }
    }

    Timer {
        id: hintTimer
        interval: 2000
        onTriggered: root.showHoldHint = false
    }

    function updateVisibleActions() {
        const allActions = SettingsData.powerMenuActions || ["reboot", "logout", "poweroff", "lock", "suspend", "restart"];
        visibleActions = allActions.filter(action => {
            if (action === "hibernate" && !SessionService.hibernateSupported)
                return false;
            return true;
        });
    }

    function getDefaultActionIndex() {
        const defaultAction = SettingsData.powerMenuDefaultAction || "logout";
        const index = visibleActions.indexOf(defaultAction);
        return index >= 0 ? index : 0;
    }

    function getActionAtIndex(index) {
        if (index < 0 || index >= visibleActions.length)
            return "";
        return visibleActions[index];
    }

    function getActionData(action) {
        switch (action) {
        case "reboot":
            return {
                "icon": "restart_alt",
                "label": I18n.tr("Reboot"),
                "key": "R"
            };
        case "logout":
            return {
                "icon": "logout",
                "label": I18n.tr("Log Out"),
                "key": "X"
            };
        case "poweroff":
            return {
                "icon": "power_settings_new",
                "label": I18n.tr("Power Off"),
                "key": "P"
            };
        case "lock":
            return {
                "icon": "lock",
                "label": I18n.tr("Lock"),
                "key": "L"
            };
        case "suspend":
            return {
                "icon": "bedtime",
                "label": I18n.tr("Suspend"),
                "key": "S"
            };
        case "hibernate":
            return {
                "icon": "ac_unit",
                "label": I18n.tr("Hibernate"),
                "key": "H"
            };
        case "restart":
            return {
                "icon": "refresh",
                "label": I18n.tr("Restart DMS"),
                "key": "D"
            };
        default:
            return {
                "icon": "help",
                "label": action,
                "key": "?"
            };
        }
    }

    function selectOption(action, actionIndex) {
        startHold(action, actionIndex !== undefined ? actionIndex : -1);
    }

    Component.onCompleted: {
        updateVisibleActions();
        selectedIndex = getDefaultActionIndex();
    }

    onExpandedChanged: {
        if (expanded) {
            updateVisibleActions();
            selectedIndex = getDefaultActionIndex();
        }
    }

    readonly property color primaryHover: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
    readonly property color primarySelected: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
    readonly property color primaryProgress: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
    readonly property color surfaceBg: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
    readonly property color borderColor: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    readonly property color errorProgress: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.3)
    readonly property color warningProgress: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.3)

    Column {
        id: contentColumn
        width: parent.width
        height: childrenRect.height
        spacing: Theme.spacingS

        Grid {
            id: buttonGrid
            width: parent.width
            columns: Math.min(root.visibleActions.length, 4)
            columnSpacing: Theme.spacingS
            rowSpacing: Theme.spacingS

            readonly property real buttonWidth: (width - Theme.spacingS * (columns - 1)) / columns

            Repeater {
                model: root.visibleActions

                Rectangle {
                    id: gridButtonRect
                    required property int index
                    required property string modelData

                    readonly property var actionData: root.getActionData(modelData)
                    readonly property bool isSelected: root.selectedIndex === index
                    readonly property bool showWarning: modelData === "reboot" || modelData === "poweroff"
                    readonly property bool isHolding: root.holdActionIndex === index && root.holdProgress > 0
                    readonly property bool showWarningColor: showWarning && (mouseArea.containsMouse || isHolding)
                    readonly property color warningColor: modelData === "poweroff" ? Theme.error : Theme.warning
                    readonly property color contentColor: showWarningColor ? warningColor : Theme.surfaceText

                    width: buttonGrid.buttonWidth
                    height: 80
                    radius: Theme.cornerRadius
                    color: isSelected ? root.primarySelected : (mouseArea.containsMouse ? root.primaryHover : root.surfaceBg)
                    border.color: isSelected ? Theme.primary : root.borderColor
                    border.width: isSelected ? 2 : 1
                    antialiasing: true
                    smooth: false

                    Rectangle {
                        id: gridProgressMask
                        anchors.fill: parent
                        radius: parent.radius
                        visible: false
                        layer.enabled: true
                    }

                    Item {
                        anchors.fill: parent
                        visible: gridButtonRect.isHolding
                        layer.enabled: gridButtonRect.isHolding
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: gridProgressMask
                            maskSpreadAtMin: 1
                            maskThresholdMin: 0.5
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * root.holdProgress
                            color: gridButtonRect.modelData === "poweroff" ? root.errorProgress : (gridButtonRect.modelData === "reboot" ? root.warningProgress : root.primaryProgress)
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: gridButtonRect.actionData.icon
                            size: Theme.iconSize + 4
                            color: gridButtonRect.contentColor
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: gridButtonRect.actionData.label
                            font.pixelSize: Theme.fontSizeSmall
                            color: gridButtonRect.contentColor
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            root.selectedIndex = index;
                            root.startHold(modelData, index);
                        }
                        onReleased: root.cancelHold()
                        onCanceled: root.cancelHold()
                    }
                }
            }
        }

        Row {
            id: hintRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingXS
            visible: root.needsConfirmation
            opacity: root.showHoldHint ? 1 : 0.5

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            DankIcon {
                name: root.showHoldHint ? "warning" : "touch_app"
                size: Theme.fontSizeSmall
                color: root.showHoldHint ? Theme.warning : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                readonly property real totalMs: SettingsData.powerActionHoldDuration * 1000
                readonly property int remainingMs: Math.ceil(totalMs * (1 - root.holdProgress))
                text: {
                    if (root.showHoldHint)
                        return I18n.tr("Hold longer to confirm");
                    if (root.holdProgress > 0) {
                        if (totalMs < 1000)
                            return I18n.tr("Hold to confirm (%1 ms)").arg(remainingMs);
                        return I18n.tr("Hold to confirm (%1s)").arg(Math.ceil(remainingMs / 1000));
                    }
                    if (totalMs < 1000)
                        return I18n.tr("Hold to confirm (%1 ms)").arg(totalMs);
                    return I18n.tr("Hold to confirm (%1s)").arg(SettingsData.powerActionHoldDuration);
                }
                font.pixelSize: Theme.fontSizeSmall
                color: root.showHoldHint ? Theme.warning : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
