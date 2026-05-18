pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../common"

Item {
    id: powerRoot

    property string pendingAction: ""

    width: powerButton.width
    height: powerButton.height

    function armAction(action) {
        pendingAction = pendingAction === action ? "" : action;

        if (pendingAction.length > 0)
            confirmResetTimer.restart();
        else
            confirmResetTimer.stop();
    }

    function runAction(action) {
        pendingAction = "";
        confirmResetTimer.stop();
        powerPopup.visible = false;

        if (action === "shutdown")
            shutdownProcess.startDetached();
        else if (action === "reboot")
            rebootProcess.startDetached();
        else if (action === "lock")
            lockProcess.startDetached();
        else if (action === "logout")
            logoutProcess.startDetached();
        else if (action === "sleep")
            sleepProcess.startDetached();
    }

    function togglePopup() {
        powerPopup.visible = !powerPopup.visible;

        if (powerPopup.visible)
            powerPopup.anchor.updateAnchor();
    }

    Timer {
        id: confirmResetTimer

        interval: 3500
        repeat: false

        onTriggered: powerRoot.pendingAction = ""
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: sleepProcess
        command: ["systemctl", "suspend"]
    }

    ModuleBox {
        id: powerButton

        width: Style.powerButtonWidth
        height: Style.moduleHeight
        paddingX: 0

        Item {
            width: powerButton.width
            height: powerButton.height

            BarText {
                width: implicitWidth
                height: parent.height
                anchors.centerIn: parent

                icon: true
                hovered: powerButton.hovered
                textPixelSize: Style.powerIconSize

                text: Style.powerIcon
            }
        }
    }

    MouseArea {
        anchors.fill: powerButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: powerRoot.togglePopup()
    }

    PopupWindow {
        id: powerPopup

        anchor {
            item: powerRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.powerPopupMaxWidth, Math.max(Style.powerPopupMinWidth, powerPopupBackground.implicitWidth))
        height: powerPopupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (!visible) {
                powerRoot.pendingAction = "";
                confirmResetTimer.stop();
            }
        }

        Rectangle {
            id: powerPopupBackground

            anchors.fill: parent

            implicitWidth: powerPopupColumn.implicitWidth + Style.powerPopupPadding * 2
            implicitHeight: powerPopupColumn.implicitHeight + Style.powerPopupPadding * 2

            radius: Style.moduleRadius
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: powerPopupColumn

                x: Style.powerPopupPadding
                y: Style.powerPopupPadding

                width: powerPopup.width - Style.powerPopupPadding * 2
                spacing: Style.powerPopupSectionGap

                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        width: parent.width

                        text: "Power"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: "Session and system controls"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupTitleFontSize
                        font.weight: 800
                    }

                    Text {
                        width: parent.width

                        text: powerRoot.pendingAction.length > 0 ? "Press confirm to continue." : "Select an action, then confirm it."
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Style.moduleBorder
                    opacity: 0.9
                }

                Column {
                    x: -6
                    width: parent.width + 6
                    spacing: 6

                    PowerActionRow {
                        actionKey: "shutdown"
                        iconText: Style.powerShutdownIcon
                        titleText: "Shut down"
                        detailText: "Power off the machine"
                        armed: powerRoot.pendingAction === actionKey

                        onArmRequested: powerRoot.armAction(actionKey)
                        onConfirmRequested: powerRoot.runAction(actionKey)
                    }

                    PowerActionRow {
                        actionKey: "reboot"
                        iconText: Style.powerRebootIcon
                        titleText: "Reboot"
                        detailText: "Restart the machine"
                        armed: powerRoot.pendingAction === actionKey

                        onArmRequested: powerRoot.armAction(actionKey)
                        onConfirmRequested: powerRoot.runAction(actionKey)
                    }

                    PowerActionRow {
                        actionKey: "lock"
                        iconText: Style.powerLockIcon
                        titleText: "Lock"
                        detailText: "Lock the current session"
                        armed: powerRoot.pendingAction === actionKey

                        onArmRequested: powerRoot.armAction(actionKey)
                        onConfirmRequested: powerRoot.runAction(actionKey)
                    }

                    PowerActionRow {
                        actionKey: "logout"
                        iconText: Style.powerLogoutIcon
                        titleText: "Log out"
                        detailText: "Exit the Hyprland session"
                        armed: powerRoot.pendingAction === actionKey

                        onArmRequested: powerRoot.armAction(actionKey)
                        onConfirmRequested: powerRoot.runAction(actionKey)
                    }

                    PowerActionRow {
                        actionKey: "sleep"
                        iconText: Style.powerSleepIcon
                        titleText: "Sleep"
                        detailText: "Suspend the machine"
                        armed: powerRoot.pendingAction === actionKey

                        onArmRequested: powerRoot.armAction(actionKey)
                        onConfirmRequested: powerRoot.runAction(actionKey)
                    }
                }
            }
        }
    }

    component PowerActionRow: Item {
        id: actionRow

        required property string actionKey
        required property string iconText
        required property string titleText
        required property string detailText
        property bool armed: false

        signal armRequested
        signal confirmRequested

        width: parent ? parent.width : Style.powerPopupMinWidth - Style.powerPopupPadding * 2
        height: Style.powerRowHeight
        scale: rowMouseArea.containsMouse ? 1.01 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 14
            color: actionRow.armed ? Style.playerControlHoverBackground : rowMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"
            border.color: actionRow.armed ? "#35ffffff" : "transparent"
            border.width: actionRow.armed ? 1 : 0

            Behavior on color {
                ColorAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: rowMouseArea

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor

            onClicked: actionRow.armRequested()
        }

        Row {
            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 10
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: 18

                text: actionRow.iconText
                color: actionRow.armed ? Style.workspaceFocusedForeground : rowMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.powerIconSize
                font.weight: Style.fontWeight

                horizontalAlignment: Text.AlignHCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 18 - parent.spacing * 2 - confirmButton.width
                spacing: 1

                Text {
                    width: parent.width

                    text: actionRow.titleText
                    color: actionRow.armed ? Style.workspaceFocusedForeground : Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: 700

                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: actionRow.armed ? "Click confirm to continue" : actionRow.detailText
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    elide: Text.ElideRight
                }
            }

            Item {
                id: confirmButton

                anchors.verticalCenter: parent.verticalCenter

                width: actionRow.armed ? Style.powerConfirmWidth : 0
                height: parent.height - 8
                clip: true
                opacity: actionRow.armed ? 1 : 0

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent

                    radius: height / 2
                    color: confirmMouseArea.containsMouse ? Style.workspaceFocusedBackground : Style.playerPanelBackground
                    border.color: "#35ffffff"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: Style.powerConfirmIcon
                        color: confirmMouseArea.containsMouse ? Style.foregroundHover : Style.workspaceFocusedForeground

                        font.family: Style.iconFontFamily
                        font.pixelSize: Style.popupSmallFontSize + 1
                        font.weight: Style.fontWeight
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: "Confirm"
                        color: confirmMouseArea.containsMouse ? Style.foregroundHover : Style.workspaceFocusedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: 800
                    }
                }

                MouseArea {
                    id: confirmMouseArea

                    anchors.fill: parent
                    enabled: actionRow.armed
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: actionRow.confirmRequested()
                }
            }
        }
    }
}
