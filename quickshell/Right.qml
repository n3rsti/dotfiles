import QtQuick
import "./components/"
import "./config"

Rectangle {
    id: rightSection
    height: parent.height
    width: audioContainer.width + powerButton.width + Theme.spacing
    color: "transparent"

    anchors {
        right: parent.right
        rightMargin: Theme.padding
        verticalCenter: parent.verticalCenter
    }

    Row {
        height: parent.height
        spacing: Theme.spacing
        anchors.right: parent.right

        Container {
            id: audioContainer
            height: parent.height
            width: audio.width + Theme.padding * 2
            bgColor: Theme.containerBackground
            clickable: true
            clickHandler: function () {
                audio.audioPopup.visible = !audio.audioPopup.visible;
            }

            Audio {
                id: audio
                height: parent.height
                width: 60
                anchors.centerIn: parent
            }
        }

        Container {
            id: powerButton
            height: parent.height
            width: powerText.width + Theme.padding * 2
            bgColor: Theme.containerBackground
            clickable: true

            TextComponent {
                id: powerText
                text: "⏻"
                anchors.centerIn: parent
            }
        }
    }
}
