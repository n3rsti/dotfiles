// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string time
    property string bg: "#191b2600"
    property string container_bg: "#000008"
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

            color: root.bg
            height: 45

            Left {
                color: "red"
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }

            Clock {
                color: root.container_bg
            }
        }
    }
}
