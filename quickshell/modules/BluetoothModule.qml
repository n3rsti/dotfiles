pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets
import ".."
import "../common"

Item {
    id: bluetoothRoot

    property bool useBackground: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: sortedDevices()
    readonly property var connectedDevices: connectedDeviceList()

    property bool forceDiscoveryOff: false

    width: bluetoothButton.width
    height: bluetoothButton.height

    function sortedDevices() {
        if (!adapter || !adapter.devices)
            return [];

        const values = adapter.devices.values || [];
        let result = [];

        for (let i = 0; i < values.length; i++) {
            const device = values[i];

            if (!device)
                continue;

            if (!device.name || device.name.length === 0)
                continue;

            result.push(device);
        }

        result.sort((a, b) => {
            if (a.connected && !b.connected)
                return -1;

            if (!a.connected && b.connected)
                return 1;

            if ((a.paired || a.bonded) && !(b.paired || b.bonded))
                return -1;

            if (!(a.paired || a.bonded) && (b.paired || b.bonded))
                return 1;

            return bluetoothRoot.deviceName(a).localeCompare(bluetoothRoot.deviceName(b));
        });

        return result;
    }

    function connectedDeviceList() {
        const values = devices || [];
        let result = [];

        for (let i = 0; i < values.length; i++) {
            const device = values[i];

            if (device && device.connected)
                result.push(device);
        }

        return result;
    }

    function deviceName(device) {
        if (!device)
            return "Unknown device";

        if (device.name && device.name.length > 0)
            return device.name;

        if (device.deviceName && device.deviceName.length > 0)
            return device.deviceName;

        if (device.address && device.address.length > 0)
            return device.address;

        return "Unknown device";
    }

    function statusIcon() {
        if (!adapter || !adapter.enabled)
            return Style.bluetoothOffIcon;

        if (connectedDevices.length > 0)
            return Style.bluetoothConnectedIcon;

        return Style.bluetoothOnIcon;
    }

    function statusTitle() {
        if (!adapter)
            return "No Bluetooth adapter";

        if (!adapter.enabled)
            return "Bluetooth disabled";

        if (connectedDevices.length === 1)
            return deviceName(connectedDevices[0]);

        if (connectedDevices.length > 1)
            return connectedDevices.length + " devices connected";

        return "Bluetooth enabled";
    }

    function statusDetail() {
        if (!adapter)
            return "No adapter is exposed by BlueZ.";

        const adapterName = adapter.name && adapter.name.length > 0 ? adapter.name : adapter.adapterId;

        if (!adapter.enabled)
            return adapterName + " • disabled";

        if (adapter.discovering)
            return adapterName + " • scanning";

        if (connectedDevices.length > 0)
            return adapterName + " • connected";

        return adapterName + " • not connected";
    }

    function deviceDetail(device) {
        if (!device)
            return "";

        let parts = [];

        if (device.connected)
            parts.push("Connected");
        else if (device.pairing)
            parts.push("Pairing");
        else if (device.paired || device.bonded)
            parts.push("Paired");
        else
            parts.push("Available");

        if (device.trusted)
            parts.push("Trusted");

        if (device.batteryAvailable)
            parts.push(Math.round(device.battery * 100) + "%");

        return parts.join(" • ");
    }

    function deviceActionText(device) {
        if (!device)
            return "";

        if (device.connected)
            return "Disconnect";

        if (device.pairing)
            return "Pairing...";

        if (device.paired || device.bonded || device.trusted)
            return "Connect";

        return "Pair";
    }

    function refreshDevices() {
        if (!adapter || !adapter.enabled)
            return;

        forceDiscoveryOff = true;
        discoveryRestartTimer.restart();
    }

    function activateDevice(device) {
        if (!device || !adapter || !adapter.enabled)
            return;

        if (device.connected) {
            device.disconnect();
            return;
        }

        if (device.pairing)
            return;

        if (device.paired || device.bonded || device.trusted) {
            device.connect();
            return;
        }

        device.pair();
    }

    function toggleBluetooth() {
        if (!adapter)
            return;

        adapter.enabled = !adapter.enabled;
    }

    function togglePopup() {
        bluetoothPopup.visible = !bluetoothPopup.visible;

        if (bluetoothPopup.visible) {
            bluetoothPopup.anchor.updateAnchor();
            refreshDevices();
        }
    }

    Binding {
        target: bluetoothRoot.adapter
        property: "discovering"
        value: !bluetoothRoot.forceDiscoveryOff && bluetoothPopup.visible && bluetoothRoot.adapter !== null && bluetoothRoot.adapter.enabled
        when: bluetoothRoot.adapter !== null
    }

    Timer {
        id: discoveryRestartTimer

        interval: 250
        repeat: false

        onTriggered: bluetoothRoot.forceDiscoveryOff = false
    }

    Process {
        id: bluetoothSettingsProcess
        command: ["blueman-manager"]
    }

    ModuleBox {
        id: bluetoothButton

        width: Style.bluetoothButtonWidth
        height: Style.moduleHeight
        paddingX: 0
        useBackground: bluetoothRoot.useBackground

        BarText {
            icon: true
            hovered: bluetoothButton.hovered
            textPixelSize: Style.bluetoothIconSize

            text: bluetoothRoot.statusIcon()
        }
    }

    MouseArea {
        anchors.fill: bluetoothButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: bluetoothRoot.togglePopup()
    }

    PopupWindow {
        id: bluetoothPopup

        anchor {
            item: bluetoothRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.bluetoothPopupMaxWidth, Math.max(Style.bluetoothPopupMinWidth, bluetoothPopupBackground.implicitWidth))

        height: bluetoothPopupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                bluetoothRoot.refreshDevices();
        }

        Rectangle {
            id: bluetoothPopupBackground

            anchors.fill: parent

            implicitWidth: bluetoothPopupColumn.implicitWidth + Style.bluetoothPopupPadding * 2
            implicitHeight: bluetoothPopupColumn.implicitHeight + Style.bluetoothPopupPadding * 2

            radius: Style.moduleRadius + 6
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: bluetoothPopupColumn

                x: Style.bluetoothPopupPadding
                y: Style.bluetoothPopupPadding

                width: bluetoothPopup.width - Style.bluetoothPopupPadding * 2
                spacing: Style.bluetoothSectionGap

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        width: parent.width

                        text: "Bluetooth"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: bluetoothRoot.statusTitle()
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: 15
                        font.weight: 800

                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: bluetoothRoot.statusDetail()
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        elide: Text.ElideRight
                    }
                }

                Row {
                    width: parent.width
                    height: Style.bluetoothToggleButtonHeight
                    spacing: 10

                    BluetoothActionButton {
                        width: (parent.width - parent.spacing) / 2
                        labelText: bluetoothRoot.adapter !== null && bluetoothRoot.adapter.enabled ? "Disable" : "Enable"
                        iconText: bluetoothRoot.statusIcon()
                        usable: bluetoothRoot.adapter !== null

                        onPressed: bluetoothRoot.toggleBluetooth()
                    }

                    BluetoothActionButton {
                        width: (parent.width - parent.spacing) / 2
                        labelText: bluetoothRoot.forceDiscoveryOff ? "Refreshing..." : "Refresh"
                        iconText: Style.bluetoothRefreshIcon
                        usable: bluetoothRoot.adapter !== null && bluetoothRoot.adapter.enabled

                        onPressed: bluetoothRoot.refreshDevices()
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
                    spacing: 8

                    Text {
                        width: parent.width

                        text: "Available devices"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: 700
                    }

                    Flickable {
                        id: bluetoothDevicesFlickable

                        readonly property bool empty: bluetoothRoot.devices.length === 0

                        width: parent.width
                        height: empty ? 72 : Math.min(Style.bluetoothDeviceListMaxHeight, bluetoothDevicesColumn.implicitHeight)

                        contentWidth: width
                        contentHeight: empty ? height : bluetoothDevicesColumn.implicitHeight
                        clip: true
                        interactive: !empty && contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: bluetoothDevicesColumn

                            width: bluetoothDevicesFlickable.width
                            spacing: 5
                            visible: !bluetoothDevicesFlickable.empty

                            Repeater {
                                model: bluetoothRoot.devices

                                BluetoothDeviceRow {
                                    required property var modelData

                                    device: modelData
                                    titleText: bluetoothRoot.deviceName(modelData)
                                    detailText: bluetoothRoot.deviceDetail(modelData)
                                    actionText: bluetoothRoot.deviceActionText(modelData)

                                    selected: modelData !== null && modelData.connected

                                    onSelectedDevice: function (device) {
                                        bluetoothRoot.activateDevice(device);
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 28

                            visible: bluetoothDevicesFlickable.empty

                            text: bluetoothRoot.adapter === null ? "No Bluetooth adapter found" : !bluetoothRoot.adapter.enabled ? "Bluetooth is disabled" : bluetoothRoot.forceDiscoveryOff ? "Refreshing devices..." : "No Bluetooth devices found"

                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSize
                            font.weight: Style.fontWeight

                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                BluetoothSettingsButton {
                    width: parent.width
                    labelText: "Bluetooth settings"
                    iconText: Style.bluetoothSettingsIcon

                    onPressed: {
                        bluetoothSettingsProcess.startDetached();
                        bluetoothPopup.visible = false;
                    }
                }
            }
        }
    }

    component BluetoothActionButton: Item {
        id: actionButton

        required property string labelText
        required property string iconText
        property bool usable: true

        signal pressed

        height: Style.bluetoothToggleButtonHeight
        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: actionMouseArea.containsMouse && actionButton.usable ? Style.playerControlHoverBackground : Style.playerPanelBackground

            opacity: actionButton.usable ? 1 : 0.45

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: actionButton.iconText
                color: actionMouseArea.containsMouse && actionButton.usable ? Style.foregroundHover : Style.foreground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.bluetoothIconSize
                font.weight: Style.fontWeight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: actionButton.labelText
                color: actionMouseArea.containsMouse && actionButton.usable ? Style.foregroundHover : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: 700
            }
        }

        MouseArea {
            id: actionMouseArea

            anchors.fill: parent
            enabled: actionButton.usable
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: actionButton.pressed()
        }
    }

    component BluetoothDeviceRow: Item {
        id: deviceRow

        required property var device
        required property string titleText
        required property string detailText
        required property string actionText
        property bool selected: false

        signal selectedDevice(var device)

        width: parent ? parent.width : Style.bluetoothPopupMinWidth
        height: Style.bluetoothDeviceRowHeight
        Rectangle {
            anchors.fill: parent

            radius: 14
            color: deviceRow.selected ? Style.playerControlHoverBackground : deviceMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"

            border.color: deviceRow.selected ? "#35ffffff" : "transparent"
            border.width: deviceRow.selected ? 1 : 0

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
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

            Item {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    anchors.centerIn: parent

                    width: Style.bluetoothDeviceIconSize
                    height: Style.bluetoothDeviceIconSize
                    implicitSize: Style.bluetoothDeviceIconSize

                    source: deviceRow.device !== null && deviceRow.device.icon !== undefined && deviceRow.device.icon.length > 0 ? Quickshell.iconPath(deviceRow.device.icon, true) : ""

                    asynchronous: true
                    mipmap: true
                    visible: source.length > 0 && status === Image.Ready

                    backer.fillMode: Image.PreserveAspectFit
                }

                Text {
                    anchors.centerIn: parent

                    visible: deviceRow.device === null || deviceRow.device.icon === undefined || deviceRow.device.icon.length === 0

                    text: Style.bluetoothDeviceFallbackIcon
                    color: deviceRow.selected ? Style.workspaceFocusedForeground : Style.popupMutedForeground

                    font.family: Style.iconFontFamily
                    font.pixelSize: Style.bluetoothIconSize
                    font.weight: Style.fontWeight
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 24 - actionTextItem.width - parent.spacing * 2
                spacing: 2

                Text {
                    width: parent.width

                    text: deviceRow.titleText
                    color: deviceRow.selected ? Style.workspaceFocusedForeground : Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: deviceRow.selected ? 700 : Style.fontWeight

                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: deviceRow.detailText
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    elide: Text.ElideRight
                }
            }

            Text {
                id: actionTextItem

                anchors.verticalCenter: parent.verticalCenter

                text: deviceRow.actionText
                color: deviceMouseArea.containsMouse ? Style.foregroundHover : Style.popupMutedForeground

                font.family: Style.fontFamily
                font.pixelSize: Style.popupSmallFontSize
                font.weight: 700
            }
        }

        MouseArea {
            id: deviceMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: deviceRow.selectedDevice(deviceRow.device)
        }
    }

    component BluetoothSettingsButton: Item {
        id: settingsButton

        required property string labelText
        required property string iconText

        signal pressed

        height: Style.bluetoothSettingsButtonHeight
        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: settingsMouseArea.containsMouse ? Style.playerControlHoverBackground : Style.playerPanelBackground

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: settingsButton.iconText
                color: settingsMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.bluetoothIconSize
                font.weight: Style.fontWeight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: settingsButton.labelText
                color: settingsMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: 700
            }
        }

        MouseArea {
            id: settingsMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: settingsButton.pressed()
        }
    }
}
