import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "./components/"
import "./config"

Rectangle {
    id: mediaRoot
    color: "transparent"

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

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
        if (title && artist) {
            return `${artist} - ${title}`;
        } else if (title) {
            return title;
        } else if (artist) {
            return artist;
        }
        return "No media playing";
    }

    TextComponent {
        id: mediaText
        text: mediaRoot.getMediaText()
        anchors.centerIn: parent
    }

    Connections {
        target: mediaRoot.player
        function onTrackChanged() {
            mediaText.text = mediaRoot.getMediaText();
        }
    }

    Connections {
        target: Mpris
        function onPlayersChanged() {
            console.log("Players changed, count:", Mpris.players.values.length);
            mediaRoot.player = Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
            mediaText.text = mediaRoot.getMediaText();
        }
    }
}
