import QtQuick
import "../config"

Rectangle {
    id: container

    property alias bgColor: background.color
    property alias bgOpacity: background.opacity
    property alias hovered: mouseArea.containsMouse
    property color hoverBg: Theme.hoverBackground
    property bool clickable: true
    property var clickHandler: null

    color: "transparent"
    radius: Theme.radius

    Rectangle {
        id: background
        anchors.fill: parent
        radius: parent.radius
        color: Theme.containerBackground
        opacity: Theme.backgroundOpacity

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    states: State {
        name: "hovered"
        when: container.hovered && container.clickable
        PropertyChanges {
            target: background
            color: container.hoverBg
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: container.clickable
        hoverEnabled: container.clickable
        cursorShape: container.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (container.clickHandler) {
                container.clickHandler();
            }
        }
    }
}
