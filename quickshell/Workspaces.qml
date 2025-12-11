import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./components/"
import "./config"

Container {
    id: workspacesContainer

    width: workspaceRow.implicitWidth + Theme.padding
    height: parent.height
    clickable: false

    Row {
        id: workspaceRow
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Repeater {
            model: Hyprland.workspaces

            Container {
                id: workspaceButton
                width: Theme.workspaceButtonWidth
                height: parent.height
                bgColor: modelData.focused ? Theme.focusBackground : "transparent"
                bgOpacity: Theme.fullOpacity
                clickable: true

                clickHandler: function() {
                    modelData.activate(modelData.id)
                }

                TextComponent {
                    text: modelData.id
                    anchors.centerIn: parent
                    active: modelData.focused || workspaceButton.hovered
                    activeColor: Theme.textColor
                }
            }
        }
    }
}
