// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string time
    property string bg: "#191b26"
    property string focus_bg: "#1b1b23"
    property string container_bg: "#000008"
    property string hover_bg: "#11111b"
    property string text_color: "#c0caf5"
    property int radius: 12
    property int padding: 10

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            color: "transparent"

            Rectangle {
                width: parent.width
                height: parent.height
                color: root.bg
                opacity: 0.5
            }

            Rectangle {
                id: root_item
                color: "transparent"
                anchors.centerIn: parent
                width: parent.width
                height: parent.height - 4

                Left {}

                Clock {}

                Right {}
            }

            height: 40
        }
    }
}
