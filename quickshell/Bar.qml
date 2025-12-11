import QtQuick
import Quickshell
import "./config"

Scope {
    id: barScope

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

            height: Theme.barHeight
            color: "transparent"

            Rectangle {
                width: parent.width
                height: parent.height
                color: Theme.background
                opacity: Theme.backgroundOpacity
            }

            Rectangle {
                id: barContent
                color: "transparent"
                anchors.fill: parent
                anchors.margins: 2

                Left {
                    id: leftSection
                }

                Clock {
                    id: clockSection
                }

                Right {
                    id: rightSection
                }
            }
        }
    }
}
