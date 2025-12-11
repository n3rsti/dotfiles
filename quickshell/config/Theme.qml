pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#191b26"
    readonly property color focusBackground: "#1b1b23"
    readonly property color containerBackground: "#000008"
    readonly property color hoverBackground: "#11111b"
    readonly property color textColor: "#c0caf5"
    readonly property color accentColor: "#4a9eff"
    readonly property color surfaceColor: "#3c3c3c"

    readonly property int padding: 10
    readonly property int spacing: 10
    readonly property int smallSpacing: 4

    readonly property int radius: 12
    readonly property int smallRadius: 4

    readonly property real backgroundOpacity: 0.5
    readonly property real fullOpacity: 1.0

    readonly property string fontFamily: "Adwaita Sans"
    readonly property int fontSize: 12
    readonly property int fontWeight: 500

    readonly property int barHeight: 40
    readonly property int iconSize: 16
    readonly property int workspaceButtonWidth: 40
}
