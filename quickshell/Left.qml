import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: left
    height: parent.height
    color: "transparent"
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: root.padding
    }

    Workspaces {
        id: workspaces
    }
    Tray {
        anchors {
            left: workspaces.right
            leftMargin: 10
        }
    }
}
