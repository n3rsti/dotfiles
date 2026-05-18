import QtQuick
import ".."

Text {
    id: root

    property bool hovered: false
    property bool icon: false
    property int textPixelSize: Style.fontSize
    property int textWeight: Style.fontWeight
    property int textHorizontalAlignment: icon ? Text.AlignHCenter : Text.AlignLeft

    property color normalColor: Style.foreground
    property color hoverColor: Style.foregroundHover

    height: parent ? parent.height : implicitHeight

    color: hovered ? hoverColor : normalColor

    font.family: icon ? Style.iconFontFamily : Style.fontFamily
    font.pixelSize: textPixelSize
    font.weight: textWeight

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: textHorizontalAlignment
}
