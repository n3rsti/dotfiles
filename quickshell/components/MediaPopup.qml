import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../config"

PopupWindow {
    id: popup

    required property var player
    property alias parentWindow: popup.anchor.window
    property bool sliderEnabled: true

    width: 380
    height: 220
    visible: false
    color: "transparent"

    anchor {
        rect.y: anchor.window?.contentItem?.height || 0
        rect.x: (anchor.window?.contentItem?.width || 0) / 2 - width / 2
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            if (!containsMouse) {
                closeTimer.start();
            }
        }
        onEntered: closeTimer.stop()

        Timer {
            id: closeTimer
            interval: 500
            onTriggered: popup.visible = false
        }

        Rectangle {
            id: rec
            anchors.fill: parent
            color: Theme.containerBackground
            opacity: 1
            radius: Theme.radius
            border.color: Theme.surfaceColor
            border.width: 1

            Column {
                anchors.centerIn: parent
                width: parent.width - Theme.padding * 4
                spacing: Theme.spacing * 2

                Row {
                    width: parent.width
                    spacing: Theme.padding * 1.5

                    Rectangle {
                        width: 100
                        height: 100
                        color: Theme.surfaceColor
                        radius: Theme.smallRadius
                        clip: true

                        Image {
                            id: albumArt
                            anchors.fill: parent
                            source: popup.player?.trackArtUrl || ""
                            fillMode: Image.PreserveAspectCrop
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰎈"
                            color: Theme.textColor
                            font.pixelSize: 40
                            visible: albumArt.status !== Image.Ready
                        }
                    }

                    Column {
                        width: parent.width - 100 - parent.spacing
                        spacing: Theme.smallSpacing

                        Text {
                            width: parent.width
                            text: popup.player?.trackArtist || "Unknown Artist"
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: popup.player?.trackTitle || "Unknown Title"
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                        }
                    }
                }

                Column {
                    width: parent.width * 0.95
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.smallSpacing
                    height: popup.sliderEnabled ? implicitHeight : 0

                    Row {
                        width: parent.width
                        spacing: Theme.smallSpacing * 2

                        Text {
                            text: formatTime(popup.player.position)
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSize - 2
                            font.family: Theme.fontFamily
                        }

                        Slider {
                            id: slider
                            width: parent.width - parent.children[0].width - parent.children[2].width - parent.spacing * 2
                            from: 0
                            value: popup.player.position
                            to: popup.player.length

                            onPressedChanged: {
                                if (!pressed) {
                                    popup.player.seek(value - popup.player.position);
                                }
                            }
                        }

                        Text {
                            text: formatTime(popup.player.length)
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSize - 2
                            font.family: Theme.fontFamily
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacing

                    Rectangle {
                        width: 35
                        height: 35
                        color: prevMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
                        radius: Theme.smallRadius

                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: Theme.textColor
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: prevMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: popup.player?.canGoPrevious || false
                            onClicked: {
                                if (popup.player?.canGoPrevious) {
                                    popup.player.previous();
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 35
                        height: 35
                        color: playMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
                        radius: Theme.smallRadius

                        Text {
                            anchors.centerIn: parent
                            text: popup.player?.isPlaying ? "󰏤" : "󰐊"
                            color: Theme.textColor
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: playMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: popup.player?.canTogglePlaying || false
                            onClicked: {
                                if (popup.player?.canTogglePlaying) {
                                    popup.player.togglePlaying();
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 35
                        height: 35
                        color: nextMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
                        radius: Theme.smallRadius

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: Theme.textColor
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: nextMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: popup.player?.canGoNext || false
                            onClicked: {
                                if (popup.player?.canGoNext) {
                                    popup.player.next();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
