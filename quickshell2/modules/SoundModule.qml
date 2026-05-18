pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."
import "../common"

Item {
    id: soundRoot

    property bool inputMode: false

    readonly property var activeNode: inputMode ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property var devices: filteredDevices()
    readonly property real maxVolume: inputMode ? Style.inputMaxVolume : Style.audioMaxVolume
    readonly property int volumePercent: activeNode !== null && activeNode.audio !== null ? Math.round(activeNode.audio.volume * 100) : 0

    width: soundButton.width
    height: soundButton.height

    function filteredDevices() {
        const nodes = Pipewire.nodes.values || [];
        let result = [];

        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];

            if (!node)
                continue;

            if (node.audio === null)
                continue;

            if (node.isStream)
                continue;

            if (inputMode) {
                if (node.isSink)
                    continue;
            } else if (!node.isSink) {
                continue;
            }

            result.push(node);
        }

        result.sort((a, b) => soundRoot.deviceName(a).localeCompare(soundRoot.deviceName(b)));
        return result;
    }

    function deviceName(node) {
        if (!node)
            return inputMode ? "Unknown input" : "Unknown output";

        if (node.description && node.description.length > 0)
            return node.description;

        if (node.nickname && node.nickname.length > 0)
            return node.nickname;

        if (node.name && node.name.length > 0)
            return node.name;

        return inputMode ? "Unknown input" : "Unknown output";
    }

    function deviceDetail(node) {
        if (!node)
            return "";

        if (node.name && node.name.length > 0)
            return node.name;

        return inputMode ? "PipeWire input" : "PipeWire output";
    }

    function isSelected(node) {
        if (!node || !activeNode)
            return false;

        return node.id === activeNode.id;
    }

    function statusIcon() {
        if (!activeNode || !activeNode.audio)
            return inputMode ? Style.inputMutedIcon : Style.audioMutedIcon;

        if (activeNode.audio.muted)
            return inputMode ? Style.inputMutedIcon : Style.audioMutedIcon;

        if (activeNode.audio.volume <= 0.005)
            return inputMode ? Style.inputMutedIcon : Style.audioZeroIcon;

        if (inputMode)
            return Style.inputActiveIcon;

        if (activeNode.audio.volume < 0.34)
            return Style.audioLowIcon;

        if (activeNode.audio.volume < 0.67)
            return Style.audioMediumIcon;

        return Style.audioHighIcon;
    }

    function titleText() {
        if (!activeNode)
            return inputMode ? "No audio input" : "No audio output";

        return deviceName(activeNode);
    }

    function detailText() {
        if (!activeNode || !activeNode.audio)
            return inputMode ? "PipeWire input is unavailable" : "PipeWire output is unavailable";

        if (activeNode.audio.muted)
            return "Muted • " + volumePercent + "%";

        return inputMode ? volumePercent + "% input gain" : volumePercent + "% volume";
    }

    function selectDevice(node) {
        if (!node)
            return;

        if (inputMode)
            Pipewire.preferredDefaultAudioSource = node;
        else
            Pipewire.preferredDefaultAudioSink = node;
    }

    function toggleMute() {
        if (!activeNode || !activeNode.audio)
            return;

        activeNode.audio.muted = !activeNode.audio.muted;
    }

    function setVolumeFromRatio(ratio) {
        if (!activeNode || !activeNode.audio)
            return;

        activeNode.audio.volume = Math.max(0, Math.min(1, ratio)) * maxVolume;

        if (activeNode.audio.muted && ratio > 0.001)
            activeNode.audio.muted = false;
    }

    function togglePopup() {
        soundPopup.visible = !soundPopup.visible;

        if (soundPopup.visible)
            soundPopup.anchor.updateAnchor();
    }

    PwObjectTracker {
        objects: [soundRoot.activeNode].concat(soundRoot.devices)
    }

    Process {
        id: soundSettingsProcess
        command: ["pavucontrol"]
    }

    ModuleBox {
        id: soundButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        contentSpacing: 7

        width: Math.max(soundRoot.inputMode ? Style.inputButtonMinWidth : Style.audioButtonMinWidth, Style.modulePaddingX * 2 + buttonIcon.implicitWidth + contentSpacing + buttonText.implicitWidth)

        BarText {
            id: buttonIcon

            icon: true
            hovered: soundButton.hovered
            textPixelSize: soundRoot.inputMode ? Style.inputIconSize : Style.audioIconSize

            text: soundRoot.statusIcon()
        }

        BarText {
            id: buttonText

            hovered: soundButton.hovered
            text: soundRoot.volumePercent + "%"
        }
    }

    MouseArea {
        anchors.fill: soundButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: soundRoot.togglePopup()
    }

    PopupWindow {
        id: soundPopup

        anchor {
            item: soundRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(soundRoot.inputMode ? Style.inputPopupMaxWidth : Style.audioPopupMaxWidth, Math.max(soundRoot.inputMode ? Style.inputPopupMinWidth : Style.audioPopupMinWidth, popupBackground.implicitWidth))

        height: popupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        Rectangle {
            id: popupBackground

            anchors.fill: parent

            implicitWidth: popupColumn.implicitWidth + popupPadding() * 2
            implicitHeight: popupColumn.implicitHeight + popupPadding() * 2

            radius: Style.moduleRadius + 6
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            function popupPadding() {
                return soundRoot.inputMode ? Style.inputPopupPadding : Style.audioPopupPadding;
            }

            Column {
                id: popupColumn

                x: popupBackground.popupPadding()
                y: popupBackground.popupPadding()

                width: soundPopup.width - popupBackground.popupPadding() * 2
                spacing: soundRoot.inputMode ? Style.inputSectionGap : Style.audioSectionGap

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        width: parent.width

                        text: soundRoot.inputMode ? "Input" : "Output"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: soundRoot.titleText()
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: 15
                        font.weight: 800

                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: soundRoot.detailText()
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        elide: Text.ElideRight
                    }
                }

                Row {
                    width: parent.width
                    height: Math.max(roundButtonSize(), volumeSlider.height)
                    spacing: 12

                    function roundButtonSize() {
                        return soundRoot.inputMode ? Style.inputRoundButtonSize : Style.audioRoundButtonSize;
                    }

                    RoundIconButton {
                        id: muteButton

                        anchors.verticalCenter: parent.verticalCenter

                        buttonSize: parent.roundButtonSize()
                        iconText: soundRoot.statusIcon()
                        usable: soundRoot.activeNode !== null && soundRoot.activeNode.audio !== null

                        onPressed: soundRoot.toggleMute()
                    }

                    SmoothSlider {
                        id: volumeSlider

                        anchors.verticalCenter: parent.verticalCenter

                        width: parent.width - muteButton.width - parent.spacing
                        ratio: soundRoot.activeNode !== null && soundRoot.activeNode.audio !== null ? Math.max(0, Math.min(1, soundRoot.activeNode.audio.volume / soundRoot.maxVolume)) : 0
                        usable: soundRoot.activeNode !== null && soundRoot.activeNode.audio !== null
                        sliderHeight: soundRoot.inputMode ? Style.inputSliderHeight : Style.audioSliderHeight
                        trackHeight: soundRoot.inputMode ? Style.inputSliderTrackHeight : Style.audioSliderTrackHeight
                        thumbSize: soundRoot.inputMode ? Style.inputSliderThumbSize : Style.audioSliderThumbSize
                        thumbHoverSize: soundRoot.inputMode ? Style.inputSliderThumbHoverSize : Style.audioSliderThumbHoverSize

                        onMoved: function (ratio) {
                            soundRoot.setVolumeFromRatio(ratio);
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Style.moduleBorder
                    opacity: 0.9
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width

                        text: soundRoot.inputMode ? "Available inputs" : "Available outputs"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: 700
                    }

                    Flickable {
                        id: devicesFlickable

                        readonly property bool empty: soundRoot.devices.length === 0

                        width: parent.width
                        height: empty ? 58 : Math.min(soundRoot.inputMode ? Style.inputSourceListMaxHeight : Style.audioOutputListMaxHeight, devicesColumn.implicitHeight)

                        contentWidth: width
                        contentHeight: empty ? height : devicesColumn.implicitHeight
                        clip: true
                        interactive: !empty && contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: devicesColumn

                            width: devicesFlickable.width
                            spacing: 5
                            visible: !devicesFlickable.empty

                            Repeater {
                                model: soundRoot.devices

                                SoundDeviceRow {
                                    required property var modelData

                                    node: modelData
                                    titleText: soundRoot.deviceName(modelData)
                                    detailText: soundRoot.deviceDetail(modelData)
                                    selected: soundRoot.isSelected(modelData)

                                    onSelectedDevice: function (node) {
                                        soundRoot.selectDevice(node);
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 24

                            visible: devicesFlickable.empty

                            text: Pipewire.ready ? (soundRoot.inputMode ? "No input devices found" : "No output devices found") : "Waiting for PipeWire..."

                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSize
                            font.weight: Style.fontWeight

                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                PillButton {
                    width: parent.width
                    buttonHeight: soundRoot.inputMode ? Style.inputSettingsButtonHeight : Style.audioSettingsButtonHeight
                    labelText: "Sound settings"
                    iconText: soundRoot.inputMode ? Style.inputSettingsIcon : Style.audioSettingsIcon
                    iconSize: soundRoot.inputMode ? Style.inputIconSize : Style.audioIconSize

                    onPressed: {
                        soundSettingsProcess.startDetached();
                        soundPopup.visible = false;
                    }
                }
            }
        }
    }

    component SoundDeviceRow: Item {
        id: deviceRow

        required property var node
        required property string titleText
        required property string detailText
        property bool selected: false

        signal selectedDevice(var node)

        width: parent ? parent.width : (soundRoot.inputMode ? Style.inputPopupMinWidth : Style.audioPopupMinWidth)
        height: soundRoot.inputMode ? Style.inputSourceRowHeight : Style.audioOutputRowHeight
        Rectangle {
            anchors.fill: parent

            radius: 14
            color: deviceRow.selected ? Style.playerControlHoverBackground : deviceMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"

            border.color: deviceRow.selected ? "#35ffffff" : "transparent"
            border.width: deviceRow.selected ? 1 : 0

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 12
                rightMargin: 12
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: soundRoot.inputMode ? Style.inputDeviceIcon : Style.audioDeviceIcon
                color: deviceRow.selected ? Style.workspaceFocusedForeground : Style.popupMutedForeground

                font.family: Style.iconFontFamily
                font.pixelSize: soundRoot.inputMode ? Style.inputIconSize : Style.audioIconSize
                font.weight: Style.fontWeight
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 34
                spacing: 1

                Text {
                    width: parent.width

                    text: deviceRow.titleText
                    color: deviceRow.selected ? Style.workspaceFocusedForeground : Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: deviceRow.selected ? 700 : Style.fontWeight

                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: deviceRow.detailText
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: deviceMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: deviceRow.selectedDevice(deviceRow.node)
        }
    }
}
