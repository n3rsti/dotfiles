pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Hyprland
import ".."
import "../common"

ModuleBox {
    id: workspacesModule

    required property var shellScreen

    readonly property var currentMonitor: Hyprland.monitorFor(shellScreen)
    readonly property var visibleWorkspaces: filteredWorkspaces()

    paddingX: Style.workspaceModulePaddingX
    contentSpacing: Style.workspaceButtonGap
    visible: visibleWorkspaces.length > 0

    function filteredWorkspaces() {
        const values = Hyprland.workspaces.values || [];
        let result = [];

        for (let i = 0; i < values.length; i++) {
            const workspace = values[i];

            if (!workspace)
                continue;

            if (!Style.workspaceShowNamed && workspace.id < 0)
                continue;

            if (!Style.workspacesAllOutputs && currentMonitor !== null && workspace.monitor !== currentMonitor) {
                continue;
            }

            result.push(workspace);
        }

        result.sort((a, b) => a.id - b.id);
        return result;
    }

    Repeater {
        model: workspacesModule.visibleWorkspaces

        WorkspaceButton {
            required property var modelData
            workspace: modelData
        }
    }

    component WorkspaceButton: Item {
        id: workspaceButton

        required property var workspace

        readonly property bool focused: workspace !== null && Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === workspace.id

        readonly property bool urgent: workspace !== null && workspace.urgent

        width: Math.max(Style.workspaceButtonMinWidth, workspaceLabel.implicitWidth + Style.workspaceButtonPaddingX * 2)
        height: Style.workspaceButtonHeight

        function labelText() {
            if (!workspace)
                return "";

            if (Style.workspaceUseNames && workspace.name && workspace.name.length > 0)
                return workspace.name.replace("special:", "");

            return workspace.id;
        }

        Rectangle {
            anchors.fill: parent
            radius: Style.moduleRadius
            color: workspaceButton.focused ? Style.workspaceFocusedBackground : Style.moduleHoverOverlay
            opacity: workspaceButton.focused || mouseArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }

        BarText {
            id: workspaceLabel

            anchors.fill: parent

            text: workspaceButton.labelText()

            textPixelSize: Style.workspaceFontSize
            textHorizontalAlignment: Text.AlignHCenter

            normalColor: workspaceButton.urgent ? Style.workspaceUrgentForeground : workspaceButton.focused ? Style.workspaceFocusedForeground : Style.workspaceOccupiedForeground

            hoverColor: normalColor

            textWeight: workspaceButton.focused ? Style.workspaceFocusedFontWeight : Style.fontWeight
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton

            onClicked: {
                if (workspace)
                    workspace.activate();
            }
        }
    }
}
