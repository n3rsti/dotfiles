pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "./components"
import "./config"

MouseArea {
    id: trayItem

    required property SystemTrayItem modelData
    property bool useNativeMenu: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Theme.iconSize + Theme.smallSpacing * 2
    height: parent.height
    hoverEnabled: true

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (event.button === Qt.RightButton) {
            if (modelData.hasMenu) {
                if (useNativeMenu) {
                    nativeMenuAnchor.menu = modelData.menu;
                    nativeMenuAnchor.open();
                } else {
                    var pos = trayItem.mapToItem(hoverRect.QsWindow.contentItem, 0, 0);
                    trayMenu.anchor.rect.x = pos.x;
                    trayMenu.anchor.rect.y = pos.y + trayItem.height;
                    trayMenu.menuHandle = modelData.menu;
                    trayMenu.visible = true;
                }
            } else {
                modelData.secondaryActivate();
            }
        }
    }

    TrayMenu {
        id: trayMenu
        parentWindow: hoverRect.QsWindow.window
    }

    QsMenuAnchor {
        id: nativeMenuAnchor
        anchor.window: hoverRect.QsWindow.window
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
