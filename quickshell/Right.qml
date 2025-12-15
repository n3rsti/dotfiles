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

    NetworkPopup {
        id: networkPopup
        parentWindow: bar
        networks: networking.availableNetworks
        connectionType: networking.connectionType
        wifiEnabled: networking.wifiEnabled
        activeSSID: networking.activeSSID
        signalStrength: networking.signalStrength
        bluetoothAdapter: networking.adapter
    }

    Row {
        height: parent.height
        spacing: Theme.spacing
        anchors.right: parent.right

        Container {
            height: parent.height
            bgColor: Theme.containerBackground
            width: networking.implicitWidth
            clickable: true
            clickHandler: function () {
                networkPopup.visible = !networkPopup.visible;
            }

            Networking {
                id: networking
                height: parent.height
                anchors.centerIn: parent
            }
        }

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
