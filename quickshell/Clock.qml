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

    clickHandler: function () {
        clockPopup.visible = !clockPopup.visible;
    }

    anchors {
        centerIn: parent
    }

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

    PopupWindow {
        id: clockPopup
        visible: false
        width: 300
        height: 200
        color: "transparent"

        anchor {
            window: clockContainer.QsWindow?.window
            rect.y: clockContainer.height
            rect.x: clockContainer.x
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.containerBackground
            radius: Theme.smallRadius
        }
    }
}
