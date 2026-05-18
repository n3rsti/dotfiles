import QtQuick
import QtQml
import ".."

Rectangle {
    id: box

    default property alias content: contentRow.data
    property alias contentSpacing: contentRow.spacing

    property int paddingX: Style.modulePaddingX
    property bool hovered: hoverHandler.hovered

    implicitWidth: contentRow.implicitWidth + paddingX * 2
    implicitHeight: Style.moduleHeight

    radius: Style.moduleRadius
    color: Style.moduleBackground
    border.color: Style.moduleBorder
    border.width: Style.borderWidth

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
}
