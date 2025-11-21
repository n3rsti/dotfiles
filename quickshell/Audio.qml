import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import "components/"

Rectangle {
    id: audio_root
    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
        onObjectsChanged: {
            sink = Pipewire.defaultAudioSink;
            if (sink?.audio) {
                sink.audio.volumeChanged.connect(updateVolume);
            }
        }
    }

    function updateVolume() {
        if (sink?.audio) {
            const icon = sink.audio.muted ? "󰖁" : "󰕾";
            content.symbolText = `${icon} ${Math.round(sink.audio.volume * 100)}%`;
        }
    }

    TextComponent {
        text: `${sink?.audio?.muted ? "󰖁" : "󰕾"}  ${Math.round(sink?.audio?.volume * 100)}%`
        anchors.centerIn: parent
    }

    Process {
        id: pavucontrol
        command: ["pavucontrol"]
        running: false
    }

    PopupWindow {
        id: menuWindow
        width: 200
        height: 150
        visible: false
        color: "transparent"

        anchor {
            window: audio_root.QsWindow?.window
            rect.y: audio_root.height
            rect.x: audio_root.x
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            // onExited: {
            //     if (!containsMouse) {
            //         closeTimer.start();
            //     }
            // }
            // onEntered: closeTimer.stop()

            onPressed: {
                menuWindow.visible = false;
            }

            Timer {
                id: closeTimer
                interval: 500
                onTriggered: menuWindow.visible = false
            }

            Rectangle {
                anchors.fill: parent
                anchors.top: parent.bottom
                color: root.container_bg
                radius: 4

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Volume Slider
                    Rectangle {
                        width: parent.width
                        height: 35
                        color: "transparent"

                        Slider {
                            id: volumeSlider
                            anchors.fill: parent
                            from: 0
                            to: 1
                            value: sink?.audio?.volume || 0
                            onValueChanged: {
                                if (sink?.audio) {
                                    sink.audio.volume = value;
                                }
                            }

                            background: Rectangle {
                                x: volumeSlider.leftPadding
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                width: volumeSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#3c3c3c"

                                Rectangle {
                                    width: volumeSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#4a9eff"
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                width: 16
                                height: 16
                                radius: 8
                                color: volumeSlider.pressed ? "#4a9eff" : "#ffffff"
                                border.color: "#3c3c3c"
                            }
                        }
                    }

                    Repeater {
                        model: [
                            {
                                text: sink?.audio?.muted ? "Unmute" : "Mute",
                                action: () => sink?.audio && (sink.audio.muted = !sink.audio.muted)
                            },
                            {
                                text: "Pavucontrol",
                                action: () => {
                                    pavucontrol.running = true;
                                    menuWindow.visible = false;
                                }
                            }
                        ]

                        Rectangle {
                            width: parent.width
                            height: 35
                            color: mouseArea.containsMouse ? "#3c3c3c" : "transparent"
                            radius: 4

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                text: modelData.text
                                color: "white"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    modelData.action();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function toggleMenu() {
        if (audio_root.QsWindow?.window?.contentItem) {
            menuWindow.visible = !menuWindow.visible;
        }
    }
}
