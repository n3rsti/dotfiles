// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick
import "components/"

Container {
    id: clock_container
    property var padding: 10
    bgColor: root.container_bg
    width: clock.width + padding * 2
    anchors {
        centerIn: parent
    }
    radius: 12
    TextComponent {
        id: clock
        anchors.centerIn: parent
        text: root.time
    }
    Process {
        id: dateProc
        command: ["date", "+%d %b %H:%M"]

        running: true

        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }

    PopupWindow {
        anchor.window: clock_container
        anchor.rect.x: parentWindow.width / 2 - width / 2
        anchor.rect.y: parentWindow.height
        width: 500
        height: 500
        visible: true
    }
}
