//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "."
import "common"
import "modules"

ShellRoot {
    id: shell

    property bool notificationsDnd: false

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    NotificationServer {
        id: notificationServer

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        inlineReplySupported: false

        onNotification: function(notification) {
            notification.tracked = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            screen: modelData

            color: "transparent"
            surfaceFormat.opaque: false

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Style.barHeight
            exclusiveZone: Style.barHeight

            Item {
                anchors.fill: parent

                BarSection {
                    anchors.left: parent.left
                    anchors.leftMargin: Style.edgeMargin
                    anchors.verticalCenter: parent.verticalCenter

                    WorkspacesModule {
                        shellScreen: bar.screen
                    }

                    TrayModule {}
                }

                BarSection {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    PlayerModule {}

                    ClockModule {
                        clock: clock
                    }
                }

                BarSection {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.edgeMargin
                    anchors.verticalCenter: parent.verticalCenter

                    NotificationsModule {
                        notificationServer: notificationServer
                        dnd: shell.notificationsDnd

                        onDndToggleRequested: {
                            shell.notificationsDnd = !shell.notificationsDnd;
                        }
                    }

                    BluetoothModule {}

                    SoundModule {
                        inputMode: true
                    }

                    SoundModule {
                        inputMode: false
                    }

                    NetworkModule {}
                }
            }
        }
    }
}
