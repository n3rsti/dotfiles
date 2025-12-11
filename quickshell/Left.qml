import QtQuick
import "./config"

Rectangle {
    id: leftSection
    height: parent.height
    width: workspaces.width + tray.width + Theme.spacing
    color: "transparent"

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: Theme.padding
    }

    Row {
        height: parent.height
        spacing: Theme.spacing

        Workspaces {
            id: workspaces
        }

        Tray {
            id: tray
        }
    }
}
