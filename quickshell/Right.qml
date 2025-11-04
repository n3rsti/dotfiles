import Quickshell
import Quickshell.Io
import QtQuick
import "components/"

Container {
    id: utils
    height: parent.height
    width: audio.width + power_btn.width + root.padding
    clickHandler: function () {}

    anchors {
        right: parent.right
        rightMargin: root.padding
        verticalCenter: parent.verticalCenter
    }

    Audio {
        id: audio
        height: parent.height
        color: "transparent"
        width: 60
        anchors {
            right: power_btn.left
        }
    }

    TextComponent {
        id: power_btn
        text: "⏻"
        width: 10
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: root.padding
        }
    }
}
