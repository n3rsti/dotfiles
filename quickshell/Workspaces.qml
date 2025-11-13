import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Rectangle {
    width: 100
    height: parent.height
    color: "red"

    Row {

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                width: 100
                height: 40
                border.width: 1
                color: "yellow"

                Text {
                    text: modelData.id
                }
            }
        }
    }
}
