pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Services.Mpris
import ".."
import "../common"

Item {
    id: playerRoot

    readonly property var players: Mpris.players.values || []
    property string selectedPlayerDbusName: ""
    readonly property var selectedPlayer: playerForDbusName(selectedPlayerDbusName)
    readonly property var activePlayer: selectedPlayer !== null ? selectedPlayer : bestPlayer()
    readonly property bool hasPlayer: activePlayer !== null

    width: hasPlayer ? playerButton.width : 0
    height: hasPlayer ? playerButton.height : 0
    visible: hasPlayer

    onHasPlayerChanged: {
        if (!hasPlayer)
            playerPopup.visible = false;
    }

    function playerForDbusName(name) {
        if (!name || name.length === 0)
            return null;

        for (let i = 0; i < players.length; i++) {
            const player = players[i];

            if (player && player.dbusName === name)
                return player;
        }

        return null;
    }

    function bestPlayer() {
        for (let i = 0; i < players.length; i++) {
            const player = players[i];

            if (player && player.isPlaying)
                return player;
        }

        for (let i = 0; i < players.length; i++) {
            const player = players[i];

            if (player && player.playbackState !== MprisPlaybackState.Stopped)
                return player;
        }

        return players.length > 0 ? players[0] : null;
    }

    function playerName(player) {
        if (!player)
            return "Player";

        if (player.identity && player.identity.length > 0)
            return player.identity;

        if (player.desktopEntry && player.desktopEntry.length > 0)
            return player.desktopEntry;

        return "Player";
    }

    function sourceIcon(player) {
        if (!player)
            return Style.playerMusicIcon;

        const source = ((player.desktopEntry || "") + " " + (player.identity || "") + " " + (player.dbusName || "")).toLowerCase();

        if (source.includes("spotify"))
            return Style.playerSpotifyIcon;

        if (source.includes("firefox") || source.includes("librewolf") || source.includes("zen"))
            return Style.playerFirefoxIcon;

        return Style.playerMusicIcon;
    }

    function displayTitle(player) {
        if (!player)
            return "No media";

        const title = player.trackTitle && player.trackTitle.length > 0 ? player.trackTitle : "Unknown title";

        const artist = player.trackArtist && player.trackArtist.length > 0 ? player.trackArtist : "Unknown artist";

        return title + " - " + artist;
    }

    function truncated(text) {
        if (!text)
            return "";

        if (text.length <= Style.playerTextMaxChars)
            return text;

        return text.substring(0, Style.playerTextMaxChars - 1) + "…";
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds || 0));
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor((total % 3600) / 60);
        const secs = total % 60;

        if (hours > 0) {
            return hours + ":" + String(minutes).padStart(2, "0") + ":" + String(secs).padStart(2, "0");
        }

        return minutes + ":" + String(secs).padStart(2, "0");
    }

    function currentTime(player) {
        if (!player || !player.positionSupported)
            return "0:00";

        return formatTime(player.position);
    }

    function lengthTime(player) {
        if (!player || !player.lengthSupported)
            return "--:--";

        return formatTime(player.length);
    }

    function artUrl(player) {
        if (!player || !player.trackArtUrl)
            return "";

        return player.trackArtUrl;
    }

    function selectPlayer(player) {
        if (!player)
            return;

        selectedPlayerDbusName = player.dbusName;
        positionUpdater.restart();
    }

    function togglePopup() {
        playerPopup.visible = !playerPopup.visible;

        if (playerPopup.visible) {
            playerPopup.anchor.updateAnchor();
            positionUpdater.restart();
        }
    }

    Timer {
        id: positionUpdater

        interval: 1000
        repeat: true
        running: playerPopup.visible && playerRoot.activePlayer !== null && playerRoot.activePlayer.playbackState === MprisPlaybackState.Playing

        onTriggered: {
            if (playerRoot.activePlayer)
                playerRoot.activePlayer.positionChanged();
        }
    }

    ModuleBox {
        id: playerButton

        height: Style.moduleHeight
        paddingX: Style.modulePaddingX
        contentSpacing: 8

        width: Math.min(Style.playerButtonMaxWidth, Math.max(Style.playerButtonMinWidth, Style.modulePaddingX * 2 + playerSourceIcon.implicitWidth + contentSpacing + playerBarText.width))

        BarText {
            id: playerSourceIcon

            icon: true
            hovered: playerButton.hovered
            textPixelSize: Style.playerIconSize

            text: playerRoot.sourceIcon(playerRoot.activePlayer)
        }

        BarText {
            id: playerBarText

            width: Math.max(0, Math.min(implicitWidth, Style.playerButtonMaxWidth - Style.modulePaddingX * 2 - playerSourceIcon.implicitWidth - playerButton.contentSpacing))

            hovered: playerButton.hovered
            text: playerRoot.truncated(playerRoot.displayTitle(playerRoot.activePlayer))

            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: playerButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: playerRoot.togglePopup()
    }

    PopupWindow {
        id: playerPopup

        anchor {
            item: playerRoot
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: Style.popupGap
        }

        width: Math.min(Style.playerPopupMaxWidth, Math.max(Style.playerPopupMinWidth, playerPopupBackground.implicitWidth))

        height: playerPopupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                positionUpdater.restart();
        }

        Rectangle {
            id: playerPopupBackground

            anchors.fill: parent

            implicitWidth: playerPopupColumn.implicitWidth + Style.playerPopupPadding * 2
            implicitHeight: playerPopupColumn.implicitHeight + Style.playerPopupPadding * 2

            radius: Style.moduleRadius + 6
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: playerPopupColumn

                x: Style.playerPopupPadding
                y: Style.playerPopupPadding

                width: playerPopup.width - Style.playerPopupPadding * 2
                spacing: Style.playerSectionGap

                Flickable {
                    id: playerSourceSelector

                    visible: playerRoot.players.length > 1
                    width: parent.width
                    height: visible ? Style.playerSourceChipHeight : 0

                    contentWidth: playerSourceChipRow.implicitWidth
                    contentHeight: height

                    clip: true
                    interactive: contentWidth > width
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: playerSourceChipRow

                        height: playerSourceSelector.height
                        spacing: 8

                        Repeater {
                            model: playerRoot.players

                            PlayerSourceChip {
                                required property var modelData

                                player: modelData
                                iconText: playerRoot.sourceIcon(modelData)
                                titleText: playerRoot.playerName(modelData)

                                active: playerRoot.activePlayer !== null && modelData !== null && playerRoot.activePlayer.dbusName === modelData.dbusName

                                onClickedPlayer: function (player) {
                                    playerRoot.selectPlayer(player);
                                }
                            }
                        }
                    }
                }

                Row {
                    id: playerMainRow

                    width: parent.width
                    spacing: Style.playerMainGap
                    height: Math.max(artFrame.height, playerRightColumn.implicitHeight)

                    Rectangle {
                        id: artFrame

                        width: Style.playerPopupArtSize
                        height: Style.playerPopupArtSize
                        radius: 18
                        color: Style.playerPanelBackground
                        clip: true

                        Image {
                            id: trackArt

                            anchors.fill: parent

                            source: playerRoot.artUrl(playerRoot.activePlayer)
                            asynchronous: true
                            cache: true
                            fillMode: Image.PreserveAspectCrop

                            visible: playerRoot.artUrl(playerRoot.activePlayer).length > 0 && status === Image.Ready
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: trackArt.visible
                            color: "transparent"
                            border.color: "#20ffffff"
                            border.width: 1
                            radius: parent.radius
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: !trackArt.visible
                            text: Style.playerNoArtIcon
                            color: Style.popupMutedForeground

                            font.family: Style.iconFontFamily
                            font.pixelSize: 42
                            font.weight: Style.fontWeight
                        }
                    }

                    Column {
                        id: playerRightColumn

                        width: parent.width - artFrame.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Style.playerInfoGap

                        Row {
                            width: parent.width
                            height: Math.max(playerSmallSourceIcon.implicitHeight, playerSmallSourceName.implicitHeight)

                            spacing: 7

                            Text {
                                id: playerSmallSourceIcon

                                anchors.verticalCenter: parent.verticalCenter

                                text: playerRoot.sourceIcon(playerRoot.activePlayer)
                                color: Style.popupMutedForeground

                                font.family: Style.iconFontFamily
                                font.pixelSize: Style.playerIconSize
                                font.weight: Style.fontWeight
                            }

                            Text {
                                id: playerSmallSourceName

                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - playerSmallSourceIcon.width - parent.spacing

                                text: playerRoot.playerName(playerRoot.activePlayer)
                                color: Style.popupMutedForeground

                                font.family: Style.fontFamily
                                font.pixelSize: Style.popupSmallFontSize
                                font.weight: Style.fontWeight

                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            width: parent.width

                            text: playerRoot.activePlayer ? playerRoot.activePlayer.trackTitle || "Unknown title" : "No media"

                            color: Style.foreground

                            font.family: Style.fontFamily
                            font.pixelSize: 16
                            font.weight: 800

                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width

                            text: playerRoot.activePlayer ? playerRoot.activePlayer.trackArtist || "Unknown artist" : ""

                            color: Style.popupMutedForeground

                            font.family: Style.fontFamily
                            font.pixelSize: Style.fontSize
                            font.weight: Style.fontWeight

                            elide: Text.ElideRight
                        }

                        Item {
                            width: parent.width
                            height: 5
                        }

                        PlayerProgressSlider {
                            width: parent.width
                            player: playerRoot.activePlayer
                        }

                        Row {
                            width: parent.width
                            height: Math.max(positionText.implicitHeight, lengthText.implicitHeight)

                            Text {
                                id: positionText

                                width: parent.width / 2

                                text: playerRoot.currentTime(playerRoot.activePlayer)
                                color: Style.popupMutedForeground

                                font.family: Style.fontFamily
                                font.pixelSize: Style.popupSmallFontSize
                                font.weight: Style.fontWeight
                            }

                            Text {
                                id: lengthText

                                width: parent.width / 2

                                text: playerRoot.lengthTime(playerRoot.activePlayer)
                                color: Style.popupMutedForeground

                                font.family: Style.fontFamily
                                font.pixelSize: Style.popupSmallFontSize
                                font.weight: Style.fontWeight

                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        Item {
                            width: parent.width
                            height: 3
                        }

                        Row {
                            width: parent.width
                            height: Style.playerPrimaryControlButtonSize

                            Item {
                                width: parent.width
                                height: parent.height

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 16

                                    PlayerControlButton {
                                        iconText: Style.playerPreviousIcon
                                        usable: playerRoot.activePlayer !== null && playerRoot.activePlayer.canGoPrevious

                                        onPressed: {
                                            if (playerRoot.activePlayer)
                                                playerRoot.activePlayer.previous();
                                        }
                                    }

                                    PlayerControlButton {
                                        primary: true
                                        iconText: playerRoot.activePlayer !== null && playerRoot.activePlayer.isPlaying ? Style.playerPauseIcon : Style.playerPlayIcon

                                        usable: playerRoot.activePlayer !== null && playerRoot.activePlayer.canTogglePlaying

                                        onPressed: {
                                            if (playerRoot.activePlayer)
                                                playerRoot.activePlayer.togglePlaying();
                                        }
                                    }

                                    PlayerControlButton {
                                        iconText: Style.playerNextIcon
                                        usable: playerRoot.activePlayer !== null && playerRoot.activePlayer.canGoNext

                                        onPressed: {
                                            if (playerRoot.activePlayer)
                                                playerRoot.activePlayer.next();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component PlayerProgressSlider: Item {
        id: progressSlider

        required property var player

        readonly property real lengthSeconds: player !== null && player.lengthSupported ? player.length : 0
        readonly property real positionSeconds: player !== null && player.positionSupported ? player.position : 0
        readonly property real progress: lengthSeconds > 0 ? Math.max(0, Math.min(1, positionSeconds / lengthSeconds)) : 0

        readonly property bool seekable: player !== null && player.canSeek && player.positionSupported && lengthSeconds > 0

        height: Style.playerSliderHeight

        function seekFromX(xPosition) {
            if (!seekable)
                return;

            const ratio = Math.max(0, Math.min(1, xPosition / width));
            player.position = ratio * lengthSeconds;
            player.positionChanged();
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

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: progressTrack

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            height: Style.playerSliderTrackHeight
            radius: height / 2
            color: sliderMouseArea.containsMouse ? Style.playerSliderHoverTrack : Style.playerSliderTrack

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors {
                left: progressTrack.left
                verticalCenter: progressTrack.verticalCenter
            }

            width: progressTrack.width * progressSlider.progress
            height: progressTrack.height
            radius: height / 2
            color: sliderMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

            Behavior on width {
                NumberAnimation {
                    duration: 90
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: progressThumb

            anchors.verticalCenter: progressTrack.verticalCenter
            x: Math.max(0, Math.min(parent.width - width, progressTrack.width * progressSlider.progress - width / 2))

            width: sliderMouseArea.containsMouse || sliderMouseArea.pressed ? Style.playerSliderThumbHoverSize : Style.playerSliderThumbSize

            height: width
            radius: width / 2
            color: sliderMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

            opacity: progressSlider.seekable ? 1 : 0.35

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: sliderMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: progressSlider.seekable ? Qt.PointingHandCursor : Qt.ArrowCursor

            onPressed: function (mouse) {
                progressSlider.seekFromX(mouse.x);
            }

            onPositionChanged: function (mouse) {
                if (pressed)
                    progressSlider.seekFromX(mouse.x);
            }
        }
    }

    component PlayerControlButton: Item {
        id: controlButton

        required property string iconText
        property bool usable: true
        property bool primary: false

        signal pressed

        width: primary ? Style.playerPrimaryControlButtonSize : Style.playerControlButtonSize
        height: width

        scale: controlMouseArea.containsMouse && usable ? 1.07 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: width / 2
            color: controlMouseArea.containsMouse && controlButton.usable ? Style.playerControlHoverBackground : Style.playerControlBackground

            border.color: controlButton.primary ? "#35ffffff" : "transparent"
            border.width: controlButton.primary ? 1 : 0

            opacity: controlButton.usable ? 1 : 0.35

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            anchors.centerIn: parent

            text: controlButton.iconText
            color: controlMouseArea.containsMouse && controlButton.usable ? Style.foregroundHover : Style.foreground

            font.family: Style.iconFontFamily
            font.pixelSize: controlButton.primary ? 21 : 18
            font.weight: Style.fontWeight
        }

        MouseArea {
            id: controlMouseArea

            anchors.fill: parent
            enabled: controlButton.usable
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: controlButton.pressed()
        }
    }

    component PlayerSourceChip: Item {
        id: sourceChip

        required property var player
        required property string iconText
        required property string titleText
        property bool active: false

        signal clickedPlayer(var player)

        width: Math.min(Style.playerSourceChipMaxWidth, Math.max(Style.playerSourceChipMinWidth, sourceIconText.implicitWidth + sourceNameText.implicitWidth + Style.playerSourceChipPaddingX * 2 + 8))

        height: Style.playerSourceChipHeight
        scale: sourceChipMouseArea.containsMouse ? 1.03 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: sourceChip.active ? Style.playerControlHoverBackground : sourceChipMouseArea.containsMouse ? Style.playerPanelHoverBackground : Style.playerPanelBackground

            border.color: sourceChip.active ? "#35ffffff" : "transparent"
            border.width: sourceChip.active ? 1 : 0

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
                leftMargin: Style.playerSourceChipPaddingX
                rightMargin: Style.playerSourceChipPaddingX
            }

            spacing: 8

            Text {
                id: sourceIconText

                anchors.verticalCenter: parent.verticalCenter

                text: sourceChip.iconText
                color: sourceChip.active ? Style.workspaceFocusedForeground : Style.popupMutedForeground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.playerIconSize
                font.weight: Style.fontWeight
            }

            Text {
                id: sourceNameText

                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - sourceIconText.width - parent.spacing

                text: sourceChip.titleText
                color: sourceChip.active ? Style.workspaceFocusedForeground : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.popupSmallFontSize
                font.weight: sourceChip.active ? 700 : Style.fontWeight

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: sourceChipMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: sourceChip.clickedPlayer(sourceChip.player)
        }
    }
}
