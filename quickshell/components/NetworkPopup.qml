import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../config"
import "./"
import "./components/"

PopupWindow {
    id: popup

    required property var networks
    required property string connectionType
    required property bool wifiEnabled
    required property string activeSSID
    required property int signalStrength
    required property var bluetoothAdapter
    property alias parentWindow: popup.anchor.window

    width: 320
    height: Math.min(500, contentColumn.implicitHeight + Theme.padding * 4)
    visible: false
    color: "transparent"

    anchor {
        rect.y: anchor.window?.contentItem?.height || 0
        rect.x: (anchor.window?.contentItem?.width || 0) - width - Theme.padding
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            if (!containsMouse) {
                closeTimer.start();
            }
        }
        onEntered: closeTimer.stop()

        Timer {
            id: closeTimer
            interval: 500
            onTriggered: popup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.containerBackground
            opacity: 1
            radius: Theme.radius
            border.color: Theme.surfaceColor
            border.width: 1

            Column {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Theme.padding * 2
                spacing: Theme.spacing * 3

                NetworkSection {
                    icon: "󰈀"
                    title: "Ethernet"
                    subtitle: popup.connectionType === "ethernet" ? "Connected" : "Not connected"
                    hasSwitch: false
                    onSettingsClicked: {}
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceColor
                    opacity: 0.2
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacing

                    NetworkSection {
                        icon: NetworkUtils.getWifiIcon(popup.connectionType, popup.signalStrength, popup.wifiEnabled)
                        title: "Wi-Fi"
                        subtitle: NetworkUtils.getWifiStatus(popup.connectionType, popup.activeSSID, popup.signalStrength, popup.wifiEnabled)
                        hasSwitch: true
                        switchChecked: popup.wifiEnabled
                        onSwitchToggled: {
                            wifiToggleProcess.running = true;
                        }
                        onSettingsClicked: {}
                    }

                    ListView {
                        id: networkList
                        width: parent.width
                        height: Math.min(200, contentHeight)
                        clip: true
                        spacing: Theme.smallSpacing
                        visible: popup.wifiEnabled && popup.networks.length > 0

                        model: popup.networks

                        delegate: Rectangle {
                            width: networkList.width
                            height: 40
                            color: networkMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
                            radius: Theme.smallRadius

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.padding
                                anchors.rightMargin: Theme.padding
                                spacing: Theme.spacing

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: NetworkUtils.getSignalIcon(modelData.signal)
                                    color: modelData.active ? Theme.accentColor : Theme.textColor
                                    font.pixelSize: Theme.fontSize + 2
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - parent.children[0].width - parent.children[2].width - parent.children[3].width - parent.spacing * 3
                                    text: modelData.ssid
                                    color: modelData.active ? Theme.accentColor : Theme.textColor
                                    font.pixelSize: Theme.fontSize
                                    elide: Text.ElideRight
                                    font.weight: modelData.active ? Font.Bold : Font.Normal
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.secured ? "󰌾" : ""
                                    color: Theme.textColor
                                    font.pixelSize: Theme.fontSize
                                    opacity: 0.7
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.active ? "󰄴" : ""
                                    color: Theme.accentColor
                                    font.pixelSize: Theme.fontSize
                                }
                            }

                            MouseArea {
                                id: networkMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.surfaceColor
                    opacity: 0.2
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacing

                    NetworkSection {
                        icon: "󰂯"
                        title: "Bluetooth"
                        subtitle: NetworkUtils.getBluetoothStatus(popup.bluetoothAdapter)
                        hasSwitch: true
                        switchChecked: getBluetoothEnabled()
                        switchEnabled: popup.bluetoothAdapter != null
                        onSwitchToggled: {
                            if (popup.bluetoothAdapter) {
                                popup.bluetoothAdapter.enabled = !popup.bluetoothAdapter.enabled;
                            }
                        }
                        onSettingsClicked: {}
                    }

                    ListView {
                        id: bluetoothList
                        width: parent.width
                        height: Math.min(150, contentHeight)
                        clip: true
                        spacing: Theme.smallSpacing
                        visible: popup.bluetoothAdapter && NetworkUtils.getConnectedDevices(popup.bluetoothAdapter).length > 0

                        model: NetworkUtils.getConnectedDevices(popup.bluetoothAdapter)

                        delegate: Rectangle {
                            width: bluetoothList.width
                            height: 40
                            color: "transparent"
                            radius: Theme.smallRadius

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.padding
                                anchors.rightMargin: Theme.padding
                                spacing: Theme.spacing

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "󰂱"
                                    color: Theme.accentColor
                                    font.pixelSize: Theme.fontSize + 2
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - parent.children[0].width - parent.children[2].width - parent.spacing * 2
                                    text: modelData.name
                                    color: Theme.textColor
                                    font.pixelSize: Theme.fontSize
                                    elide: Text.ElideRight
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "󰄴"
                                    color: Theme.accentColor
                                    font.pixelSize: Theme.fontSize
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }
        }
    }

    function getBluetoothEnabled() {
        if (!popup.bluetoothAdapter) {
            return false;
        }
        return popup.bluetoothAdapter.state == BluetoothAdapterState.Enabled;
    }

    Process {
        id: wifiToggleProcess
        command: ["nmcli", "radio", "wifi", popup.wifiEnabled ? "off" : "on"]
        running: false
    }
}
