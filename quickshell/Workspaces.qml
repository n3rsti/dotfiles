import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import "./components/"

Container {
    width: row.implicitWidth + 10
    height: parent.height

    Row {
        id: row
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: Hyprland.workspaces

            Container {
                id: container
                width: 40
                height: parent.height
                bgColor: modelData.focused ? root.focus_bg : "transparent"
                bgOpacity: 1
                clickHandler: function () {
                    modelData.activate(modelData.id);
                }

                TextComponent {
                    text: modelData.id
                    anchors.centerIn: parent
                    activeColor: "#cdd6f4"
                    active: modelData.focused || container.hovered
                }
            }
        }
    }
}
