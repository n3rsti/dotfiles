import QtQuick
import QtQml
import ".."

Item {
    id: pillButton

    required property string labelText
    required property string iconText
    property bool usable: true
    property int iconSize: Style.fontSize + 4
    property int buttonHeight: Style.moduleHeight

    signal pressed()

    height: buttonHeight
    scale: pillMouseArea.containsMouse && usable ? 1.01 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: pillMouseArea.containsMouse && pillButton.usable
               ? Style.playerControlHoverBackground
               : Style.playerPanelBackground
        opacity: pillButton.usable ? 1 : 0.45

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pillButton.iconText
            color: pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground
            font.family: Style.iconFontFamily
            font.pixelSize: pillButton.iconSize
            font.weight: Style.fontWeight
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pillButton.labelText
            color: pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize
            font.weight: 700
        }
    }

    MouseArea {
        id: pillMouseArea
        anchors.fill: parent
        enabled: pillButton.usable
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: pillButton.pressed()
    }
}
