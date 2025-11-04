// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string time
    property string bg: "#191b26"
    property string container_bg: "#000008"
    property string hover_bg: "#111111"
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

            Clock {
                color: root.container_bg
            }

            Rectangle {
                id: utils
                height: parent.height
                width: audio.width + power_btn.width + root.padding
                radius: root.radius
                color: a.containsMouse ? root.hover_bg : root.container_bg

                anchors {
                    right: parent.right
                    rightMargin: root.padding
                    verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    id: a
                    hoverEnabled: true
                    enabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }

                Audio {
                    id: audio
                    height: parent.height
                    color: "transparent"
                    width: 60
                    anchors {
                        right: power_btn.left
                    }
                }

                Text {
                    id: power_btn
                    text: "⏻"
                    color: "#fff"
                    width: 10
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: root.padding
                    }
                }
            }
        }
    }
}
