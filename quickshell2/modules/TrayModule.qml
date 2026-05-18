pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."
import "../common"

ModuleBox {
    id: trayModule

    paddingX: Style.trayPaddingX
    contentSpacing: Style.trayIconGap

    Repeater {
        model: SystemTray.items ? SystemTray.items.values : []

        TrayIconButton {
            required property var modelData
            trayItem: modelData
        }
    }

    component TrayIconButton: Item {
        id: trayButton

        required property var trayItem

        width: Style.trayIconButtonSize
        height: Style.moduleHeight

        function iconSource(icon) {
            if (!icon)
                return "";

            if (icon.includes("?path=")) {
                const parts = icon.split("?path=");
                const name = parts[0];
                const path = parts[1];
                const fileName = name.substring(name.lastIndexOf("/") + 1);
                return "file://" + path + "/" + fileName;
            }

            return icon;
        }

        function openMenu() {
            if (trayItem && trayItem.hasMenu && trayItem.menu) {
                menuAnchor.open();
                return true;
            }

            return false;
        }

        QsMenuAnchor {
            id: menuAnchor

            menu: trayItem ? trayItem.menu : null

            anchor {
                item: trayButton
                edges: Edges.Bottom | Edges.Left
                gravity: Edges.Bottom | Edges.Right
            }
        }

        IconImage {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: Style.trayIconYOffset

            width: Style.trayIconSize
            height: Style.trayIconSize
            implicitSize: Style.trayIconSize

            asynchronous: true
            mipmap: true
            source: trayButton.iconSource(trayItem ? trayItem.icon : "")

            backer.fillMode: Image.PreserveAspectFit
            opacity: status === Image.Ready ? 1 : 0.65
        }

        Rectangle {
            anchors.fill: parent
            radius: Style.moduleRadius
            color: Style.moduleHoverOverlay
            opacity: mouseArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: function (mouse) {
                if (!trayItem)
                    return;

                if (mouse.button === Qt.LeftButton) {
                    if (trayItem.onlyMenu) {
                        trayButton.openMenu();
                    } else {
                        trayItem.activate();
                    }
                } else if (mouse.button === Qt.RightButton) {
                    trayButton.openMenu();
                } else if (mouse.button === Qt.MiddleButton) {
                    trayItem.secondaryActivate();
                }
            }
        }
    }
}
