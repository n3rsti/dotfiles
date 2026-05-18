import QtQuick
import QtQml
import Quickshell
import ".."
import "../common"

ModuleBox {
    id: clockModule

    required property var clock

    BarText {
        hovered: clockModule.hovered

        text: Qt.formatDateTime(clock.date, Style.clockFormat)
    }
}
