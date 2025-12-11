import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "./components/"
import "./config"

Rectangle {
    id: audioRoot
    color: "transparent"

    property var sink: Pipewire.defaultAudioSink
    property alias audioPopup: audioPopup

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
        onObjectsChanged: {
            sink = Pipewire.defaultAudioSink;
        }
    }

    function getVolumeText() {
        if (!sink?.audio)
            return "󰖁 0%";
        const icon = sink.audio.muted ? "󰖁" : "󰕾";
        const volume = Math.round(sink.audio.volume * 100);
        return `${icon} ${volume}%`;
    }

    TextComponent {
        id: volumeText
        text: audioRoot.getVolumeText()
        anchors.centerIn: parent
    }

    AudioPopup {
        id: audioPopup
        audioSink: audioRoot.sink
        parentWindow: audioRoot.QsWindow?.window
        anchor.rect.x: audioRoot.x
    }

    Connections {
        target: audioRoot.sink?.audio
        function onVolumeChanged() {
            volumeText.text = audioRoot.getVolumeText();
        }
        function onMutedChanged() {
            volumeText.text = audioRoot.getVolumeText();
        }
    }
}
