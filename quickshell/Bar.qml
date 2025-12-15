import QtQuick
import Quickshell
import "./components/"
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
                anchors.margins: 4

                Left {
                    id: leftSection
                }

                Row {
                    id: centerSection
                    height: parent.height
                    spacing: Theme.spacing
                    anchors.centerIn: parent

                    Container {
                        id: mediaContainer
                        height: parent.height
                        width: media.implicitWidth + Theme.padding * 2
                        bgColor: Theme.containerBackground
                        clickable: true
                        visible: media.player !== null

                        clickHandler: function () {
                            media.mediaPopup.visible = !media.mediaPopup.visible;
                        }

                        Media {
                            id: media
                            height: parent.height
                            anchors.centerIn: parent
                        }
                    }

                    Clock {
                        id: clockSection
                    }
                }

                Right {
                    id: rightSection
                }
            }
        }
    }
}
