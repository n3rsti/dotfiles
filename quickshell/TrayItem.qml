pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
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

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (event.button === Qt.RightButton) {
            if (modelData.hasMenu) {
                // Update anchor position before opening
                var pos = trayItem.mapToItem(hoverRect.QsWindow.contentItem, 0, 0);
                menuAnchor.anchor.rect.x = pos.x;
                menuAnchor.anchor.rect.y = pos.y + trayItem.height;
                menuAnchor.menu = modelData.menu;
                menuAnchor.open();
            } else {
                modelData.secondaryActivate();
            }
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        anchor.window: hoverRect.QsWindow.window
        anchor.rect.width: trayItem.width
        anchor.rect.height: 0
    }

    Rectangle {
        id: hoverRect
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
