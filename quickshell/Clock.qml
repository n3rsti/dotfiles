import Quickshell
import Quickshell.Io
import QtQuick
import "./components/"
import "./config"

Container {
    id: clockContainer

    bgColor: Theme.containerBackground
    width: clockText.width + Theme.padding * 2
    height: parent.height
    clickable: true

    TextComponent {
        id: clockText
        anchors.centerIn: parent
        text: timeString
    }

    property string timeString: ""

    Process {
        id: dateProc
        command: ["date", "+%d %b %H:%M"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: clockContainer.timeString = text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
