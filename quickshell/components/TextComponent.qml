import Quickshell
import Quickshell.Io
import QtQuick

Text {
    color: active ? this.activeColor : this.textColor
    font.pixelSize: 12
    font.family: "Adwaita Sans"
    font.weight: 500
    property var textColor: root.text_color
    property var active: false
    property var activeColor: color
}
