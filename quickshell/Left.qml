import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: left
    height: parent.height
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
    }

    Workspaces {}
}
