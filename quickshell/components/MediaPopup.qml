import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../config"

PopupWindow {
    id: popup

    required property var player
    property alias parentWindow: popup.anchor.window

    width: 350
    height: 180
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
            anchors.fill: parent
            color: Theme.containerBackground
            opacity: 0.95
            radius: Theme.radius

            Row {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.padding

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
                    width: parent.width - albumArt.width - parent.spacing
                    height: parent.height
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

                    Item {
                        width: parent.width
                        height: Theme.smallSpacing
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.smallSpacing

                        Slider {
                            id: positionSlider
                            width: parent.width
                            from: 0
                            to: popup.player?.length || 1
                            value: popup.player?.position || 0
                            enabled: popup.player?.canSeek || false

                            onMoved: {
                                if (popup.player?.canSeek) {
                                    popup.player.position = value;
                                }
                            }

                            background: Rectangle {
                                x: positionSlider.leftPadding
                                y: positionSlider.topPadding + positionSlider.availableHeight / 2 - height / 2
                                width: positionSlider.availableWidth
                                height: 4
                                radius: 2
                                color: Theme.surfaceColor

                                Rectangle {
                                    width: positionSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.accentColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: positionSlider.leftPadding + positionSlider.visualPosition * (positionSlider.availableWidth - width)
                                y: positionSlider.topPadding + positionSlider.availableHeight / 2 - height / 2
                                width: 12
                                height: 12
                                radius: 6
                                color: positionSlider.pressed ? Theme.accentColor : "white"
                                border.color: Theme.surfaceColor
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.smallSpacing

                            Text {
                                text: formatTime(popup.player?.position || 0)
                                color: Theme.textColor
                                font.pixelSize: Theme.fontSize - 2
                                font.family: Theme.fontFamily
                            }

                            Item {
                                width: parent.width - parent.children[0].width - parent.children[2].width - parent.spacing * 2
                                height: 1
                            }

                            Text {
                                text: formatTime(popup.player?.length || 0)
                                color: Theme.textColor
                                font.pixelSize: Theme.fontSize - 2
                                font.family: Theme.fontFamily
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: Theme.smallSpacing
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
    }

    Timer {
        running: popup.visible && popup.player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: {
            if (popup.player) {
                popup.player.positionChanged();
            }
        }
    }

    function formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
