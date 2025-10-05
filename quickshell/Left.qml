import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: left
    height: parent.height

    Workspaces {
        id: workspaces
        height: parent.height
        color: "red"
        radius: root.radius
        width: 60
        anchors {
            left: parent.left
            leftMargin: root.padding
            verticalCenter: parent.verticalCenter
        }
        // height: 60
    }
}
