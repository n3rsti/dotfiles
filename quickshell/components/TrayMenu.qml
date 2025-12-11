pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import "../config"

PopupWindow {
    id: popup

    property var menuHandle: null
    required property var parentWindow
    property var submenu: null
    property var parentMenu: null
    property bool backgroundHovered: false
    property bool itemsHovered: false

    implicitWidth: menuColumn.implicitWidth + Theme.padding * 2
    implicitHeight: menuColumn.implicitHeight + Theme.padding * 2
    visible: false
    color: "transparent"

    anchor {
        window: popup.parentWindow
        rect.y: popup.parentWindow?.contentItem?.height || 0
    }

    QsMenuOpener {
        id: menuOpener
        menu: popup.menuHandle
    }

    onVisibleChanged: {
        if (!visible && submenu) {
            submenu.visible = false;
        }
    }

    Timer {
        id: closeTimer
        interval: 500
        repeat: false
        onTriggered: {
            var thisMenuHovered = popup.backgroundHovered || popup.itemsHovered;
            var submenuBackgroundHovered = popup.submenu && popup.submenu.backgroundHovered;
            var submenuItemsHovered = popup.submenu && popup.submenu.itemsHovered;
            var submenuHovered = submenuBackgroundHovered || submenuItemsHovered;

            if (!thisMenuHovered && !submenuHovered) {
                popup.visible = false;
                if (popup.submenu) {
                    popup.submenu.visible = false;
                }
                if (popup.parentMenu) {
                    popup.parentMenu.visible = false;
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.containerBackground
        radius: Theme.radius
        border.color: Theme.surfaceColor
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                popup.backgroundHovered = true;
                closeTimer.stop();
                if (popup.parentMenu) {
                    popup.parentMenu.closeTimer.stop();
                }
            }
            onExited: {
                popup.backgroundHovered = false;
                closeTimer.start();
                if (popup.parentMenu) {
                    popup.parentMenu.closeTimer.start();
                }
            }
        }

        ColumnLayout {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.smallSpacing

            Repeater {
                model: menuOpener.children

                Item {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitWidth: menuItemContent.implicitWidth
                    height: modelData.isSeparator ? 2 : 30

                    Rectangle {
                        visible: parent.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width
                        height: 1
                        color: Theme.surfaceColor
                    }

                    Rectangle {
                        id: menuItemContent
                        visible: !parent.modelData.isSeparator
                        anchors.fill: parent
                        color: menuItemMouse.containsMouse ? Theme.hoverBackground : "transparent"
                        radius: Theme.smallRadius
                        implicitWidth: itemRow.implicitWidth + Theme.smallSpacing * 4

                        Row {
                            id: itemRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.smallSpacing * 2
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.smallSpacing * 2
                            spacing: Theme.spacing

                            Image {
                                visible: source !== ""
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                source: parent.parent.parent.modelData.icon || ""
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.parent.parent.modelData.text || ""
                                color: parent.parent.parent.modelData.enabled ? "#c0caf5" : "#6e738d"
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                            }

                            Item {
                                width: 20
                                height: parent.height
                            }

                            Text {
                                visible: parent.parent.parent.modelData.hasChildren
                                anchors.verticalCenter: parent.verticalCenter
                                text: "›"
                                color: "#c0caf5"
                                font.pixelSize: 14
                            }
                        }

                        MouseArea {
                            id: menuItemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                popup.itemsHovered = true;
                                closeTimer.stop();
                                if (popup.parentMenu) {
                                    popup.parentMenu.closeTimer.stop();
                                }
                                var item = parent.parent.modelData;
                                if (item.hasChildren) {
                                    openSubmenu(item, parent.parent);
                                } else if (popup.submenu) {
                                    popup.submenu.visible = false;
                                }
                            }

                            onExited: {
                                popup.itemsHovered = false;
                                closeTimer.start();
                                if (popup.parentMenu) {
                                    popup.parentMenu.closeTimer.start();
                                }
                            }

                            onClicked: {
                                var item = parent.parent.modelData;
                                if (item.enabled) {
                                    if (item.hasChildren) {
                                        if (popup.submenu && popup.submenu.visible) {
                                            popup.submenu.visible = false;
                                        } else {
                                            openSubmenu(item, parent.parent);
                                        }
                                    } else {
                                        item.triggered();
                                        closeTimer.stop();
                                        popup.visible = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function openSubmenu(item, itemRect) {
        if (!item.hasChildren)
            return;

        if (popup.submenu) {
            popup.submenu.visible = false;
            popup.submenu.destroy();
        }

        var component = Qt.createComponent("TrayMenu.qml");
        if (component.status === Component.Ready) {
            var props = {
                "parentWindow": popup.parentWindow,
                "menuHandle": item,
                "parentMenu": popup
            };
            popup.submenu = component.createObject(null, props);

            if (popup.submenu) {
                var itemPos = itemRect.mapToItem(popup.parentWindow.contentItem, 0, 0);
                popup.submenu.anchor.rect.x = popup.anchor.rect.x + popup.width;
                popup.submenu.anchor.rect.y = itemPos.y;
                popup.submenu.visible = true;
            }
        }
    }
}
