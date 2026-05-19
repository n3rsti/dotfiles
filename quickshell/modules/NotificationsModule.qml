pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."
import "../common"

Item {
    id: notificationRoot

    required property var notificationServer
    property bool dnd: false
    property bool useBackground: true
    property bool blockGenericPlaceholderNotifications: true

    signal dndToggleRequested

    readonly property var notifications: sortedNotifications()
    readonly property int notificationCount: notifications.length

    width: notificationButton.width
    height: notificationButton.height

    function hasText(value) {
        return value !== undefined && value !== null && String(value).trim().length > 0;
    }

    function isGenericPlaceholderNotification(notification) {
        if (!blockGenericPlaceholderNotifications || !notification)
            return false;

        return !hasText(notification.appName)
            && !hasText(notification.desktopEntry)
            && !hasText(notification.summary)
            && !hasText(notification.body);
    }

    function shouldDisplayNotification(notification) {
        if (!notification)
            return false;

        if (isGenericPlaceholderNotification(notification))
            return false;

        return true;
    }

    function sortedNotifications() {
        const values = notificationRoot.notificationServer.trackedNotifications.values || [];
        let result = [];

        for (let i = 0; i < values.length; i++) {
            const notification = values[i];

            if (!notification)
                continue;

            if (!shouldDisplayNotification(notification))
                continue;

            result.push(notification);
        }

        result.sort((a, b) => b.id - a.id);
        return result;
    }

    function statusIcon() {
        if (notificationRoot.dnd)
            return Style.notificationDndIcon;

        if (notificationCount > 0)
            return Style.notificationSomeIcon;

        return Style.notificationNoneIcon;
    }

    function statusTitle() {
        if (notificationRoot.dnd)
            return "Do Not Disturb";

        if (notificationCount === 0)
            return "No notifications";

        if (notificationCount === 1)
            return "1 notification";

        return notificationCount + " notifications";
    }

    function statusDetail() {
        if (notificationRoot.dnd)
            return "Notifications are collected silently.";

        if (notificationCount === 0)
            return "You are all caught up.";

        return "Recent notifications are shown below.";
    }

    function clearAll() {
        const values = notifications;

        for (let i = 0; i < values.length; i++) {
            const notification = values[i];

            if (notification)
                notification.dismiss();
        }
    }

    function dismissNotification(notification) {
        if (notification)
            notification.dismiss();
    }

    function primaryAction(notification) {
        if (!notification || !notification.actions)
            return null;

        const actions = notification.actions;

        for (let i = 0; i < actions.length; i++) {
            const action = actions[i];

            if (action && action.identifier === "default")
                return action;
        }

        return actions.length > 0 ? actions[0] : null;
    }

    function activateNotification(notification) {
        const action = primaryAction(notification);

        if (!action)
            return false;

        action.invoke();
        return true;
    }

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

    function notificationImageSource(notification) {
        if (!notification || !notification.image || notification.image.length === 0)
            return "";

        return directImageSource(notification.image);
    }

    function appIconSource(notification) {
        if (!notification)
            return "";

        let source = iconSource(notification.appIcon);

        if (source.length > 0)
            return source;

        source = iconSource(notification.image);

        if (source.length > 0)
            return source;

        source = iconSource(notification.desktopEntry);

        if (source.length > 0)
            return source;

        source = iconSource(notification.appName);

        if (source.length > 0)
            return source;

        if (notification.desktopEntry && notification.desktopEntry.length > 0) {
            source = iconSource(notification.desktopEntry + ".desktop");

            if (source.length > 0)
                return source;
        }

        return "";
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

    function urgencyLabel(notification) {
        if (!notification)
            return "";

        if (notification.urgency === NotificationUrgency.Critical)
            return "Critical";

        if (notification.urgency === NotificationUrgency.Low)
            return "Low";

        return "";
    }

    function togglePopup() {
        notificationPopup.visible = !notificationPopup.visible;

        if (notificationPopup.visible)
            notificationPopup.anchor.updateAnchor();
    }

    ModuleBox {
        id: notificationButton

        width: Style.notificationButtonWidth
        height: Style.moduleHeight
        paddingX: 0
        useBackground: notificationRoot.useBackground

        BarText {
            icon: true
            hovered: notificationButton.hovered
            textPixelSize: Style.notificationIconSize

            text: notificationRoot.statusIcon()
        }
    }

    MouseArea {
        anchors.fill: notificationButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: notificationRoot.togglePopup()
    }

    PopupWindow {
        id: notificationPopup

        anchor {
            item: notificationRoot
            edges: Edges.Bottom | Edges.Right
            gravity: Edges.Bottom | Edges.Left
            margins.top: Style.popupGap
        }

        width: Math.min(Style.notificationPopupMaxWidth, Math.max(Style.notificationPopupMinWidth, notificationPopupBackground.implicitWidth))

        height: notificationPopupBackground.implicitHeight

        color: "transparent"
        visible: false
        grabFocus: true

        Rectangle {
            id: notificationPopupBackground

            anchors.fill: parent

            implicitWidth: notificationPopupColumn.implicitWidth + Style.notificationPopupPadding * 2
            implicitHeight: notificationPopupColumn.implicitHeight + Style.notificationPopupPadding * 2

            radius: Style.moduleRadius + 6
            color: Style.popupBackground
            border.color: Style.popupBorder
            border.width: Style.borderWidth

            Column {
                id: notificationPopupColumn

                x: Style.notificationPopupPadding
                y: Style.notificationPopupPadding

                width: notificationPopup.width - Style.notificationPopupPadding * 2
                spacing: Style.notificationSectionGap

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        width: parent.width

                        text: "Notifications"
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: Style.fontWeight
                    }

                    Text {
                        width: parent.width

                        text: notificationRoot.statusTitle()
                        color: Style.foreground

                        font.family: Style.fontFamily
                        font.pixelSize: 15
                        font.weight: 800

                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: notificationRoot.statusDetail()
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        elide: Text.ElideRight
                    }
                }

                Row {
                    width: parent.width
                    height: Style.notificationActionButtonHeight
                    spacing: 10

                    NotificationPillButton {
                        width: (parent.width - parent.spacing) / 2

                        labelText: "Clear all"
                        iconText: Style.notificationClearIcon
                        usable: notificationRoot.notificationCount > 0

                        onPressed: notificationRoot.clearAll()
                    }

                    NotificationDndSwitch {
                        width: (parent.width - parent.spacing) / 2
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Style.moduleBorder
                    opacity: 0.9
                }

                Flickable {
                    id: notificationFlickable

                    readonly property bool empty: notificationRoot.notificationCount === 0

                    width: parent.width
                    height: empty ? 96 : Math.min(Style.notificationListMaxHeight, notificationListColumn.implicitHeight)

                    contentWidth: width
                    contentHeight: empty ? height : notificationListColumn.implicitHeight
                    clip: true
                    interactive: !empty && contentHeight > height
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: notificationListColumn

                        width: notificationFlickable.width
                        spacing: 8
                        visible: !notificationFlickable.empty

                        Repeater {
                            model: notificationRoot.notifications

                            NotificationCard {
                                required property var modelData

                                notification: modelData
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 28

                        visible: notificationFlickable.empty

                        text: notificationRoot.dnd ? "No notifications. Do Not Disturb is enabled." : "No notifications."

                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSize
                        font.weight: Style.fontWeight

                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    component NotificationCard: Item {
        id: notificationCard

        required property var notification

        width: parent ? parent.width : Style.notificationPopupMinWidth
        height: Math.max(Style.notificationCardMinHeight, notificationContent.implicitHeight + Style.notificationCardPadding * 2)

        HoverHandler {
            id: cardHover
        }

        Rectangle {
            anchors.fill: parent

            radius: Style.notificationCardRadius
            color: cardHover.hovered ? Style.playerPanelHoverBackground : Style.playerPanelBackground

            border.color: notification !== null && notification.urgency === NotificationUrgency.Critical ? Style.workspaceUrgentForeground : "transparent"

            border.width: notification !== null && notification.urgency === NotificationUrgency.Critical ? 1 : 0

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
            cursorShape: notificationRoot.primaryAction(notification) !== null ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (notificationRoot.activateNotification(notification))
                    notificationPopup.visible = false;
            }
        }

        Row {
            id: notificationContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Style.notificationCardPadding
            }

            spacing: 10

            Rectangle {
                width: Style.notificationAppIconSize
                height: Style.notificationAppIconSize
                radius: 9
                color: Style.playerControlBackground
                clip: true

                IconImage {
                    id: notificationAppIcon

                    anchors.centerIn: parent

                    width: Style.notificationAppIconSize - 6
                    height: Style.notificationAppIconSize - 6
                    implicitSize: Style.notificationAppIconSize - 6

                    source: notificationRoot.appIconSource(notification)
                    asynchronous: true
                    mipmap: true

                    backer.fillMode: Image.PreserveAspectFit
                }
            }

            Column {
                width: parent.width - Style.notificationAppIconSize - notificationCloseButton.width - parent.spacing * 2

                spacing: 3

                Row {
                    width: parent.width
                    height: Math.max(appNameText.implicitHeight, urgencyText.implicitHeight)

                    Text {
                        id: appNameText

                        anchors.verticalCenter: parent.verticalCenter

                        width: parent.width - urgencyText.implicitWidth - 8

                        text: notificationRoot.appName(notification)
                        color: Style.popupMutedForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: 700

                        elide: Text.ElideRight
                    }

                    Text {
                        id: urgencyText

                        anchors.verticalCenter: parent.verticalCenter

                        text: notificationRoot.urgencyLabel(notification)
                        color: Style.workspaceUrgentForeground

                        font.family: Style.fontFamily
                        font.pixelSize: Style.popupSmallFontSize
                        font.weight: 700

                        visible: text.length > 0
                    }
                }

                Text {
                    width: parent.width

                    text: notificationRoot.summary(notification)
                    color: Style.foreground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSize
                    font.weight: 800

                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }

                Text {
                    width: parent.width

                    text: notificationRoot.body(notification)
                    color: Style.popupMutedForeground

                    font.family: Style.fontFamily
                    font.pixelSize: Style.popupSmallFontSize
                    font.weight: Style.fontWeight

                    visible: text.length > 0
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }
            }

            NotificationIconButton {
                id: notificationCloseButton

                iconText: Style.notificationCloseIcon
                visibleOpacity: cardHover.hovered ? 1 : 0

                onPressed: notificationRoot.dismissNotification(notification)
            }
        }
    }

    component NotificationIconButton: Item {
        id: iconButton

        required property string iconText
        property real visibleOpacity: 1

        signal pressed

        width: Style.notificationCloseButtonSize
        height: Style.notificationCloseButtonSize

        opacity: visibleOpacity

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

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

            text: iconButton.iconText
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

    component NotificationPillButton: Item {
        id: pillButton

        required property string labelText
        required property string iconText
        property bool usable: true

        signal pressed

        height: Style.notificationActionButtonHeight
        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: pillMouseArea.containsMouse && pillButton.usable ? Style.playerControlHoverBackground : Style.playerPanelBackground

            opacity: pillButton.usable ? 1 : 0.45

            Behavior on color {
                ColorAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: pillButton.iconText
                color: pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground

                font.family: Style.iconFontFamily
                font.pixelSize: Style.notificationIconSize
                font.weight: Style.fontWeight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: pillButton.labelText
                color: pillMouseArea.containsMouse && pillButton.usable ? Style.foregroundHover : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: 700
            }
        }

        MouseArea {
            id: pillMouseArea

            anchors.fill: parent
            enabled: pillButton.usable
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: pillButton.pressed()
        }
    }

    component NotificationDndSwitch: Item {
        id: dndSwitch

        height: Style.notificationActionButtonHeight

        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: dndMouseArea.containsMouse ? Style.playerControlHoverBackground : Style.playerPanelBackground

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
                rightMargin: 10
            }

            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - Style.notificationToggleWidth - parent.spacing

                text: "Do Not Disturb"
                color: dndMouseArea.containsMouse ? Style.foregroundHover : Style.foreground

                font.family: Style.fontFamily
                font.pixelSize: Style.fontSize
                font.weight: 700

                elide: Text.ElideRight
            }

            Rectangle {
                id: toggleTrack

                anchors.verticalCenter: parent.verticalCenter

                width: Style.notificationToggleWidth
                height: Style.notificationToggleHeight
                radius: height / 2

                color: notificationRoot.dnd ? Style.playerControlHoverBackground : Style.moduleBorder

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    width: toggleTrack.height - 6
                    height: width
                    radius: width / 2

                    x: notificationRoot.dnd ? toggleTrack.width - width - 3 : 3

                    anchors.verticalCenter: parent.verticalCenter

                    color: notificationRoot.dnd ? Style.foreground : Style.popupMutedForeground

                    Behavior on x {
                        NumberAnimation {
                            duration: 140
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
            }
        }

        MouseArea {
            id: dndMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: notificationRoot.dndToggleRequested()
        }
    }
}
