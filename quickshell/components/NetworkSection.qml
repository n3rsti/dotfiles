import QtQuick
import QtQuick.Controls
import "../config"

Item {
    id: section
    width: parent.width
    height: 40

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool hasSwitch: false
    property bool switchChecked: false
    property bool switchEnabled: true
    signal switchToggled
    signal settingsClicked

    Text {
        id: sectionIcon
        text: section.icon
        color: Theme.textColor
        font.pixelSize: Theme.fontSize + 4
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    Column {
        anchors.left: sectionIcon.right
        anchors.leftMargin: Theme.spacing
        anchors.right: settingsButton.left
        anchors.rightMargin: Theme.spacing
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: section.title
            color: Theme.textColor
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
        }

        Text {
            text: section.subtitle
            color: Theme.textColor
            font.pixelSize: Theme.fontSize - 2
            opacity: 0.6
        }
    }

    Rectangle {
        id: settingsButton
        width: 35
        height: 35
        color: settingsMouseArea.containsMouse ? Theme.surfaceColor : "transparent"
        radius: Theme.smallRadius
        anchors.right: section.hasSwitch ? sectionSwitch.left : parent.right
        anchors.rightMargin: section.hasSwitch ? Theme.spacing : 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: "󰒓"
            color: Theme.textColor
            font.pixelSize: Theme.fontSize + 4
        }

        MouseArea {
            id: settingsMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: section.settingsClicked()
        }
    }

    Switch {
        id: sectionSwitch
        visible: section.hasSwitch
        checked: section.switchChecked
        enabled: section.switchEnabled
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onToggled: section.switchToggled()
    }
}
