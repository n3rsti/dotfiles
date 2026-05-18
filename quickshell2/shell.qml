//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
    id: shell

    QtObject {
        id: style

        // Bar geometry
        property int barHeight: 38
        property int edgeMargin: 15
        property int moduleGap: 5

        // Module geometry
        property int moduleHeight: 28
        property int moduleRadius: 13
        property int modulePaddingX: 12
        property int trayPaddingX: 15

        // Workspaces
        property bool workspacesAllOutputs: true
        property bool workspaceShowNamed: false
        property bool workspaceUseNames: false
        property int workspaceButtonMinWidth: 24
        property int workspaceButtonHeight: 24
        property int workspaceButtonPaddingX: 8
        property int workspaceButtonGap: 2
        property int workspaceModulePaddingX: 5
        property int workspaceFontSize: 13
        property int workspaceFocusedFontWeight: 700

        // Tray
        property int trayIconSize: 17
        property int trayIconButtonSize: 20
        property int trayIconGap: 13

        // Network module
        property int networkButtonWidth: 42
        property int networkIconSize: 16
        property bool networkWifiScanAlways: false
        property int networkWifiRefreshIntervalMs: 10000

        // Network popup
        property int popupGap: 8
        property int networkPopupMinWidth: 300
        property int networkPopupMaxWidth: 420
        property int networkPopupMaxHeight: 560
        property int networkPopupPadding: 14
        property int networkPopupHeaderSpacing: 10
        property int networkListMaxHeight: 340
        property int networkEmptyStateMinHeight: 76
        property int networkEmptyStatePaddingY: 18
        property int networkRowHeight: 34
        property int networkRowRadius: 10
        property int networkRowPaddingX: 10

        // Colors, taken from your Waybar theme
        property color foreground: "#c0caf5"
        property color foregroundHover: "#a0aad5"
        property color moduleBackground: "#99000008"
        property color moduleBorder: "#34344d"
        property color moduleHoverOverlay: "#1425252d"

        // Workspace colors
        property color workspaceFocusedBackground: "#cc25252d"
        property color workspaceFocusedForeground: "#d0daff"
        property color workspaceOccupiedForeground: "#c0caf5"
        property color workspaceUrgentForeground: "#ff5555"

        // Popup colors
        property color popupBackground: "#ee000008"
        property color popupBorder: "#34344d"
        property color popupRowHover: "#2625252d"
        property color popupMutedForeground: "#a0aad5"

        // Borders
        property int borderWidth: 1

        // Font
        property string fontFamily: "Adwaita Sans"
        property string iconFontFamily: "Symbols Nerd Font Mono"
        property int fontSize: 12
        property int fontWeight: 600
        property int popupTitleFontSize: 13
        property int popupSmallFontSize: 11

        // Nerd Font network icons
        property string networkDisconnectedIcon: "󰌙"
        property string wiredConnectedIcon: "󰈀"
        property string wiredNoLinkIcon: "󰈂"
        property string wifiOffIcon: "󰤯"
        property string wifiDisconnectedIcon: "󰤭"
        property string wifiStrength1Icon: "󰤟"
        property string wifiStrength2Icon: "󰤢"
        property string wifiStrength3Icon: "󰤥"
        property string wifiStrength4Icon: "󰤨"

        // Clock
        property string clockFormat: "dd MMM   hh:mm"
    }

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            screen: modelData

            color: "transparent"
            surfaceFormat.opaque: false

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: style.barHeight
            exclusiveZone: style.barHeight

            Item {
                anchors.fill: parent

                BarSection {
                    anchors.left: parent.left
                    anchors.leftMargin: style.edgeMargin
                    anchors.verticalCenter: parent.verticalCenter

                    WorkspacesModule {
                        shellScreen: bar.screen
                    }

                    TrayModule {}
                }

                BarSection {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    ClockModule {}
                }

                BarSection {
                    anchors.right: parent.right
                    anchors.rightMargin: style.edgeMargin
                    anchors.verticalCenter: parent.verticalCenter

                    NetworkModule {}
                }
            }
        }
    }

    component BarSection: Item {
        id: section

        default property alias content: row.data
        property alias spacing: row.spacing

        width: row.implicitWidth
        height: row.implicitHeight

        Row {
            id: row
            anchors.centerIn: parent
            spacing: style.moduleGap
        }
    }

    component ModuleBox: Rectangle {
        id: box

        default property alias content: contentRow.data
        property alias contentSpacing: contentRow.spacing

        property int paddingX: style.modulePaddingX
        property bool hovered: hoverHandler.hovered

        implicitWidth: contentRow.implicitWidth + paddingX * 2
        implicitHeight: style.moduleHeight

        radius: style.moduleRadius
        color: style.moduleBackground
        border.color: style.moduleBorder
        border.width: style.borderWidth

        HoverHandler {
            id: hoverHandler
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: style.moduleHoverOverlay
            opacity: box.hovered ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: style.moduleGap
        }
    }

    component WorkspacesModule: ModuleBox {
        id: workspacesModule

        required property var shellScreen

        readonly property var currentMonitor: Hyprland.monitorFor(shellScreen)
        readonly property var visibleWorkspaces: filteredWorkspaces()

        paddingX: style.workspaceModulePaddingX
        contentSpacing: style.workspaceButtonGap
        visible: visibleWorkspaces.length > 0

        function filteredWorkspaces() {
            const values = Hyprland.workspaces.values || [];
            let result = [];

            for (let i = 0; i < values.length; i++) {
                const workspace = values[i];

                if (!workspace)
                    continue;

                if (!style.workspaceShowNamed && workspace.id < 0)
                    continue;

                if (!style.workspacesAllOutputs && currentMonitor !== null && workspace.monitor !== currentMonitor) {
                    continue;
                }

                result.push(workspace);
            }

            result.sort((a, b) => a.id - b.id);
            return result;
        }

        Repeater {
            model: workspacesModule.visibleWorkspaces

            WorkspaceButton {
                required property var modelData
                workspace: modelData
            }
        }
    }

    component WorkspaceButton: Item {
        id: workspaceButton

        required property var workspace

        readonly property bool focused: workspace !== null && Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === workspace.id

        readonly property bool urgent: workspace !== null && workspace.urgent

        width: Math.max(style.workspaceButtonMinWidth, workspaceLabel.implicitWidth + style.workspaceButtonPaddingX * 2)
        height: style.workspaceButtonHeight

        function labelText() {
            if (!workspace)
                return "";

            if (style.workspaceUseNames && workspace.name && workspace.name.length > 0)
                return workspace.name.replace("special:", "");

            return workspace.id;
        }

        Rectangle {
            anchors.fill: parent
            radius: style.moduleRadius
            color: workspaceButton.focused ? style.workspaceFocusedBackground : style.moduleHoverOverlay
            opacity: workspaceButton.focused || mouseArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            id: workspaceLabel
            anchors.centerIn: parent

            text: workspaceButton.labelText()

            color: workspaceButton.urgent ? style.workspaceUrgentForeground : workspaceButton.focused ? style.workspaceFocusedForeground : style.workspaceOccupiedForeground

            font.family: style.fontFamily
            font.pixelSize: style.workspaceFontSize
            font.weight: workspaceButton.focused ? style.workspaceFocusedFontWeight : style.fontWeight

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton

            onClicked: {
                if (workspace)
                    workspace.activate();
            }
        }
    }

    component TrayModule: ModuleBox {
        id: trayModule

        paddingX: style.trayPaddingX
        contentSpacing: style.trayIconGap

        Repeater {
            model: SystemTray.items ? SystemTray.items.values : []

            TrayIconButton {
                required property var modelData
                trayItem: modelData
            }
        }
    }

    component TrayIconButton: Item {
        id: trayButton

        required property var trayItem

        width: style.trayIconButtonSize
        height: style.moduleHeight

        function iconSource(icon) {
            if (!icon)
                return "";

            if (icon.includes("?path=")) {
                const parts = icon.split("?path=");
                const name = parts[0];
                const path = parts[1];
                const fileName = name.substring(name.lastIndexOf("/") + 1);
                return "file://" + path + "/" + fileName;
            }

            return icon;
        }

        function openMenu() {
            if (trayItem && trayItem.hasMenu && trayItem.menu) {
                menuAnchor.open();
                return true;
            }

            return false;
        }

        QsMenuAnchor {
            id: menuAnchor

            menu: trayItem ? trayItem.menu : null

            anchor {
                item: trayButton
                edges: Edges.Bottom | Edges.Left
                gravity: Edges.Bottom | Edges.Right
            }
        }

        IconImage {
            anchors.centerIn: parent

            width: style.trayIconSize
            height: style.trayIconSize
            implicitSize: style.trayIconSize

            asynchronous: true
            mipmap: true
            source: trayButton.iconSource(trayItem ? trayItem.icon : "")

            backer.fillMode: Image.PreserveAspectFit
            opacity: status === Image.Ready ? 1 : 0.65
        }

        Rectangle {
            anchors.fill: parent
            radius: style.moduleRadius
            color: style.moduleHoverOverlay
            opacity: mouseArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: function (mouse) {
                if (!trayItem)
                    return;

                if (mouse.button === Qt.LeftButton) {
                    if (trayItem.onlyMenu) {
                        trayButton.openMenu();
                    } else {
                        trayItem.activate();
                    }
                } else if (mouse.button === Qt.RightButton) {
                    trayButton.openMenu();
                } else if (mouse.button === Qt.MiddleButton) {
                    trayItem.secondaryActivate();
                }
            }
        }
    }

    component NetworkModule: Item {
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
                return style.wifiStrength4Icon;

            if (strength >= 0.50)
                return style.wifiStrength3Icon;

            if (strength >= 0.25)
                return style.wifiStrength2Icon;

            return style.wifiStrength1Icon;
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
                return style.wiredConnectedIcon;

            if (connectedWifiNetwork)
                return wifiIconForStrength(connectedWifiNetwork.signalStrength);

            if (linkedWiredDevice)
                return style.wiredNoLinkIcon;

            if (wifiDevice !== null) {
                if (!Networking.wifiHardwareEnabled || !Networking.wifiEnabled)
                    return style.wifiOffIcon;

                return style.wifiDisconnectedIcon;
            }

            if (wiredDevice !== null)
                return style.wiredNoLinkIcon;

            return style.networkDisconnectedIcon;
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
            value: !networkRoot.forceScannerOff && (style.networkWifiScanAlways || networkPopup.visible)
            when: networkRoot.wifiDevice !== null
        }

        Timer {
            id: scannerRestartTimer

            interval: 200
            repeat: false

            onTriggered: networkRoot.forceScannerOff = false
        }

        Timer {
            interval: style.networkWifiRefreshIntervalMs
            repeat: true
            running: networkPopup.visible && networkRoot.wifiDevice !== null && style.networkWifiRefreshIntervalMs > 0

            onTriggered: networkRoot.refreshWifiNetworks()
        }

        ModuleBox {
            id: networkButton

            width: style.networkButtonWidth
            height: style.moduleHeight
            paddingX: 0

            Text {
                text: networkRoot.statusIcon()

                color: networkButton.hovered ? style.foregroundHover : style.foreground

                font.family: style.iconFontFamily
                font.pixelSize: style.networkIconSize
                font.weight: style.fontWeight

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
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
                margins.top: style.popupGap
            }

            width: Math.min(style.networkPopupMaxWidth, Math.max(style.networkPopupMinWidth, networkPopupBackground.implicitWidth))

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

                implicitWidth: popupColumn.implicitWidth + style.networkPopupPadding * 2
                implicitHeight: popupColumn.implicitHeight + style.networkPopupPadding * 2

                radius: style.moduleRadius
                color: style.popupBackground
                border.color: style.popupBorder
                border.width: style.borderWidth

                Column {
                    id: popupColumn

                    x: style.networkPopupPadding
                    y: style.networkPopupPadding

                    width: networkPopup.width - style.networkPopupPadding * 2
                    spacing: style.networkPopupHeaderSpacing

                    Row {
                        id: networkHeader

                        width: parent.width
                        spacing: 10

                        height: Math.max(headerIcon.implicitHeight, headerTextColumn.implicitHeight)

                        Text {
                            id: headerIcon

                            anchors.verticalCenter: parent.verticalCenter

                            text: networkRoot.statusIcon()
                            color: style.foreground

                            font.family: style.iconFontFamily
                            font.pixelSize: 22
                            font.weight: style.fontWeight
                        }

                        Column {
                            id: headerTextColumn

                            anchors.verticalCenter: parent.verticalCenter

                            width: parent.width - headerIcon.width - parent.spacing
                            spacing: 2

                            Text {
                                width: parent.width

                                text: networkRoot.statusTitle()
                                color: style.foreground

                                font.family: style.fontFamily
                                font.pixelSize: style.popupTitleFontSize
                                font.weight: 700

                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width

                                text: networkRoot.statusDetail()
                                color: style.popupMutedForeground

                                font.family: style.fontFamily
                                font.pixelSize: style.popupSmallFontSize
                                font.weight: style.fontWeight

                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: style.moduleBorder
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
                            color: style.foreground

                            font.family: style.fontFamily
                            font.pixelSize: style.fontSize
                            font.weight: 700
                        }

                        Text {
                            id: refreshText

                            anchors.verticalCenter: parent.verticalCenter

                            text: networkRoot.forceScannerOff ? "Refreshing..." : "Refresh"
                            color: refreshMouseArea.containsMouse && networkRoot.wifiDevice !== null ? style.foregroundHover : style.popupMutedForeground

                            opacity: networkRoot.wifiDevice !== null ? 1 : 0.55

                            font.family: style.fontFamily
                            font.pixelSize: style.popupSmallFontSize
                            font.weight: style.fontWeight

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
                        readonly property int emptyContentHeight: emptyNetworksText.implicitHeight + style.networkEmptyStatePaddingY * 2
                        readonly property int listContentHeight: empty ? Math.max(style.networkEmptyStateMinHeight, emptyContentHeight) : networksColumn.implicitHeight

                        width: parent.width
                        height: Math.min(style.networkListMaxHeight, listContentHeight)

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
                                color: style.popupMutedForeground

                                font.family: style.fontFamily
                                font.pixelSize: style.fontSize
                                font.weight: style.fontWeight

                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
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

        width: parent ? parent.width : style.networkPopupMinWidth
        height: style.networkRowHeight

        function iconForStrength() {
            if (strength >= 0.75)
                return style.wifiStrength4Icon;

            if (strength >= 0.50)
                return style.wifiStrength3Icon;

            if (strength >= 0.25)
                return style.wifiStrength2Icon;

            return style.wifiStrength1Icon;
        }

        Rectangle {
            anchors.fill: parent

            radius: style.networkRowRadius
            color: networkMouseArea.containsMouse || networkRow.connected ? style.popupRowHover : "transparent"

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
                leftMargin: style.networkRowPaddingX
                rightMargin: style.networkRowPaddingX
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: networkRow.iconForStrength()
                color: networkRow.connected ? style.workspaceFocusedForeground : style.foreground

                font.family: style.iconFontFamily
                font.pixelSize: style.networkIconSize
                font.weight: style.fontWeight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 32

                text: network ? network.name : ""
                color: networkRow.connected ? style.workspaceFocusedForeground : style.foreground

                font.family: style.fontFamily
                font.pixelSize: style.fontSize
                font.weight: networkRow.connected ? 700 : style.fontWeight

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: networkMouseArea

            anchors.fill: parent
            hoverEnabled: true
        }
    }

    component ClockModule: ModuleBox {
        id: clockModule

        Text {
            text: Qt.formatDateTime(clock.date, style.clockFormat)

            color: clockModule.hovered ? style.foregroundHover : style.foreground

            font.family: style.fontFamily
            font.pixelSize: style.fontSize
            font.weight: style.fontWeight

            verticalAlignment: Text.AlignVCenter
        }
    }
}
