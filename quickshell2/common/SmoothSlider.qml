import QtQuick
import QtQml
import ".."

Item {
    id: smoothSlider

    required property real ratio
    property bool usable: true
    property int sliderHeight: Style.audioSliderHeight
    property int trackHeight: Style.audioSliderTrackHeight
    property int thumbSize: Style.audioSliderThumbSize
    property int thumbHoverSize: Style.audioSliderThumbHoverSize

    signal moved(real ratio)

    height: sliderHeight

    function setFromX(xPosition) {
        if (!usable)
            return;

        smoothSlider.moved(Math.max(0, Math.min(1, xPosition / width)));
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 18
        radius: height / 2
        color: Style.playerPanelBackground
        opacity: sliderMouseArea.containsMouse ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: track
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: smoothSlider.trackHeight
        radius: height / 2
        color: sliderMouseArea.containsMouse ? Style.playerSliderHoverTrack : Style.playerSliderTrack

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors {
            left: track.left
            verticalCenter: track.verticalCenter
        }
        width: track.width * Math.max(0, Math.min(1, smoothSlider.ratio))
        height: track.height
        radius: height / 2
        color: sliderMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

        Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors.verticalCenter: track.verticalCenter
        x: Math.max(0, Math.min(parent.width - width, track.width * Math.max(0, Math.min(1, smoothSlider.ratio)) - width / 2))
        width: sliderMouseArea.containsMouse || sliderMouseArea.pressed ? smoothSlider.thumbHoverSize : smoothSlider.thumbSize
        height: width
        radius: width / 2
        color: sliderMouseArea.containsMouse ? Style.foregroundHover : Style.foreground
        opacity: smoothSlider.usable ? 1 : 0.35

        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: sliderMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: smoothSlider.usable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: function(mouse) { smoothSlider.setFromX(mouse.x); }
        onPositionChanged: function(mouse) {
            if (pressed)
                smoothSlider.setFromX(mouse.x);
        }
    }
}
