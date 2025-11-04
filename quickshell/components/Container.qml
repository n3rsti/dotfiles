import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: rec
    height: parent.height
    width: audio.width + power_btn.width + root.padding
    color: "transparent"
    property var clickHandler

    Rectangle {
        id: bg_rec
        anchors.fill: parent
        color: root.container_bg
        radius: root.radius
        opacity: 0.5
    }

    MouseArea {
        hoverEnabled: true
        enabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (containsMouse) {
                bg_rec.color = root.hover_bg;
            } else {
                bg_rec.color = root.container_bg;
            }
        }

        onClicked: {
            if (parent.clickHandler) {
                rec.clickHandler();
            }
        }
    }
}
