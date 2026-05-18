import QtQuick
import QtQml
import ".."

Rectangle {
    id: group

    default property alias content: contentRow.data
    property alias contentSpacing: contentRow.spacing

    property int paddingX: Style.modulePaddingX
    property bool autoStripChildBackgrounds: true
    property bool useHoverOverlay: false

    function syncChildBackgrounds() {
        if (!autoStripChildBackgrounds)
            return;

        const children = contentRow.children;

        for (let i = 0; i < children.length; i++) {
            const child = children[i];

            if (!child)
                continue;

            if (child.hasOwnProperty("useBackground"))
                child.useBackground = false;
        }
    }

    implicitWidth: contentRow.implicitWidth + paddingX * 2
    implicitHeight: Style.moduleHeight

    radius: Style.moduleRadius
    color: Style.moduleBackground
    border.color: Style.moduleBorder
    border.width: Style.borderWidth

    HoverHandler {
        id: hoverHandler
    }

    Component.onCompleted: syncChildBackgrounds()

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Style.moduleHoverOverlay
        opacity: group.useHoverOverlay && hoverHandler.hovered ? 1 : 0

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
        spacing: 0

        onChildrenChanged: group.syncChildBackgrounds()
    }
}
