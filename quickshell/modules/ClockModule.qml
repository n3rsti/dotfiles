import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import ".."
import "../common"

ModuleBox {
    id: clockModule

    required property var clock

    clickable: true

    onClicked: calendarProcess.startDetached()

    Process {
        id: calendarProcess
        command: [ "gnome-calendar" ]
    }

    BarText {
        hovered: clockModule.hovered

        text: Qt.formatDateTime(clock.date, Style.clockFormat)
    }
}
