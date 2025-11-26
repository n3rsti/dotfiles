import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.Widgets
import QtQuick.Controls
import "./components/"

Menu {

    Action {
        text: "Cut"
    }
    Action {
        text: "Copy"
    }
    Action {
        text: "Paste"
    }

    MenuSeparator {}

    Menu {
        title: "Find/Replace"
        Action {
            text: "Find Next"
        }
        Action {
            text: "Find Previous"
        }
        Action {
            text: "Replace"
        }
    }
}
