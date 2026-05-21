pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ".."

PopupWindow {
    id: menuPopup

    property var anchorItem: null
    property var menuHandle: null
    property var closeAllMenus: null
    property var iconSourceResolver: null
    property bool rootMenu: false
    property bool requestedVisible: false
    readonly property int menuWidth: 240

    anchor {
        item: menuPopup.anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        margins.top: Style.popupGap
    }

    implicitWidth: menuWidth
    implicitHeight: menuFrame.implicitHeight

    color: "transparent"
    grabFocus: menuPopup.rootMenu
    visible: requestedVisible && menuHandle !== null && anchorItem !== null

    function resolveIcon(icon) {
        if (!icon || icon.length === 0)
            return "";

        return iconSourceResolver ? iconSourceResolver(icon) : icon;
    }

    function createMenuPage(handle, isSubmenu) {
        return submenuComponent.createObject(menuStack, {
            "handle": handle,
            "isSubmenu": isSubmenu
        });
    }

    function resetStack() {
        if (menuStack)
            menuStack.clear();
    }

    function rebuildStack() {
        if (!menuStack)
            return;

        resetStack();

        if (menuHandle) {
            const page = createMenuPage(menuHandle, false);
            if (page)
                menuStack.push(page);
        }
    }

    function openFresh() {
        requestedVisible = false;
        resetStack();

        Qt.callLater(function () {
            if (menuPopup.menuHandle && menuPopup.anchorItem)
                menuPopup.requestedVisible = true;
        });
    }

    function closeFresh() {
        requestedVisible = false;
        resetStack();
    }

    function dismiss() {
        if (closeAllMenus)
            closeAllMenus();
        else
            closeFresh();
    }

    onMenuHandleChanged: {
        if (visible)
            rebuildStack();
    }

    onVisibleChanged: {
        if (visible) {
            rebuildStack();
            keyCatcher.forceActiveFocus();
        } else {
            requestedVisible = false;
            resetStack();
        }
    }

    Item {
        id: keyCatcher

        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: menuPopup.dismiss()
    }

    Rectangle {
        id: menuFrame

        anchors.fill: parent
        implicitWidth: menuPopup.menuWidth
        implicitHeight: menuStack.height + 8

        radius: 12
        color: Style.popupBackground
        border.color: Style.popupBorder
        border.width: Style.borderWidth

        StackView {
            id: menuStack

            x: 4
            y: 4
            width: menuPopup.menuWidth - 8
            height: currentItem ? currentItem.implicitHeight : 0

            pushEnter: Transition {}
            pushExit: Transition {}
            popEnter: Transition {}
            popExit: Transition {}
        }
    }

    Component {
        id: submenuComponent

        Column {
            id: submenu

            required property var handle
            required property bool isSubmenu

            width: menuStack.width
            spacing: 2

            StackView.onRemoved: {
                opener.menu = null;
                destroy();
            }

            QsMenuOpener {
                id: opener
                menu: submenu.handle
            }

            Rectangle {
                id: backRow

                width: submenu.width
                height: submenu.isSubmenu ? 30 : 0
                visible: submenu.isSubmenu
                radius: 8
                color: backMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"

                Text {
                    anchors {
                        left: backRow.left
                        verticalCenter: backRow.verticalCenter
                        leftMargin: 10
                    }

                    text: "‹ Back"
                    color: Style.popupMutedForeground
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: 700
                }

                MouseArea {
                    id: backMouseArea

                    anchors.fill: backRow
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (menuStack.depth > 1)
                            menuStack.pop();
                    }
                }
            }

            Repeater {
                model: opener.children

                Rectangle {
                    id: itemRow

                    required property var modelData

                    readonly property var entry: modelData
                    readonly property bool separator: entry !== null && entry.isSeparator
                    readonly property bool enabledEntry: entry !== null && entry.enabled
                    readonly property bool checkable: entry !== null && entry.buttonType === QsMenuButtonType.CheckBox
                    readonly property bool radio: entry !== null && entry.buttonType === QsMenuButtonType.RadioButton
                    readonly property bool checked: entry !== null && entry.checkState === Qt.Checked
                    readonly property bool hasChildren: entry !== null && entry.hasChildren
                    readonly property bool hasIcon: entry !== null && entry.icon && entry.icon.length > 0

                    width: submenu.width
                    height: separator ? 10 : 28
                    radius: 8
                    color: separator ? "transparent" : rowMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.centerIn: itemRow
                        width: Math.max(0, itemRow.width - 12)
                        height: 1

                        visible: itemRow.separator
                        color: Style.moduleBorder
                        opacity: 0.9
                    }

                    RowLayout {
                        id: rowLayout

                        anchors {
                            fill: itemRow
                            leftMargin: 10
                            rightMargin: 10
                        }

                        visible: !itemRow.separator
                        spacing: 8

                        Item {
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                radius: itemRow.radio ? 7 : 4
                                visible: itemRow.checkable || itemRow.radio
                                color: "transparent"
                                border.color: itemRow.checked ? Style.workspaceFocusedForeground : Style.moduleBorder
                                border.width: 1
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: itemRow.radio ? 4 : 2
                                visible: (itemRow.checkable || itemRow.radio) && itemRow.checked
                                color: Style.workspaceFocusedForeground
                            }
                        }

                        IconImage {
                            Layout.preferredWidth: itemRow.hasIcon ? 16 : 0
                            Layout.preferredHeight: 16
                            Layout.alignment: Qt.AlignVCenter

                            visible: itemRow.hasIcon
                            implicitSize: 16
                            source: itemRow.hasIcon ? menuPopup.resolveIcon(itemRow.entry.icon) : ""
                            asynchronous: true
                            mipmap: true
                            opacity: itemRow.enabledEntry ? 1 : 0.45

                            backer.fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            text: itemRow.entry ? itemRow.entry.text : ""
                            color: itemRow.enabledEntry ? Style.foreground : Style.popupMutedForeground
                            opacity: itemRow.enabledEntry ? 1 : 0.6

                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSize
                            font.weight: Style.fontWeight

                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: itemRow.hasChildren ? 12 : 0
                            Layout.alignment: Qt.AlignVCenter

                            visible: itemRow.hasChildren
                            text: "›"
                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: 14
                            font.weight: 700
                        }
                    }

                    MouseArea {
                        id: rowMouseArea

                        anchors.fill: itemRow
                        enabled: !itemRow.separator && itemRow.enabledEntry
                        hoverEnabled: enabled
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (!itemRow.entry)
                                return;

                            if (itemRow.hasChildren) {
                                const page = menuPopup.createMenuPage(itemRow.entry, true);
                                if (page)
                                    menuStack.push(page);

                                return;
                            }

                            itemRow.entry.triggered();
                            menuPopup.dismiss();
                        }
                    }
                }
            }
        }
    }
}
