import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../config"

PopupWindow {
    id: popup

    required property var audioSink
    property alias parentWindow: popup.anchor.window

    width: 200
    height: 150
    visible: false
    color: "transparent"

    anchor {
        rect.y: anchor.window?.contentItem?.height || 0
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

        onPressed: popup.visible = false

        Timer {
            id: closeTimer
            interval: 500
            onTriggered: popup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.containerBackground
            radius: Theme.smallRadius

            Column {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.spacing

                Rectangle {
                    width: parent.width
                    height: 35
                    color: "transparent"

                    Slider {
                        id: volumeSlider
                        anchors.fill: parent
                        from: 0
                        to: 1
                        value: popup.audioSink?.audio?.volume || 0
                        onValueChanged: {
                            if (popup.audioSink?.audio) {
                                popup.audioSink.audio.volume = value;
                            }
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: volumeSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.surfaceColor

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accentColor
                                radius: 2
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: volumeSlider.pressed ? Theme.accentColor : "white"
                            border.color: Theme.surfaceColor
                        }
                    }
                }

                Repeater {
                    model: [
                        {
                            text: popup.audioSink?.audio?.muted ? "Unmute" : "Mute",
                            action: () => {
                                if (popup.audioSink?.audio) {
                                    popup.audioSink.audio.muted = !popup.audioSink.audio.muted;
                                }
                            }
                        },
                        {
                            text: "Pavucontrol",
                            action: () => {
                                pavucontrolProcess.running = true;
                                popup.visible = false;
                            }
                        }
                    ]

                    Rectangle {
                        width: parent.width
                        height: 35
                        color: itemMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
                        radius: Theme.smallRadius

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.padding
                            text: modelData.text
                            color: Theme.textColor
                            font.pixelSize: Theme.fontSize
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: modelData.action()
                        }
                    }
                }
            }
        }
    }

    Process {
        id: pavucontrolProcess
        command: ["pavucontrol"]
        running: false
    }
}
