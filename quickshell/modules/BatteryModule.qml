pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import ".."
import "../common"

Item {
    id: batteryRoot

    property bool useBackground: true
    readonly property var device: UPower.displayDevice
    readonly property bool available: device !== null && device.ready && device.isLaptopBattery && device.isPresent
    readonly property bool charging: available && (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge)
    readonly property bool discharging: available && (device.state === UPowerDeviceState.Discharging || device.state === UPowerDeviceState.PendingDischarge)
    readonly property int percentage: available ? Math.round(device.percentage) : 0
    property string uptimeText: ""

    width: available ? batteryButton.width : 0
    height: batteryButton.height
    visible: available

    function batteryIcon() {
        if (!available)
            return "";

        if (charging)
            return Style.batteryChargingIcon;

        if (percentage >= 95)
            return Style.batteryFullIcon;

        if (percentage >= 70)
            return Style.batteryHighIcon;

        if (percentage >= 35)
            return Style.batteryMediumIcon;

        if (percentage >= 12)
            return Style.batteryLowIcon;

        return Style.batteryEmptyIcon;
    }

    function statusTitle() {
        if (!available)
            return "No battery";

        if (charging)
            return "Charging";

        if (device.state === UPowerDeviceState.FullyCharged)
            return "Fully charged";

        if (discharging)
            return "On battery";

        return "Battery";
    }

    function statusDetail() {
        if (!available)
            return "";

        if (charging && device.timeToFull > 0)
            return "Full in " + formatDuration(device.timeToFull);

        if (discharging && device.timeToEmpty > 0)
            return formatDuration(device.timeToEmpty) + " remaining";

        if (device.state === UPowerDeviceState.FullyCharged)
            return "Power adapter connected";

        return "Power status available";
    }

    function formatDuration(seconds) {
        const total = Math.max(0, Math.round(seconds));
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor((total % 3600) / 60);

        if (hours > 0)
            return hours + "h " + minutes + "m";

        return minutes + "m";
    }

    function powerText() {
        if (!available || device.changeRate === 0)
            return "Unavailable";

        return Math.abs(device.changeRate).toFixed(1) + " W";
    }

    function healthText() {
        if (!available || !device.healthSupported)
            return "Unavailable";

        return Math.round(device.healthPercentage) + "%";
    }

    function timeText() {
        if (!available)
            return "Unavailable";

        if (charging && device.timeToFull > 0)
            return formatDuration(device.timeToFull);

        if (discharging && device.timeToEmpty > 0)
            return formatDuration(device.timeToEmpty);

        return "Unavailable";
    }

    function energyText() {
        if (!available)
            return "Unavailable";

        return device.energy.toFixed(1) + " / " + device.energyCapacity.toFixed(1) + " Wh";
    }

    function refreshUptime() {
        uptimeProcess.running = true;
    }

    function togglePopup() {
        batteryPopup.visible = !batteryPopup.visible;

        if (batteryPopup.visible) {
            batteryPopup.anchor.updateAnchor();
            refreshUptime();
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true

        onTriggered: batteryRoot.refreshUptime()
    }

    Process {
        id: uptimeProcess

        command: [
            "sh",
            "-c",
            "uptime -p 2>/dev/null | sed 's/^up //' || awk '{print int($1/3600) \"h \" int(($1%3600)/60) \"m\"}' /proc/uptime"
        ]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: batteryRoot.uptimeText = text.trim()
        }

        stderr: StdioCollector {}
    }

    ModuleBox {
        id: batteryButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        contentSpacing: 7
        useBackground: batteryRoot.useBackground

        width: Math.max(Style.batteryButtonMinWidth, Style.modulePaddingX * 2 + batteryIconText.implicitWidth + contentSpacing + batteryText.implicitWidth)

        BarText {
            id: batteryIconText

            icon: true
            hovered: batteryMouseArea.containsMouse
            textPixelSize: Style.batteryIconSize

            text: batteryRoot.batteryIcon()
        }

        BarText {
            id: batteryText

            hovered: batteryMouseArea.containsMouse
            text: batteryRoot.percentage + "%"
        }
    }

    MouseArea {
        id: batteryMouseArea

        anchors.fill: batteryButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: batteryRoot.togglePopup()
    }

    PopupWindow {
        id: batteryPopup

        anchor {
            item: batteryRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.batteryPopupMaxWidth, Math.max(Style.batteryPopupMinWidth, popupBackground.implicitWidth))
        height: popupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                batteryRoot.refreshUptime();
        }

        Rectangle {
            id: popupBackground

            anchors.fill: parent

            implicitWidth: popupColumn.implicitWidth + Style.batteryPopupPadding * 2
            implicitHeight: popupColumn.implicitHeight + Style.batteryPopupPadding * 2

            radius: Style.moduleRadius + 6
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: popupColumn

                x: Style.batteryPopupPadding
                y: Style.batteryPopupPadding

                width: batteryPopup.width - Style.batteryPopupPadding * 2
                spacing: Style.batteryPopupSectionGap

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        width: parent.width

                        text: "Battery"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: batteryRoot.statusTitle() + " • " + batteryRoot.percentage + "%"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: 15
                        font.weight: 800

                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: batteryRoot.statusDetail()
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Style.moduleBorder
                    opacity: 0.9
                }

                Column {
                    width: parent.width
                    spacing: 5

                    BatteryStatRow {
                        titleText: "Time left"
                        valueText: batteryRoot.timeText()
                    }

                    BatteryStatRow {
                        titleText: "Power draw"
                        valueText: batteryRoot.powerText()
                    }

                    BatteryStatRow {
                        titleText: "Health"
                        valueText: batteryRoot.healthText()
                    }

                    BatteryStatRow {
                        titleText: "Energy"
                        valueText: batteryRoot.energyText()
                    }

                    BatteryStatRow {
                        titleText: "Uptime"
                        valueText: batteryRoot.uptimeText.length > 0 ? batteryRoot.uptimeText : "Unavailable"
                    }
                }
            }
        }
    }

    component BatteryStatRow: Item {
        id: statRow

        required property string titleText
        required property string valueText

        width: parent ? parent.width : Style.batteryPopupMinWidth
        height: Style.batteryStatRowHeight

        Rectangle {
            anchors.fill: parent

            radius: 12
            color: Style.playerPanelBackground
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 12
                rightMargin: 12
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: Math.max(72, parent.width * 0.34)

                text: statRow.titleText
                color: Style.popupMutedForeground

                font.family: Style.fontFamily
                font.pixelSize: Style.popupSmallFontSize
                font.weight: 700

                elide: Text.ElideRight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 72 - parent.spacing

                text: statRow.valueText
                color: Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: Style.fontWeight

                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
            }
        }
    }

    Component.onCompleted: refreshUptime()
}
