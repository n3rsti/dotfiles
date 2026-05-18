pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."

Item {
    id: toastRoot

    required property var toastEntries
    property bool toastEnabled: true

    signal dismissToastRequested(int toastId)
    signal dismissNotificationRequested(var notification)

    width: 0
    height: 0

    function directImageSource(value) {
        if (!value || value.length === 0)
            return "";

        if (value.startsWith("image://"))
            return value;

        if (value.startsWith("file://"))
            return value;

        if (value.startsWith("/"))
            return "file://" + value;

        return "";
    }

    function iconSource(value) {
        if (!value || value.length === 0)
            return "";

        const direct = directImageSource(value);

        if (direct.length > 0)
            return direct;

        return Quickshell.iconPath(value, true);
    }

    function appIconSource(notification) {
        if (!notification)
            return "";

        let source = iconSource(notification.appIcon);

        if (source.length > 0)
            return source;

        source = iconSource(notification.desktopEntry);

        if (source.length > 0)
            return source;

        source = iconSource(notification.appName);

        if (source.length > 0)
            return source;

        return "";
    }

    function imageSource(notification) {
        if (!notification || !notification.image || notification.image.length === 0)
            return "";

        return directImageSource(notification.image);
    }

    function appName(notification) {
        if (!notification)
            return "Application";

        if (notification.appName && notification.appName.length > 0)
            return notification.appName;

        if (notification.desktopEntry && notification.desktopEntry.length > 0)
            return notification.desktopEntry;

        return "Application";
    }

    function summary(notification) {
        if (!notification)
            return "Notification";

        if (notification.summary && notification.summary.length > 0)
            return notification.summary;

        return "Notification";
    }

    function body(notification) {
        if (!notification || !notification.body)
            return "";

        return notification.body;
    }

    PopupWindow {
        id: toastWindow

        anchor {
            item: toastRoot
            edges: Edges.Top | Edges.Right
            gravity: Edges.Top | Edges.Right
            margins.top: Style.barHeight + Style.popupGap
            margins.right: Style.edgeMargin
        }

        width: Style.notificationToastWidth
        height: toastBackground.implicitHeight

        color: "transparent"
        visible: toastRoot.toastEnabled && toastRoot.toastEntries.length > 0

        Rectangle {
            id: toastBackground

            anchors.fill: parent
            color: "transparent"

            implicitWidth: Style.notificationToastWidth
            implicitHeight: toastColumn.implicitHeight + Style.notificationToastHoverMargin * 2

            Column {
                id: toastColumn

                x: Style.notificationToastHoverMargin
                y: Style.notificationToastHoverMargin
                width: Style.notificationToastWidth - Style.notificationToastHoverMargin * 2
                spacing: Style.notificationToastGap

                Repeater {
                    model: toastRoot.toastEntries

                    ToastCard {
                        required property var modelData

                        toastEntry: modelData

                        onCloseRequested: function(toastId, notification) {
                            toastRoot.dismissToastRequested(toastId);

                            if (notification)
                                toastRoot.dismissNotificationRequested(notification);
                        }

                        onTimeoutRequested: function(toastId) {
                            toastRoot.dismissToastRequested(toastId);
                        }
                    }
                }
            }
        }
    }

    component ToastCard: Item {
        id: toastCard

        required property var toastEntry

        readonly property var notification: toastEntry ? toastEntry.notification : null
        readonly property string previewSource: toastRoot.imageSource(notification)
        readonly property bool hasPreview: previewSource.length > 0

        signal closeRequested(int toastId, var notification)
        signal timeoutRequested(int toastId)

        width: toastColumn.width
        height: Math.max(72, toastContent.implicitHeight + Style.notificationToastPadding * 2)
        opacity: 1
        scale: toastHover.hovered ? 1.01 : 1.0

        HoverHandler {
            id: toastHover
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Timer {
            interval: toastEntry && toastEntry.durationMs > 0 ? toastEntry.durationMs : Style.notificationToastDurationMs
            repeat: false
            running: toastCard.notification !== null && !toastHover.hovered

            onTriggered: toastCard.timeoutRequested(toastEntry.toastId)
        }

        Rectangle {
            anchors.fill: parent

            radius: Style.notificationCardRadius
            color: toastHover.hovered ? Style.notificationToastHoverBackground : Style.notificationToastBackground
            border.color: notification !== null && notification.urgency === NotificationUrgency.Critical ? Style.workspaceUrgentForeground : Style.moduleBorder
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor

            onClicked: toastRoot.dismissToastRequested(toastEntry.toastId)
        }

        Row {
            id: toastContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Style.notificationToastPadding
            }

            spacing: 10

            Rectangle {
                width: hasPreview ? Style.notificationToastImageSize : Style.notificationToastAppIconSize
                height: width
                radius: hasPreview ? 10 : 8
                color: Style.playerControlBackground
                clip: true

                Image {
                    anchors.fill: parent
                    source: previewSource
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: hasPreview
                }

                IconImage {
                    anchors.centerIn: parent

                    width: parent.width - 6
                    height: parent.height - 6
                    implicitSize: parent.width - 6

                    source: toastRoot.appIconSource(notification)
                    asynchronous: true
                    mipmap: true
                    visible: !hasPreview

                    backer.fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                width: parent.width - (hasPreview ? Style.notificationToastImageSize : Style.notificationToastAppIconSize) - toastCloseButton.width - parent.spacing * 2
                spacing: 3

                Text {
                    width: parent.width

                    text: toastRoot.appName(notification)
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: 700

                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    text: toastRoot.summary(notification)
                    color: Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: 800

                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                Text {
                    width: parent.width

                    text: toastRoot.body(notification)
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    visible: text.length > 0
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }
            }

            ToastCloseButton {
                id: toastCloseButton

                onPressed: toastCard.closeRequested(toastEntry.toastId, toastCard.notification)
            }
        }
    }

    component ToastCloseButton: Item {
        id: iconButton

        signal pressed

        width: Style.notificationCloseButtonSize
        height: Style.notificationCloseButtonSize

        Rectangle {
            anchors.fill: parent

            radius: width / 2
            color: closeMouseArea.containsMouse ? Style.playerControlHoverBackground : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            anchors.centerIn: parent

            text: Style.notificationCloseIcon
            color: closeMouseArea.containsMouse ? Style.foregroundHover : Style.popupMutedForeground

            font.family: Style.iconFontFamily
            font.pixelSize: Style.notificationIconSize
            font.weight: Style.fontWeight
        }

        MouseArea {
            id: closeMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: iconButton.pressed()
        }
    }
}
