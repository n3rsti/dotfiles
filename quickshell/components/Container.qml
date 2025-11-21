import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: rec

    height: parent.height
    width: audio.width + power_btn.width + root.padding
    color: "transparent"

    property var clickHandler
    property color bgColor: root.container_bg
    property real bgOpacity: 0.5
    property alias hovered: mouseArea.containsMouse

    Rectangle {
        id: bg_rec
        anchors.fill: parent
        radius: root.radius

        color: rec.hovered ? root.hover_bg : rec.bgColor
        opacity: rec.bgOpacity
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (rec.clickHandler)
                rec.clickHandler();
        }
    }
}
