import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "./components/"
import "./config"
import "./components/"

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: networkingRow.implicitWidth + Theme.padding * 3
    implicitHeight: parent.height

    property var adapter: Bluetooth.defaultAdapter

    property string connectionType: "none"
    property bool wifiEnabled: false
    property bool wifiConnected: false
    property int signalStrength: 0
    property string activeSSID: ""
    property var availableNetworks: []

    Row {
        id: networkingRow
        spacing: Theme.padding * 2
        anchors.centerIn: parent

        TextComponent {
            id: bluetoothText
            anchors.verticalCenter: parent.verticalCenter
        }

        TextComponent {
            id: networkText
            text: getNetworkIcon()
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Component.onCompleted: {
        console.log("Bluetooth adapters:", Bluetooth.adapters.values);
        console.log("Default adapter:", Bluetooth.defaultAdapter.state);
        updateNetworkStatus();
    }

    function getNetworkIcon() {
        if (connectionType === "ethernet") {
            return "󰈀";
        } else {
            return NetworkUtils.getWifiIcon(connectionType, signalStrength, wifiEnabled);
        }
    }

    function updateBluetoothIcon() {
        bluetoothText.text = NetworkUtils.getBluetoothIcon(root.adapter);
    }

    function updateNetworkStatus() {
        networkStatusProc.running = true;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.adapter = Bluetooth.defaultAdapter;
            updateBluetoothIcon();
            updateNetworkStatus();
        }
    }

    Process {
        id: networkStatusProc
        running: false
        command: ["nmcli", "-t", "-f", "TYPE,STATE,DEVICE,CONNECTION", "device"]

        stdout: StdioCollector {
            onStreamFinished: {
                let ethernetConnected = false;
                let wifiConnectedLocal = false;

                const lines = text.trim().split("\n");
                for (let line of lines) {
                    const parts = line.split(":");
                    if (parts.length < 2)
                        continue;

                    const type = parts[0];
                    const state = parts[1];

                    if (state === "connected") {
                        if (type === "ethernet") {
                            ethernetConnected = true;
                            root.connectionType = "ethernet";
                            break;
                        } else if (type === "wifi") {
                            wifiConnectedLocal = true;
                        }
                    }
                }

                if (!ethernetConnected) {
                    if (wifiConnectedLocal) {
                        root.connectionType = "wifi";
                        root.wifiConnected = true;
                        wifiDetailsProc.running = true;
                    } else {
                        root.connectionType = "none";
                        root.wifiConnected = false;
                        root.signalStrength = 0;
                        root.activeSSID = "";
                    }
                } else {
                    root.wifiConnected = false;
                    root.signalStrength = 0;
                    root.activeSSID = "";
                }

                wifiRadioProc.running = true;
                wifiListProc.running = true;
            }
        }
    }

    Process {
        id: wifiRadioProc
        running: false
        command: ["nmcli", "radio", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: wifiDetailsProc
        running: false
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (let line of lines) {
                    const parts = line.split(":");
                    if (parts.length < 3)
                        continue;

                    const active = parts[0];
                    const ssid = parts[1];
                    const signal = parseInt(parts[2]) || 0;

                    if (active === "yes") {
                        root.signalStrength = signal;
                        root.activeSSID = ssid;
                        break;
                    }
                }
            }
        }
    }

    Process {
        id: wifiListProc
        running: false
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY,BARS", "device", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                let networks = [];
                const lines = text.trim().split("\n");

                for (let line of lines) {
                    const parts = line.split(":");
                    if (parts.length < 4)
                        continue;

                    const active = parts[0] === "yes";
                    const ssid = parts[1];
                    const signal = parseInt(parts[2]) || 0;
                    const security = parts[3];
                    const bars = parts.length > 4 ? parts[4] : "";

                    if (!ssid)
                        continue;

                    networks.push({
                        active: active,
                        ssid: ssid,
                        signal: signal,
                        security: security,
                        bars: bars,
                        secured: security !== "" && security !== "--"
                    });
                }

                networks.sort((a, b) => b.signal - a.signal);

                root.availableNetworks = networks;
            }
        }
    }
}
