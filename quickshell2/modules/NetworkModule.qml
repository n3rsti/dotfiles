pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Networking
import ".."
import "../common"

Item {
    id: networkRoot

    readonly property var wifiDevice: firstDevice(DeviceType.Wifi)
    readonly property var wiredDevice: firstDevice(DeviceType.Wired)
    readonly property var connectedWifiNetwork: firstConnectedWifiNetwork()
    readonly property var connectedWiredDevice: firstConnectedWiredDevice()
    readonly property var linkedWiredDevice: firstLinkedWiredDevice()
    readonly property var availableWifiNetworks: sortedWifiNetworks()

    property bool forceScannerOff: false

    width: networkButton.width
    height: networkButton.height

    function firstDevice(type) {
        const devices = Networking.devices.values || [];

        for (let i = 0; i < devices.length; i++) {
            const device = devices[i];

            if (device && device.type === type)
                return device;
        }

        return null;
    }

    function firstConnectedWiredDevice() {
        const devices = Networking.devices.values || [];

        for (let i = 0; i < devices.length; i++) {
            const device = devices[i];

            if (device && device.type === DeviceType.Wired && device.connected)
                return device;
        }

        return null;
    }

    function firstLinkedWiredDevice() {
        const devices = Networking.devices.values || [];

        for (let i = 0; i < devices.length; i++) {
            const device = devices[i];

            if (device && device.type === DeviceType.Wired && device.hasLink)
                return device;
        }

        return null;
    }

    function firstConnectedWifiNetwork() {
        if (!wifiDevice || !wifiDevice.networks)
            return null;

        const networks = wifiDevice.networks.values || [];

        for (let i = 0; i < networks.length; i++) {
            const network = networks[i];

            if (network && network.connected)
                return network;
        }

        return null;
    }

    function sortedWifiNetworks() {
        if (!wifiDevice || !wifiDevice.networks)
            return [];

        const networks = wifiDevice.networks.values || [];
        let result = [];

        for (let i = 0; i < networks.length; i++) {
            const network = networks[i];

            if (!network)
                continue;

            if (!network.name || network.name.length === 0)
                continue;

            result.push(network);
        }

        result.sort((a, b) => {
            if (a.connected && !b.connected)
                return -1;

            if (!a.connected && b.connected)
                return 1;

            return b.signalStrength - a.signalStrength;
        });

        return result;
    }

    function wifiIconForStrength(strength) {
        if (strength >= 0.75)
            return Style.wifiStrength4Icon;

        if (strength >= 0.50)
            return Style.wifiStrength3Icon;

        if (strength >= 0.25)
            return Style.wifiStrength2Icon;

        return Style.wifiStrength1Icon;
    }

    function linkSpeedText(device) {
        if (!device || device.linkSpeed <= 0)
            return "";

        if (device.linkSpeed >= 1000)
            return (device.linkSpeed / 1000).toFixed(device.linkSpeed % 1000 === 0 ? 0 : 1) + " Gb/s";

        return device.linkSpeed + " Mb/s";
    }

    function wiredDisplayName(device) {
        if (!device)
            return "Ethernet";

        if (device.network && device.network.name && device.network.name.length > 0)
            return device.network.name;

        if (device.name && device.name.length > 0)
            return "Ethernet (" + device.name + ")";

        return "Ethernet";
    }

    function statusIcon() {
        if (connectedWiredDevice)
            return Style.wiredConnectedIcon;

        if (connectedWifiNetwork)
            return wifiIconForStrength(connectedWifiNetwork.signalStrength);

        if (linkedWiredDevice)
            return Style.wiredNoLinkIcon;

        if (wifiDevice !== null) {
            if (!Networking.wifiHardwareEnabled || !Networking.wifiEnabled)
                return Style.wifiOffIcon;

            return Style.wifiDisconnectedIcon;
        }

        if (wiredDevice !== null)
            return Style.wiredNoLinkIcon;

        return Style.networkDisconnectedIcon;
    }

    function statusTitle() {
        if (connectedWiredDevice)
            return wiredDisplayName(connectedWiredDevice);

        if (connectedWifiNetwork)
            return connectedWifiNetwork.name;

        if (linkedWiredDevice)
            return "Ethernet link detected";

        if (wifiDevice !== null) {
            if (!Networking.wifiHardwareEnabled)
                return "Wi-Fi hardware disabled";

            if (!Networking.wifiEnabled)
                return "Wi-Fi disabled";

            return "Wi-Fi disconnected";
        }

        if (wiredDevice !== null)
            return "Ethernet cable unplugged";

        return "No network device found";
    }

    function statusDetail() {
        if (connectedWiredDevice) {
            const speed = linkSpeedText(connectedWiredDevice);

            if (speed.length > 0)
                return connectedWiredDevice.name + " • " + speed;

            return connectedWiredDevice.name;
        }

        if (connectedWifiNetwork) {
            const strength = Math.round(connectedWifiNetwork.signalStrength * 100);
            return wifiDevice.name + " • " + strength + "% signal";
        }

        if (linkedWiredDevice)
            return linkedWiredDevice.name + " • cable connected, waiting for network";

        if (wifiDevice !== null) {
            if (!Networking.wifiHardwareEnabled)
                return "The wireless device is blocked by hardware rfkill.";

            if (!Networking.wifiEnabled)
                return "Wireless networking is disabled.";

            return wifiDevice.name + " • no active Wi-Fi connection";
        }

        if (wiredDevice !== null)
            return wiredDevice.name + " • no physical link";

        return "No wired or wireless device is exposed by NetworkManager.";
    }

    function emptyWifiMessage() {
        if (wifiDevice === null) {
            if (wiredDevice !== null)
                return "No Wi-Fi device found. Ethernet status is shown above.";

            return "No Wi-Fi device found.";
        }

        if (!Networking.wifiHardwareEnabled)
            return "Wi-Fi hardware is disabled.";

        if (!Networking.wifiEnabled)
            return "Wi-Fi is disabled.";

        if (forceScannerOff)
            return "Refreshing Wi-Fi networks...";

        return "No Wi-Fi networks found.";
    }

    function refreshWifiNetworks() {
        if (wifiDevice === null)
            return;

        forceScannerOff = true;
        scannerRestartTimer.restart();
    }

    function togglePopup() {
        networkPopup.visible = !networkPopup.visible;

        if (networkPopup.visible) {
            networkPopup.anchor.updateAnchor();
            refreshWifiNetworks();
        }
    }

    Binding {
        target: networkRoot.wifiDevice
        property: "scannerEnabled"
        value: !networkRoot.forceScannerOff && (Style.networkWifiScanAlways || networkPopup.visible)
        when: networkRoot.wifiDevice !== null
    }

    Timer {
        id: scannerRestartTimer

        interval: 200
        repeat: false

        onTriggered: networkRoot.forceScannerOff = false
    }

    Timer {
        interval: Style.networkWifiRefreshIntervalMs
        repeat: true
        running: networkPopup.visible && networkRoot.wifiDevice !== null && Style.networkWifiRefreshIntervalMs > 0

        onTriggered: networkRoot.refreshWifiNetworks()
    }

    ModuleBox {
        id: networkButton

        width: Style.networkButtonWidth
        height: Style.moduleHeight
        paddingX: 0

        BarText {
            icon: true
            hovered: networkButton.hovered
            textPixelSize: Style.networkIconSize

            text: networkRoot.statusIcon()
        }
    }

    MouseArea {
        anchors.fill: networkButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: networkRoot.togglePopup()
    }

    PopupWindow {
        id: networkPopup

        anchor {
            item: networkRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.networkPopupMaxWidth, Math.max(Style.networkPopupMinWidth, networkPopupBackground.implicitWidth))

        height: networkPopupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                networkRoot.refreshWifiNetworks();
        }

        Rectangle {
            id: networkPopupBackground

            anchors.fill: parent

            implicitWidth: popupColumn.implicitWidth + Style.networkPopupPadding * 2
            implicitHeight: popupColumn.implicitHeight + Style.networkPopupPadding * 2

            radius: Style.moduleRadius
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: popupColumn

                x: Style.networkPopupPadding
                y: Style.networkPopupPadding

                width: networkPopup.width - Style.networkPopupPadding * 2
                spacing: Style.networkPopupHeaderSpacing

                Row {
                    id: networkHeader

                    width: parent.width
                    spacing: 10
                    height: Math.max(headerIcon.implicitHeight, headerTextColumn.implicitHeight)

                    Text {
                        id: headerIcon

                        anchors.verticalCenter: parent.verticalCenter

                        text: networkRoot.statusIcon()
                        color: Style.foreground

                        font.family: Style.iconFontFamily
                        font.pixelSize: 22
                        font.weight: Style.fontWeight
                    }

                    Column {
                        id: headerTextColumn

                        anchors.verticalCenter: parent.verticalCenter

                        width: parent.width - headerIcon.width - parent.spacing
                        spacing: 2

                        Text {
                            width: parent.width

                            text: networkRoot.statusTitle()
                            color: Style.foreground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.popupTitleFontSize
                            font.weight: 700

                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width

                            text: networkRoot.statusDetail()
                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.popupSmallFontSize
                            font.weight: Style.fontWeight

                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Style.moduleBorder
                    opacity: 0.9
                }

                Row {
                    width: parent.width
                    height: Math.max(listTitle.implicitHeight, refreshText.implicitHeight) + 4

                    Text {
                        id: listTitle

                        anchors.verticalCenter: parent.verticalCenter

                        width: parent.width - refreshText.implicitWidth - 12

                        text: "Available Wi-Fi networks"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: 700
                    }

                    Text {
                        id: refreshText

                        anchors.verticalCenter: parent.verticalCenter

                        text: networkRoot.forceScannerOff ? "Refreshing..." : "Refresh"
                        color: refreshMouseArea.containsMouse && networkRoot.wifiDevice !== null ? Style.foregroundHover : Style.popupMutedForeground

                        opacity: networkRoot.wifiDevice !== null ? 1 : 0.55

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight

                        MouseArea {
                            id: refreshMouseArea

                            anchors.fill: parent
                            enabled: networkRoot.wifiDevice !== null
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: networkRoot.refreshWifiNetworks()
                        }
                    }
                }

                Flickable {
                    id: networksFlickable

                    readonly property bool empty: networkRoot.availableWifiNetworks.length === 0
                    readonly property int emptyContentHeight: emptyNetworksText.implicitHeight + Style.networkEmptyStatePaddingY * 2
                    readonly property int listContentHeight: empty ? Math.max(Style.networkEmptyStateMinHeight, emptyContentHeight) : networksColumn.implicitHeight

                    width: parent.width
                    height: empty ? listContentHeight : Math.min(Style.networkListMaxHeight, listContentHeight)

                    contentWidth: width
                    contentHeight: empty ? height : networksColumn.implicitHeight

                    clip: true
                    interactive: !empty && contentHeight > height

                    Column {
                        id: networksColumn

                        width: networksFlickable.width
                        spacing: 3
                        visible: !networksFlickable.empty

                        Repeater {
                            model: networkRoot.availableWifiNetworks

                            NetworkRow {
                                required property var modelData
                                network: modelData
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        visible: networksFlickable.empty

                        Text {
                            id: emptyNetworksText

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 14
                                rightMargin: 14
                            }

                            text: networkRoot.emptyWifiMessage()
                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSize
                            font.weight: Style.fontWeight

                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    component NetworkRow: Item {
        id: networkRow

        required property var network

        readonly property bool connected: network !== null && network.connected
        readonly property real strength: network !== null ? network.signalStrength : 0.0

        width: parent ? parent.width : Style.networkPopupMinWidth
        height: Style.networkRowHeight

        function iconForStrength() {
            if (strength >= 0.75)
                return Style.wifiStrength4Icon;

            if (strength >= 0.50)
                return Style.wifiStrength3Icon;

            if (strength >= 0.25)
                return Style.wifiStrength2Icon;

            return Style.wifiStrength1Icon;
        }

        Rectangle {
            anchors.fill: parent

            radius: Style.networkRowRadius
            color: networkMouseArea.containsMouse || networkRow.connected ? Style.popupRowHover : "transparent"

            opacity: networkMouseArea.containsMouse || networkRow.connected ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Style.networkRowPaddingX
                rightMargin: Style.networkRowPaddingX
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: networkRow.iconForStrength()
                color: networkRow.connected ? Style.workspaceFocusedForeground : Style.foreground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.networkIconSize
                font.weight: Style.fontWeight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 32

                text: network ? network.name : ""
                color: networkRow.connected ? Style.workspaceFocusedForeground : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: networkRow.connected ? 700 : Style.fontWeight

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: networkMouseArea

            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
