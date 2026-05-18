import QtQuick
import QtQml
import ".."

Item {
    id: pillButton

    required property string labelText
    required property string iconText
    property bool usable: true
    property bool active: false
    property int iconSize: Style.fontSize + 4
    property int buttonHeight: Style.moduleHeight
    property color activeBackgroundColor: Style.workspaceFocusedBackground
    property color activeHoverBackgroundColor: Style.workspaceFocusedBackground
    property color activeForegroundColor: Style.workspaceFocusedForeground
    property color activeHoverForegroundColor: Style.foregroundHover
    property int activeFontWeight: 700

    signal pressed()

    height: buttonHeight
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: pillButton.active
               ? (pillMouseArea.containsMouse && pillButton.usable ? pillButton.activeHoverBackgroundColor : pillButton.activeBackgroundColor)
               : (pillMouseArea.containsMouse && pillButton.usable ? Style.playerControlHoverBackground : Style.playerPanelBackground)
        opacity: pillButton.usable ? 1 : 0.45

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pillButton.iconText
            color: pillButton.active
                   ? (pillMouseArea.containsMouse && pillButton.usable ? pillButton.activeHoverForegroundColor : pillButton.activeForegroundColor)
                   : (pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground)
            font.family: Style.iconFontFamily
            font.pixelSize: pillButton.iconSize
            font.weight: Style.fontWeight
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pillButton.labelText
            color: pillButton.active
                   ? (pillMouseArea.containsMouse && pillButton.usable ? pillButton.activeHoverForegroundColor : pillButton.activeForegroundColor)
                   : (pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground)
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize
            font.weight: pillButton.active ? pillButton.activeFontWeight : 700
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
