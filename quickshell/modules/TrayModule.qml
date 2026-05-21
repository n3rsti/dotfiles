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

    function directIconSource(icon) {
        if (!icon || icon.length === 0)
            return "";

        if (icon.includes("?path=")) {
            const parts = icon.split("?path=");
            const name = parts[0];
            const path = parts[1];
            const fileName = name.substring(name.lastIndexOf("/") + 1);
            return "file://" + path + "/" + fileName;
        }

        if (icon.startsWith("image://") || icon.startsWith("file://"))
            return icon;

        if (icon.startsWith("/"))
            return "file://" + icon;

        return Quickshell.iconPath(icon, true);
    }

    Repeater {
        model: SystemTray.items

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

        function rootMenuHandle() {
            if (!trayItem || !trayItem.hasMenu || !trayItem.menu)
                return null;

            return trayItem.menu;
        }

        function openMenu() {
            if (!trayItem || !trayItem.hasMenu || !rootMenuHandle())
                return false;

            rootMenuPopup.openFresh();
            return true;
        }

        function closeMenu() {
            rootMenuPopup.closeFresh();
        }

        IconImage {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: Style.trayIconYOffset

            width: Style.trayIconSize
            height: Style.trayIconSize
            implicitSize: Style.trayIconSize

            asynchronous: true
            mipmap: true
            source: trayModule.directIconSource(trayItem ? trayItem.icon : "")

            backer.fillMode: Image.PreserveAspectFit
            opacity: status === Image.Ready ? 1 : 0.65
        }

        Rectangle {
            anchors.fill: parent
            radius: Style.moduleRadius
            color: Style.moduleHoverOverlay
            opacity: mouseArea.containsMouse || rootMenuPopup.visible ? 1 : 0

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
                    if (trayItem.onlyMenu)
                        trayButton.openMenu();
                    else
                        trayItem.activate();
                } else if (mouse.button === Qt.RightButton) {
                    trayButton.openMenu();
                } else if (mouse.button === Qt.MiddleButton) {
                    trayItem.secondaryActivate();
                }
            }
        }

        TrayMenuPopup {
            id: rootMenuPopup

            anchorItem: trayButton
            menuHandle: trayButton.rootMenuHandle()
            closeAllMenus: function () {
                trayButton.closeMenu();
            }
            iconSourceResolver: trayModule.directIconSource
            rootMenu: true
        }
    }
}
