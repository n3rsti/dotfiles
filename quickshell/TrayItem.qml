pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "./config"

MouseArea {
    id: trayItem

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Theme.iconSize + Theme.smallSpacing * 2
    height: parent.height
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else {
            modelData.secondaryActivate();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.hoverBackground
        opacity: parent.containsMouse ? 0.3 : 0
        radius: Theme.smallRadius

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    IconImage {
        source: trayItem.modelData.icon
        width: Theme.iconSize
        height: Theme.iconSize
        anchors.centerIn: parent
    }
}
