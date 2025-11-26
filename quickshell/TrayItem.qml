pragma ComponentBehavior: Bound

import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: 10 * 2
    implicitHeight: 10 * 2

    onClicked: event => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else {
            modelData.secondaryActivate();
        }
    }

    IconImage {
        source: modelData.icon
        implicitSize: 16
        anchors.centerIn: parent
    }
}
