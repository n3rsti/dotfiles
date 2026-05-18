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
    property int nextToastId: 1
    property var notificationToasts: []

    function toastDurationMs(notification) {
        if (notification && notification.expireTimeout && notification.expireTimeout > 0)
            return Math.max(3000, Math.min(15000, notification.expireTimeout));

        return Style.notificationToastDurationMs;
    }

    function removeToast(toastId) {
        let result = [];

        for (let i = 0; i < notificationToasts.length; i++) {
            const entry = notificationToasts[i];

            if (entry && entry.toastId !== toastId)
                result.push(entry);
        }

        notificationToasts = result;
    }

    function removeToastForNotification(notificationId) {
        let result = [];

        for (let i = 0; i < notificationToasts.length; i++) {
            const entry = notificationToasts[i];

            if (entry && entry.notificationId !== notificationId)
                result.push(entry);
        }

        notificationToasts = result;
    }

    function pushToast(notification) {
        if (!notification || notificationsDnd)
            return;

        removeToastForNotification(notification.id);

        let result = notificationToasts.slice();

        result.unshift({
            "toastId": nextToastId++,
            "notificationId": notification.id,
            "notification": notification,
            "durationMs": toastDurationMs(notification)
        });

        if (result.length > Style.notificationToastMaxVisible)
            result = result.slice(0, Style.notificationToastMaxVisible);

        notificationToasts = result;
    }

    onNotificationsDndChanged: {
        if (notificationsDnd)
            notificationToasts = [];
    }

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

        onNotification: function (notification) {
            notification.tracked = true;
            shell.pushToast(notification);
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

                NotificationToasts {
                    anchorWindow: bar
                    toastEnabled: Quickshell.screens.length > 0 && bar.screen === Quickshell.screens[0]
                    toastEntries: shell.notificationToasts

                    onDismissToastRequested: function (toastId) {
                        shell.removeToast(toastId);
                    }

                    onDismissNotificationRequested: function (notification) {
                        if (notification)
                            notification.dismiss();
                    }
                }

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

                    RecordingModule {}
                }

                BarSection {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.edgeMargin
                    anchors.verticalCenter: parent.verticalCenter

                    BrightnessModule {
                        inhibitorWindow: bar
                    }

                    CoupledModules {
                        paddingX: 0
                        contentSpacing: -10

                        SoundModule {
                            inputMode: false
                        }

                        SoundModule {
                            inputMode: true
                        }
                    }

                    NetworkModule {}

                    BluetoothModule {}

                    NotificationsModule {
                        notificationServer: notificationServer
                        dnd: shell.notificationsDnd

                        onDndToggleRequested: {
                            shell.notificationsDnd = !shell.notificationsDnd;
                        }
                    }

                    BatteryModule {}

                    PowerMenuModule {}
                }
            }
        }
    }
}
