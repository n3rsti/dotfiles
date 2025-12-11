import QtQuick
import Quickshell.Services.SystemTray
import "./components/"
import "./config"

Container {
    id: trayContainer

    width: trayRow.implicitWidth + Theme.padding
    height: parent.height
    clickable: false

    Row {
        id: trayRow
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.smallSpacing

        Repeater {
            model: SystemTray.items
            TrayItem {}
        }
    }
}
