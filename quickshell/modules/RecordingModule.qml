pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../common"

Item {
    id: recordingRoot

    property bool useBackground: true
    property bool active: false
    property string durationText: ""

    width: active ? recordingButton.width : 0
    height: recordingButton.height
    visible: active

    function refreshStatus() {
        statusProcess.running = true;
    }

    function parseStatus(text) {
        const trimmed = text.trim();

        if (trimmed.length === 0) {
            active = false;
            durationText = "";
            return;
        }

        active = true;
        durationText = trimmed;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: recordingRoot.refreshStatus()
    }

    Process {
        id: statusProcess

        command: [
            "sh",
            "-c",
            "pid=\"$(pgrep -x wf-recorder | head -n1)\"; " +
            "if [ -n \"$pid\" ]; then " +
            "seconds=\"$(ps -o etimes= -p \"$pid\" | tr -d ' ')\"; " +
            "printf '%02d:%02d:%02d\\n' \"$((seconds / 3600))\" \"$(((seconds % 3600) / 60))\" \"$((seconds % 60))\"; " +
            "fi"
        ]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: recordingRoot.parseStatus(text)
        }

        stderr: StdioCollector {}
    }

    Process {
        id: stopRecordingProcess
        command: ["pkill", "-INT", "-x", "wf-recorder"]
    }

    ModuleBox {
        id: recordingButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        useBackground: recordingRoot.useBackground

        width: Style.modulePaddingX * 2 + recordingIconText.implicitWidth

        BarText {
            id: recordingIconText

            icon: true
            hovered: recordingMouseArea.containsMouse
            textPixelSize: Style.recordingIconSize
            normalColor: Style.recordingForeground
            hoverColor: Style.recordingForeground

            text: Style.recordingIcon
        }
    }

    MouseArea {
        id: recordingMouseArea

        anchors.fill: recordingButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            stopRecordingProcess.startDetached();
            recordingRoot.active = false;
            recordingRoot.durationText = "";
        }
    }

    Component.onCompleted: refreshStatus()
}
