import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Rectangle {
    Row {
        Rectangle {
            width: 10
            height: 20
            color: "green"
        }
        Repeater {
            model: 10
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: "green"
            }
        }
        Rectangle {
            width: 10
            height: 20
            color: "blue"
        }
    }
}
