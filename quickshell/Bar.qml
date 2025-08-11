// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time
  property string bg: "#191b26bf"

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }
      color: root.bg


      Rectangle {
          implicitWidth: workspaces_row.implicitWidth
          implicitHeight: workspaces_row.implicitHeight
          id: bar
          color: root.bg
          anchors {
              fill: parent
              margins: 15
          }

          radius: 10

          Row {
              id: workspaces_row
              width: 100
              height: 100
          }



          // Row {
          //     width: parent.width
          //     id: workspaces_row
          //     anchors {
          //         fill: parent
          //     }
          //     Rectangle {
          //         id: workspaces_list
          //         color: "#000008"
          //         Text {
          //             text: "xddddd"
          //             color: "#fff"
          //
          //         anchors {
          //             fill: parent
          //             verticalCenter: parent.verticalCenter
          //         }
          //         }
          //     }
          // }
          //
          Rectangle {
              anchors {
                  centerIn: parent
              }
              Text {
                  anchors.centerIn: parent
                  text: root.time
                  color: "#fff"
              }
          }
      }

      implicitHeight: 30

    }

  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
