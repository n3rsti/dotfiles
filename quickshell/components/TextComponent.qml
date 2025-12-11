import QtQuick
import "../config"

Text {
    id: textComponent

    property bool active: false
    property color activeColor: Theme.textColor
    property color inactiveColor: Theme.textColor

    color: active ? activeColor : inactiveColor
    font.pixelSize: Theme.fontSize
    font.family: Theme.fontFamily
    font.weight: Theme.fontWeight
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
