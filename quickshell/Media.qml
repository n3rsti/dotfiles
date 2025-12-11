import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "./components/"
import "./config"

Rectangle {
    id: mediaRoot
    color: "transparent"

    property var player: getPreferredPlayer()
    property alias mediaPopup: mediaPopup

    function getPreferredPlayer() {
        const players = Mpris.players.values;
        if (players.length === 0)
            return null;

        for (let i = 0; i < players.length; i++) {
            const identity = players[i].identity.toLowerCase();
            if (identity.includes("spotify")) {
                return players[i];
            }
        }

        for (let i = 0; i < players.length; i++) {
            const identity = players[i].identity.toLowerCase();
            if (identity.includes("firefox")) {
                return players[i];
            }
        }

        return players[0];
    }

    function getPlayerIcon() {
        if (!player)
            return "󰎈";
        const identity = player.identity.toLowerCase();
        if (identity.includes("spotify")) {
            return " ";
        } else if (identity.includes("firefox") || identity.includes("mozilla")) {
            return "󰈹 ";
        } else {
            return "󰎈";
        }
    }

    Component.onCompleted: {
        console.log("MPRIS players count:", Mpris.players.values.length);
        if (player) {
            console.log("Player:", player.identity);
            console.log("Title:", player.trackTitle);
            console.log("Artist:", player.trackArtist);
        }
    }

    function getMediaText() {
        if (!player || !player.trackTitle)
            return "No media playing";
        const title = player.trackTitle || "";
        const artist = player.trackArtist || "";
        let text = "";
        if (title && artist) {
            text = `${artist} - ${title}`;
        } else if (title) {
            text = title;
        } else if (artist) {
            text = artist;
        } else {
            return "No media playing";
        }

        if (text.length > 30) {
            return text.substring(0, 30) + "...";
        }
        return text;
    }

    implicitWidth: mediaRow.implicitWidth
    implicitHeight: mediaRow.implicitHeight

    Row {
        id: mediaRow
        spacing: Theme.smallSpacing * 2
        anchors.centerIn: parent

        TextComponent {
            id: mediaIcon
            text: mediaRoot.getPlayerIcon()
            anchors.verticalCenter: parent.verticalCenter
        }

        TextComponent {
            id: mediaText
            text: mediaRoot.getMediaText()
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Connections {
        target: mediaRoot.player
        function trackChanged() {
            mediaText.text = mediaRoot.getMediaText();
            mediaIcon.text = mediaRoot.getPlayerIcon();
        }
    }

    Connections {
        target: Mpris
        function onPlayersChanged() {
            console.log("Players changed, count:", Mpris.players.values.length);
            mediaRoot.player = mediaRoot.getPreferredPlayer();
            mediaText.text = mediaRoot.getMediaText();
            mediaIcon.text = mediaRoot.getPlayerIcon();
        }
    }

    MediaPopup {
        id: mediaPopup
        player: mediaRoot.player
        parentWindow: mediaRoot.QsWindow?.window
    }
}
