import QtQuick
import QtQml
import ".."

Item {
    id: roundButton

    required property string iconText
    property bool usable: true
    property int buttonSize: Style.playerControlButtonSize
    property int iconSize: 18
    property bool primary: false

    signal pressed()

    width: primary ? Style.playerPrimaryControlButtonSize : buttonSize
    height: width
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: roundMouseArea.containsMouse && roundButton.usable
               ? Style.playerControlHoverBackground
               : Style.playerControlBackground
        border.color: roundButton.primary ? "#35ffffff" : "transparent"
        border.width: roundButton.primary ? 1 : 0
        opacity: roundButton.usable ? 1 : 0.35

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Text {
        anchors.centerIn: parent
        text: roundButton.iconText
        color: roundMouseArea.containsMouse && roundButton.usable ? Style.foregroundHover : Style.foreground
        font.family: Style.iconFontFamily
        font.pixelSize: roundButton.primary ? 21 : roundButton.iconSize
        font.weight: Style.fontWeight
    }

    MouseArea {
        id: roundMouseArea
        anchors.fill: parent
        enabled: roundButton.usable
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: roundButton.pressed()
    }
}
