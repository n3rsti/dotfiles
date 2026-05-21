pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import ".."
import "../common"

Item {
    id: keyboardRoot

    property bool useBackground: true
    property var layouts: []
    property var layoutEntries: []
    property string activeKeymap: ""
    property int currentLayoutIndex: -1
    property string currentLayoutCode: ""
    property string statusMessage: ""

    width: keyboardButton.width
    height: keyboardButton.height

    function parseLayouts(text) {
        const value = text.trim();

        if (value.length === 0) {
            layouts = [];
            layoutEntries = [];
            return;
        }

        const parts = value.split(",");
        let result = [];

        for (let i = 0; i < parts.length; i++) {
            const part = parts[i].trim().toLowerCase();

            if (part.length > 0)
                result.push(part);
        }

        layouts = result;
        layoutEntries = result.map((layout, index) => {
            return {
                "layout": layout,
                "index": index
            };
        });
        currentLayoutIndex = matchLayoutIndex(activeKeymap);

        if (currentLayoutIndex >= 0)
            currentLayoutCode = layouts[currentLayoutIndex];
        else if (layouts.length > 0 && currentLayoutCode.length === 0)
            currentLayoutCode = layouts[0];
    }

    function refreshConfiguredLayouts() {
        configuredLayoutsProcess.running = true;
    }

    function refreshStatus() {
        layoutStatusProcess.running = true;
    }

    function formatLayoutLabel(layout) {
        return layout ? layout.toLowerCase() : "--";
    }

    function formatLayoutTitle(layout) {
        if (!layout || layout.length === 0)
            return "Unknown layout";

        switch (layout.toLowerCase()) {
        case "us":
            return "English (US)";
        case "pl":
            return "Polish";
        case "de":
            return "German";
        case "fr":
            return "French";
        case "es":
            return "Spanish";
        default:
            return layout.toUpperCase();
        }
    }

    function layoutAliases(layout) {
        switch ((layout || "").toLowerCase()) {
        case "us":
            return ["us", "english (us)", "english us", "english"];
        case "pl":
            return ["pl", "polish", "polski"];
        case "de":
            return ["de", "german", "deutsch"];
        case "fr":
            return ["fr", "french", "francais", "français"];
        case "es":
            return ["es", "spanish", "espanol", "español"];
        default:
            return [(layout || "").toLowerCase()];
        }
    }

    function matchLayoutIndex(keymap) {
        const normalizedKeymap = (keymap || "").trim().toLowerCase();

        if (normalizedKeymap.length === 0)
            return -1;

        for (let i = 0; i < layouts.length; i++) {
            const aliases = layoutAliases(layouts[i]);

            for (let j = 0; j < aliases.length; j++) {
                if (normalizedKeymap === aliases[j] || normalizedKeymap.indexOf(aliases[j]) >= 0)
                    return i;
            }
        }

        return -1;
    }

    function parseStatus(text) {
        const trimmed = text.trim();

        if (trimmed.length === 0)
            return;

        try {
            const payload = JSON.parse(trimmed);
            const keyboards = payload.keyboards || [];

            if (keyboards.length === 0)
                return;

            let keyboard = keyboards[0];

            for (let i = 0; i < keyboards.length; i++) {
                if (keyboards[i] && keyboards[i].main === true) {
                    keyboard = keyboards[i];
                    break;
                }
            }

            activeKeymap = keyboard && keyboard.active_keymap ? keyboard.active_keymap : "";
            currentLayoutIndex = matchLayoutIndex(activeKeymap);

            if (currentLayoutIndex >= 0)
                currentLayoutCode = layouts[currentLayoutIndex];
            else if (activeKeymap.length > 0)
                currentLayoutCode = activeKeymap;

            statusMessage = "";
        } catch (error) {
            statusMessage = "Unable to read keyboard layout status.";
        }
    }

    function displayLayoutText() {
        if (currentLayoutIndex >= 0 && currentLayoutIndex < layouts.length)
            return formatLayoutLabel(layouts[currentLayoutIndex]);

        if (currentLayoutCode.length > 0)
            return currentLayoutCode.toLowerCase();

        return "--";
    }

    function switchToLayout(index) {
        if (index < 0 || index >= layouts.length)
            return;

        switchLayoutProcess.command = ["hyprctl", "switchxkblayout", "current", String(index)];
        switchLayoutProcess.startDetached();
        keyboardPopup.visible = false;
        refreshDelay.restart();
    }

    function togglePopup() {
        keyboardPopup.visible = !keyboardPopup.visible;

        if (keyboardPopup.visible) {
            keyboardPopup.anchor.updateAnchor();
            refreshConfiguredLayouts();
            refreshStatus();
        }
    }

    Component.onCompleted: {
        refreshConfiguredLayouts();
        refreshStatus();
    }

    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered: keyboardRoot.refreshStatus()
    }

    Timer {
        id: refreshDelay

        interval: 180
        repeat: false

        onTriggered: keyboardRoot.refreshStatus()
    }

    Process {
        id: configuredLayoutsProcess

        command: [
            "sh",
            "-c",
            "value=\"$(hyprctl getoption input:kb_layout 2>/dev/null | awk -F': ' '/str:/ {print $2}')\"; " +
            "if [ -z \"$value\" ]; then " +
            "value=\"$(sed -n 's/^[[:space:]]*kb_layout[[:space:]]*=[[:space:]]*//p' ~/.config/hypr/input.conf | head -n1)\"; " +
            "fi; " +
            "printf '%s\\n' \"$value\""
        ]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: keyboardRoot.parseLayouts(text)
        }

        stderr: StdioCollector {}
    }

    Process {
        id: layoutStatusProcess

        command: ["hyprctl", "-j", "devices"]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: keyboardRoot.parseStatus(text)
        }

        stderr: StdioCollector {}
    }

    Process {
        id: switchLayoutProcess
    }

    ModuleBox {
        id: keyboardButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        contentSpacing: 7
        useBackground: keyboardRoot.useBackground
        width: Math.max(Style.keyboardButtonMinWidth, Style.modulePaddingX * 2 + keyboardIcon.implicitWidth + contentSpacing + layoutText.implicitWidth)

        BarText {
            id: keyboardIcon

            icon: true
            hovered: keyboardMouseArea.containsMouse
            textPixelSize: Style.keyboardIconSize

            text: Style.keyboardIcon
        }

        BarText {
            id: layoutText

            hovered: keyboardMouseArea.containsMouse
            text: keyboardRoot.displayLayoutText()
        }
    }

    MouseArea {
        id: keyboardMouseArea

        anchors.fill: keyboardButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: keyboardRoot.togglePopup()
    }

    PopupWindow {
        id: keyboardPopup

        anchor {
            item: keyboardRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.keyboardPopupMaxWidth, Math.max(Style.keyboardPopupMinWidth, popupBackground.implicitWidth))
        implicitHeight: popupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        Rectangle {
            id: popupBackground

            anchors.fill: parent
            implicitWidth: popupColumn.implicitWidth + Style.keyboardPopupPadding * 2
            implicitHeight: popupColumn.implicitHeight + Style.keyboardPopupPadding * 2

            radius: Style.moduleRadius
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: popupColumn

                x: Style.keyboardPopupPadding
                y: Style.keyboardPopupPadding

                width: keyboardPopup.width - Style.keyboardPopupPadding * 2
                spacing: Style.keyboardPopupSectionGap

                Column {
                    width: parent.width
                    spacing: 3

                    Text {
                        width: parent.width

                        text: "Keyboard layout"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: currentLayoutIndex >= 0 ? formatLayoutTitle(layouts[currentLayoutIndex]) : activeKeymap
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupTitleFontSize
                        font.weight: 700

                        elide: Text.ElideRight
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
                    spacing: 5

                    Repeater {
                        model: keyboardRoot.layoutEntries

                        KeyboardLayoutRow {
                            required property var modelData

                            width: parent.width
                            layoutIndex: Number(modelData.index)
                            layoutCode: String(modelData.layout)
                            selected: layoutIndex === keyboardRoot.currentLayoutIndex

                            onPressed: keyboardRoot.switchToLayout(layoutIndex)
                        }
                    }

                    Text {
                        width: parent.width
                        visible: keyboardRoot.layouts.length === 0
                        text: "No keyboard layouts found."
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Text {
                    width: parent.width
                    visible: keyboardRoot.statusMessage.length > 0
                    text: keyboardRoot.statusMessage
                    color: Style.recordingForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    component KeyboardLayoutRow: Item {
        id: layoutRow

        property int layoutIndex: -1
        required property string layoutCode
        property bool selected: false

        signal pressed()

        height: Style.keyboardRowHeight

        Rectangle {
            anchors.fill: parent

            radius: Style.keyboardRowRadius
            color: layoutRow.selected ? Style.playerControlHoverBackground : rowMouseArea.containsMouse ? Style.playerPanelHoverBackground : "transparent"
            border.color: layoutRow.selected ? "#35ffffff" : "transparent"
            border.width: layoutRow.selected ? 1 : 0

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

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter

                width: Style.keyboardRadioSize
                height: Style.keyboardRadioSize
                radius: width / 2
                color: "transparent"
                border.color: layoutRow.selected ? Style.workspaceFocusedForeground : Style.moduleBorder
                border.width: 1

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 6
                    height: width
                    radius: width / 2
                    color: layoutRow.selected ? Style.workspaceFocusedForeground : "transparent"
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - Style.keyboardRadioSize - parent.spacing
                spacing: 1

                Text {
                    width: parent.width

                    text: keyboardRoot.formatLayoutLabel(layoutRow.layoutCode)
                    color: layoutRow.selected ? Style.workspaceFocusedForeground : Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: layoutRow.selected ? 700 : Style.fontWeight

                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: keyboardRoot.formatLayoutTitle(layoutRow.layoutCode)
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: rowMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: layoutRow.pressed()
        }
    }
}
