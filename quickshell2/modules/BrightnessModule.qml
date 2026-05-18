pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../common"

Item {
    id: brightnessRoot

    property bool useBackground: true
    property var inhibitorWindow: null
    property string iconText: Style.brightnessLowIcon
    property string percentText: "0%"
    property int brightnessPercent: 0
    property bool nightModeEnabled: false
    property bool caffeineEnabled: false

    width: brightnessButton.width
    height: brightnessButton.height

    function refreshStatus() {
        statusProcess.running = true;
    }

    function parseStatus(text) {
        const parts = text.trim().split("|");

        if (parts.length < 4)
            return;

        iconText = parts[0];
        brightnessPercent = Number(parts[1]);
        percentText = parts[1] + "%";
        nightModeEnabled = parts[2] === "1";
    }

    function setBrightness(percent) {
        const value = Math.max(1, Math.min(100, Math.round(percent)));

        brightnessSetProcess.command = [
            "sh",
            "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "brightnessctl set " + value + "%; " +
            "else " +
            "hyprctl hyprsunset gamma " + value + "; " +
            "fi"
        ];

        brightnessSetProcess.startDetached();
        refreshDelay.restart();
    }

    function togglePopup() {
        brightnessPopup.visible = !brightnessPopup.visible;

        if (brightnessPopup.visible) {
            brightnessPopup.anchor.updateAnchor();
            refreshStatus();
        }
    }

    function changeBrightness(direction) {
        brightnessChangeProcess.command = [
            "sh",
            "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "brightnessctl set 1%" + direction + "; " +
            "else " +
            "hyprctl hyprsunset gamma " + direction + "1; " +
            "fi"
        ];

        brightnessChangeProcess.startDetached();
        refreshDelay.restart();
    }

    function toggleNightMode() {
        toggleNightModeProcess.startDetached();
        refreshDelay.restart();
    }

    function toggleCaffeine() {
        caffeineEnabled = !caffeineEnabled;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: brightnessRoot.refreshStatus()
    }

    Timer {
        id: refreshDelay

        interval: 160
        repeat: false

        onTriggered: brightnessRoot.refreshStatus()
    }

    Process {
        id: statusProcess

        command: [
            "sh",
            "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "gamma=\"$(brightnessctl -m | cut -d, -f4 | sed 's/%//')\"; " +
            "else " +
            "gamma=\"$(hyprctl hyprsunset gamma | awk '{print int($1)}')\"; " +
            "fi; " +
            "temperature=\"$(hyprctl hyprsunset temperature | awk '{print int($1)}')\"; " +
            "if [ \"$temperature\" -ne 6000 ]; then " +
            "icon='" + Style.brightnessNightIcon + "'; night=1; " +
            "elif [ \"$gamma\" -gt 33 ] && [ \"$gamma\" -lt 66 ]; then " +
            "icon='" + Style.brightnessMediumIcon + "'; night=0; " +
            "elif [ \"$gamma\" -gt 66 ]; then " +
            "icon='" + Style.brightnessHighIcon + "'; night=0; " +
            "else " +
            "icon='" + Style.brightnessLowIcon + "'; night=0; " +
            "fi; " +
            "printf '%s|%s|%s|ok\\n' \"$icon\" \"$gamma\" \"$night\""
        ]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: brightnessRoot.parseStatus(text)
        }

        stderr: StdioCollector {}
    }

    Process {
        id: brightnessChangeProcess
    }

    Process {
        id: brightnessSetProcess
    }

    Process {
        id: toggleNightModeProcess

        command: [
            "sh",
            "-c",
            "night_mode=3000; " +
            "normal_mode=6000; " +
            "current_mode=\"$(hyprctl hyprsunset temperature | awk '{print $1}')\"; " +
            "if [ \"$current_mode\" -ne \"$normal_mode\" ]; then " +
            "hyprctl hyprsunset temperature \"$normal_mode\"; " +
            "else " +
            "systemctl restart --user hyprsunset.service; " +
            "sleep 0.1; " +
            "current_mode=\"$(hyprctl hyprsunset temperature | awk '{print $1}')\"; " +
            "if [ \"$current_mode\" -eq \"$normal_mode\" ]; then " +
            "hyprctl hyprsunset temperature \"$night_mode\"; " +
            "fi; " +
            "fi"
        ]
    }

    IdleInhibitor {
        window: brightnessRoot.inhibitorWindow
        enabled: brightnessRoot.caffeineEnabled
    }

    ModuleBox {
        id: brightnessButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        contentSpacing: 7
        useBackground: brightnessRoot.useBackground
        color: brightnessRoot.nightModeEnabled ? Style.brightnessActiveBackground : (useBackground ? Style.moduleBackground : "transparent")
        border.color: brightnessRoot.nightModeEnabled ? Style.brightnessActiveBorder : (useBackground ? Style.moduleBorder : "transparent")
        border.width: useBackground ? Style.borderWidth : 0

        width: Style.modulePaddingX * 2 + brightnessIcon.implicitWidth + contentSpacing + brightnessText.implicitWidth

        BarText {
            id: brightnessIcon

            icon: true
            hovered: brightnessMouseArea.containsMouse
            textPixelSize: Style.brightnessIconSize
            textWeight: brightnessRoot.nightModeEnabled ? Style.brightnessActiveFontWeight : Style.fontWeight
            normalColor: brightnessRoot.nightModeEnabled ? Style.brightnessActiveForeground : Style.foreground
            hoverColor: brightnessRoot.nightModeEnabled ? Style.brightnessActiveHoverForeground : Style.foregroundHover

            text: brightnessRoot.iconText
        }

        BarText {
            id: brightnessText

            hovered: brightnessMouseArea.containsMouse
            textWeight: brightnessRoot.nightModeEnabled ? Style.brightnessActiveFontWeight : Style.fontWeight
            normalColor: brightnessRoot.nightModeEnabled ? Style.brightnessActiveForeground : Style.foreground
            hoverColor: brightnessRoot.nightModeEnabled ? Style.brightnessActiveHoverForeground : Style.foregroundHover

            text: brightnessRoot.percentText
        }
    }

    MouseArea {
        id: brightnessMouseArea

        anchors.fill: brightnessButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: brightnessRoot.togglePopup()

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0)
                brightnessRoot.changeBrightness("+");
            else if (wheel.angleDelta.y < 0)
                brightnessRoot.changeBrightness("-");

            wheel.accepted = true;
        }
    }

    PopupWindow {
        id: brightnessPopup

        anchor {
            item: brightnessRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.brightnessPopupMaxWidth, Math.max(Style.brightnessPopupMinWidth, popupBackground.implicitWidth))
        height: popupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                brightnessRoot.refreshStatus();
        }

        Rectangle {
            id: popupBackground

            anchors.fill: parent

            implicitWidth: popupColumn.implicitWidth + Style.brightnessPopupPadding * 2
            implicitHeight: popupColumn.implicitHeight + Style.brightnessPopupPadding * 2

            radius: Style.moduleRadius
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: popupColumn

                x: Style.brightnessPopupPadding
                y: Style.brightnessPopupPadding

                width: brightnessPopup.width - Style.brightnessPopupPadding * 2
                spacing: Style.brightnessPopupSectionGap

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        width: parent.width

                        text: "Brightness"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: brightnessRoot.percentText
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: 15
                        font.weight: brightnessRoot.nightModeEnabled ? Style.brightnessActiveFontWeight : 800

                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: brightnessRoot.nightModeEnabled ? "Night mode enabled" : "Normal display mode"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight
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
                    spacing: 6

                    Text {
                        width: parent.width

                        text: "Level"
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: 700
                    }

                    SmoothSlider {
                        width: parent.width
                        ratio: brightnessRoot.brightnessPercent / 100

                        onMoved: function(ratio) {
                            brightnessRoot.setBrightness(ratio * 100);
                        }
                    }
                }

                PillButton {
                    width: parent.width
                    buttonHeight: Style.brightnessButtonHeight
                    active: brightnessRoot.nightModeEnabled
                    activeBackgroundColor: Style.brightnessToggleActiveBackground
                    activeHoverBackgroundColor: Style.brightnessToggleActiveHoverBackground
                    activeForegroundColor: Style.brightnessToggleActiveForeground
                    activeHoverForegroundColor: Style.brightnessToggleActiveHoverForeground
                    activeFontWeight: Style.brightnessActiveFontWeight
                    labelText: brightnessRoot.nightModeEnabled ? "Disable night mode" : "Enable night mode"
                    iconText: brightnessRoot.nightModeEnabled ? Style.brightnessHighIcon : Style.brightnessNightIcon
                    iconSize: Style.brightnessIconSize

                    onPressed: brightnessRoot.toggleNightMode()
                }

                PillButton {
                    width: parent.width
                    buttonHeight: Style.brightnessSecondaryButtonHeight
                    active: brightnessRoot.caffeineEnabled
                    activeBackgroundColor: Style.brightnessToggleActiveBackground
                    activeHoverBackgroundColor: Style.brightnessToggleActiveHoverBackground
                    activeForegroundColor: Style.brightnessToggleActiveForeground
                    activeHoverForegroundColor: Style.brightnessToggleActiveHoverForeground
                    activeFontWeight: Style.brightnessActiveFontWeight
                    labelText: brightnessRoot.caffeineEnabled ? "Keep awake on" : "Keep awake"
                    iconText: Style.caffeineIcon
                    iconSize: Style.brightnessIconSize

                    onPressed: brightnessRoot.toggleCaffeine()
                }
            }
        }
    }

    Component.onCompleted: refreshStatus()
}
