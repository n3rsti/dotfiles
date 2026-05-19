import QtQuick
import QtQml
import ".."

Rectangle {
    id: box

    signal clicked()

    default property alias content: contentRow.data
    property alias contentSpacing: contentRow.spacing

    property int paddingX: Style.modulePaddingX
    property bool hovered: hoverHandler.hovered
    property bool useBackground: true
    property bool clickable: false

    implicitWidth: contentRow.implicitWidth + paddingX * 2
    implicitHeight: Style.moduleHeight

    radius: Style.moduleRadius
    color: useBackground ? Style.moduleBackground : "transparent"
    border.color: useBackground ? Style.moduleBorder : "transparent"
    border.width: useBackground ? Style.borderWidth : 0

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Style.moduleHoverOverlay
        opacity: box.hovered ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: contentRow

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: Style.moduleContentYOffset
        }

        height: parent.height
        spacing: Style.moduleGap
    }

    MouseArea {
        anchors.fill: parent
        enabled: box.clickable
        acceptedButtons: Qt.LeftButton
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: box.clicked()
    }
}
