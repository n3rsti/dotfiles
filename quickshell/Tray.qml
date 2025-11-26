import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.Widgets
import QtQuick.Controls
import "./components/"

Container {
    width: row.implicitWidth + 10
    height: parent.height

    Row {
        id: row
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: items

            model: SystemTray.items

            TrayItem {}
        }
    }
}
