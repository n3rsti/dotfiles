pragma Singleton
import QtQuick
import Quickshell.Bluetooth

QtObject {
    function getWifiIcon(connectionType, signalStrength, wifiEnabled) {
        if (connectionType === "wifi") {
            if (signalStrength >= 80) {
                return "󰤨";
            } else if (signalStrength >= 60) {
                return "󰤥";
            } else if (signalStrength >= 40) {
                return "󰤢";
            } else if (signalStrength >= 20) {
                return "󰤟";
            } else {
                return "󰤯";
            }
        } else if (wifiEnabled) {
            return "󰤯";
        } else {
            return "󰤮";
        }
    }

    function getSignalIcon(signal) {
        if (signal >= 80) {
            return "󰤨";
        } else if (signal >= 60) {
            return "󰤥";
        } else if (signal >= 40) {
            return "󰤢";
        } else if (signal >= 20) {
            return "󰤟";
        } else {
            return "󰤯";
        }
    }

    function getBluetoothIcon(adapter) {
        if (!adapter) {
            return "󰂲";
        }
        if (isBluetoothConnected(adapter)) {
            return "";
        } else if (adapter.state == BluetoothAdapterState.Enabled) {
            return "󰂯";
        } else {
            return "󰂲";
        }
    }

    function isBluetoothConnected(adapter) {
        if (!adapter) {
            return false;
        }
        for (let device of adapter.devices.values) {
            if (device.connected) {
                return true;
            }
        }
        return false;
    }

    function getConnectedDevices(adapter) {
        let devices = [];
        if (!adapter) {
            return devices;
        }
        for (let device of adapter.devices.values) {
            if (device.connected) {
                devices.push({
                    name: device.name || "Unknown Device",
                    address: device.address
                });
            }
        }
        return devices;
    }

    function getBluetoothStatus(adapter) {
        if (!adapter) {
            return "Not available";
        }
        const connectedCount = getConnectedDevices(adapter).length;
        if (connectedCount > 0) {
            return connectedCount + " device" + (connectedCount > 1 ? "s" : "") + " connected";
        } else if (adapter.state == BluetoothAdapterState.Enabled) {
            return "On";
        } else {
            return "Off";
        }
    }

    function getWifiStatus(connectionType, activeSSID, signalStrength, wifiEnabled) {
        if (connectionType === "wifi") {
            return activeSSID + " • " + signalStrength + "%";
        } else if (wifiEnabled) {
            return "Not connected";
        } else {
            return "Off";
        }
    }
}
