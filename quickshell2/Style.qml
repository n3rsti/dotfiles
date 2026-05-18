pragma Singleton

import QtQuick
import QtQml

QtObject {

    // Bar geometry
    property int barHeight: 45
    property int edgeMargin: 15
    property int moduleGap: 5

    // Module geometry
    property int moduleHeight: 36
    property int moduleRadius: 13
    property int modulePaddingX: 14
    property int trayPaddingX: 15
    property int moduleContentYOffset: 0
    property int trayIconYOffset: 0

    // Workspaces
    property bool workspacesAllOutputs: true
    property bool workspaceShowNamed: false
    property bool workspaceUseNames: false
    property int workspaceButtonMinWidth: 24
    property int workspaceButtonPaddingX: 14
    property int workspaceButtonGap: 0
    property int workspaceModulePaddingX: 5
    property int workspaceFontSize: 13
    property int workspaceFocusedFontWeight: 600

    // Tray
    property int trayIconSize: 17
    property int trayIconButtonSize: 20
    property int trayIconGap: 13

    // Player module
    property int playerButtonMinWidth: 0
    property int playerButtonMaxWidth: 200
    property int playerIconSize: 16
    property int playerTextMaxChars: 42

    // Player popup
    property int playerPopupMinWidth: 610
    property int playerPopupMaxWidth: 760
    property int playerPopupPadding: 18
    property int playerPopupArtSize: 150
    property int playerMainGap: 18
    property int playerSectionGap: 15
    property int playerInfoGap: 8

    // Player controls
    property int playerControlButtonSize: 38
    property int playerPrimaryControlButtonSize: 48
    property int playerSliderHeight: 26
    property int playerSliderTrackHeight: 5
    property int playerSliderThumbSize: 10
    property int playerSliderThumbHoverSize: 15

    // Player source selector
    property int playerSourceChipHeight: 32
    property int playerSourceChipMinWidth: 116
    property int playerSourceChipMaxWidth: 190
    property int playerSourceChipPaddingX: 12

    // Notifications module
    property int notificationButtonWidth: 42
    property int notificationIconSize: 20

    // Notifications popup
    property int notificationPopupMinWidth: 430
    property int notificationPopupMaxWidth: 560
    property int notificationPopupPadding: 18
    property int notificationSectionGap: 15
    property int notificationListMaxHeight: 360
    property int notificationCardMinHeight: 76
    property int notificationCardRadius: 16
    property int notificationCardPadding: 12
    property int notificationAppIconSize: 32
    property int notificationCloseButtonSize: 24
    property int notificationActionButtonHeight: 34
    property int notificationToggleWidth: 52
    property int notificationToggleHeight: 28

    // Notification toasts
    property int notificationToastWidth: 360
    property int notificationToastGap: 8
    property int notificationToastPadding: 12
    property int notificationToastImageSize: 52
    property int notificationToastAppIconSize: 30
    property int notificationToastMaxVisible: 4
    property int notificationToastDurationMs: 8000
    property int notificationToastHoverMargin: 4
    property int notificationToastImagePadding: 4

    // Bluetooth module
    property int bluetoothButtonWidth: 42
    property int bluetoothIconSize: 20

    // Bluetooth popup
    property int bluetoothPopupMinWidth: 430
    property int bluetoothPopupMaxWidth: 540
    property int bluetoothPopupPadding: 18
    property int bluetoothSectionGap: 15
    property int bluetoothDeviceRowHeight: 46
    property int bluetoothDeviceListMaxHeight: 260
    property int bluetoothSettingsButtonHeight: 36
    property int bluetoothToggleButtonHeight: 36
    property int bluetoothDeviceIconSize: 20

    // Input module
    property int inputButtonMinWidth: 70
    property int inputIconSize: 14
    property real inputMaxVolume: 1.5

    // Input popup
    property int inputPopupMinWidth: 430
    property int inputPopupMaxWidth: 540
    property int inputPopupPadding: 18
    property int inputSectionGap: 15
    property int inputSliderHeight: 28
    property int inputSliderTrackHeight: 5
    property int inputSliderThumbSize: 10
    property int inputSliderThumbHoverSize: 15
    property int inputSourceRowHeight: 42
    property int inputSourceListMaxHeight: 220
    property int inputRoundButtonSize: 38
    property int inputSettingsButtonHeight: 36

    // Audio module
    property int audioButtonMinWidth: 70
    property int audioIconSize: 16
    property real audioMaxVolume: 1.5

    // Audio popup
    property int audioPopupMinWidth: 430
    property int audioPopupMaxWidth: 540
    property int audioPopupPadding: 18
    property int audioSectionGap: 15
    property int audioSliderHeight: 28
    property int audioSliderTrackHeight: 5
    property int audioSliderThumbSize: 10
    property int audioSliderThumbHoverSize: 15
    property int audioOutputRowHeight: 42
    property int audioOutputListMaxHeight: 220
    property int audioRoundButtonSize: 38
    property int audioSettingsButtonHeight: 36

    // Network module
    property int networkButtonWidth: 42
    property int networkIconSize: 20
    property bool networkWifiScanAlways: false
    property int networkWifiRefreshIntervalMs: 10000

    // Power menu module
    property int powerButtonWidth: 34
    property int powerIconSize: 13
    property int powerPopupMinWidth: 300
    property int powerPopupMaxWidth: 360
    property int powerPopupPadding: 14
    property int powerPopupSectionGap: 12
    property int powerRowHeight: 42
    property int powerConfirmWidth: 104

    // Recording module
    property int recordingIconSize: 14
    property color recordingForeground: "#ff5555"

    // Brightness module
    property int brightnessIconSize: 20
    property color brightnessNightForeground: "#ffb86c"
    property color brightnessActiveBackground: "#c0caf5"
    property color brightnessActiveForeground: "#cc000008"
    property color brightnessActiveHoverForeground: "#99000008"
    property color brightnessActiveBorder: "#c0caf5"
    property int brightnessActiveFontWeight: 700
    property int brightnessPopupMinWidth: 280
    property int brightnessPopupMaxWidth: 340
    property int brightnessPopupPadding: 14
    property int brightnessPopupSectionGap: 12
    property int brightnessButtonHeight: 36
    property int brightnessSecondaryButtonHeight: 36
    property color brightnessToggleActiveBackground: "#c0caf5"
    property color brightnessToggleActiveHoverBackground: "#b4bfe8"
    property color brightnessToggleActiveForeground: "#cc000008"
    property color brightnessToggleActiveHoverForeground: "#99000008"

    // Battery module
    property int batteryIconSize: 18
    property int batteryButtonMinWidth: 74
    property int batteryPopupMinWidth: 300
    property int batteryPopupMaxWidth: 360
    property int batteryPopupPadding: 14
    property int batteryPopupSectionGap: 12
    property int batteryStatRowHeight: 34

    // Network popup
    property int popupGap: 8
    property int networkPopupMinWidth: 300
    property int networkPopupMaxWidth: 420
    property int networkPopupPadding: 18
    property int networkPopupHeaderSpacing: 15
    property int networkListMaxHeight: 340
    property int networkEmptyStateMinHeight: 76
    property int networkEmptyStatePaddingY: 18
    property int networkRowHeight: 34
    property int networkRowRadius: 10
    property int networkRowPaddingX: 10

    // Colors
    property color foreground: "#c0caf5"
    property color foregroundHover: "#a0aad5"
    property color moduleBackground: "#99000008"
    property color moduleBorder: "#34344d"
    property color moduleHoverOverlay: "#1425252d"

    // Workspace colors
    property color workspaceFocusedBackground: "#cc25252d"
    property color workspaceFocusedForeground: "#d0daff"
    property color workspaceOccupiedForeground: "#c0caf5"
    property color workspaceUrgentForeground: "#ff5555"

    // Popup colors
    property color popupBackground: "#ee000008"
    property color popupBorder: "#34344d"
    property color popupRowHover: "#2625252d"
    property color popupMutedForeground: "#a0aad5"
    property color notificationToastBackground: "#cc000008"
    property color notificationToastHoverBackground: "#cc25252d"

    // macOS-ish popup controls
    property color playerPanelBackground: "#2025252d"
    property color playerPanelHoverBackground: "#3025252d"
    property color playerControlBackground: "#2225252d"
    property color playerControlHoverBackground: "#3a34344d"
    property color playerSliderTrack: "#34344d"
    property color playerSliderHoverTrack: "#45455f"

    // Borders
    property int borderWidth: 1

    // Font
    property string fontFamily: "Adwaita Sans"
    property string iconFontFamily: "Symbols Nerd Font Mono"
    property int fontSize: 12
    property int fontWeight: 500
    property int popupTitleFontSize: 13
    property int popupSmallFontSize: 11

    // Nerd Font player icons
    property string playerFirefoxIcon: "󰈹"
    property string playerSpotifyIcon: "󰓇"
    property string playerMusicIcon: "󰎆"
    property string playerNoArtIcon: "󰎆"
    property string playerPreviousIcon: "󰒮"
    property string playerPlayIcon: "󰐊"
    property string playerPauseIcon: "󰏤"
    property string playerNextIcon: "󰒭"

    // Nerd Font notification icons
    property string notificationNoneIcon: "󰂚"
    property string notificationSomeIcon: "󰂞"
    property string notificationDndIcon: "󰂛"
    property string notificationClearIcon: "󰎟"
    property string notificationCloseIcon: "󰅖"
    property string notificationFallbackAppIcon: "󰅺"

    // Nerd Font bluetooth icons
    property string bluetoothOffIcon: "󰂲"
    property string bluetoothOnIcon: "󰂯"
    property string bluetoothConnectedIcon: "󰂱"
    property string bluetoothDeviceFallbackIcon: "󰂯"
    property string bluetoothSettingsIcon: "󰒓"
    property string bluetoothRefreshIcon: "󰑐"
    property string bluetoothBatteryIcon: "󰁹"

    // Nerd Font input icons
    property string inputMutedIcon: "󰍭"
    property string inputActiveIcon: "󰍬"
    property string inputDeviceIcon: "󰍬"
    property string inputSettingsIcon: "󰒓"

    // Nerd Font audio icons
    property string audioMutedIcon: "󰖁"
    property string audioZeroIcon: "󰝟"
    property string audioLowIcon: "󰕿"
    property string audioMediumIcon: "󰖀"
    property string audioHighIcon: "󰕾"
    property string audioDeviceIcon: "󰓃"
    property string audioSettingsIcon: "󰒓"

    // Nerd Font network icons
    property string networkDisconnectedIcon: "󰌙"
    property string wiredConnectedIcon: "󰈀"
    property string wiredNoLinkIcon: "󰈂"
    property string wifiOffIcon: "󰤯"
    property string wifiDisconnectedIcon: "󰤭"
    property string wifiStrength1Icon: "󰤟"
    property string wifiStrength2Icon: "󰤢"
    property string wifiStrength3Icon: "󰤥"
    property string wifiStrength4Icon: "󰤨"

    // Nerd Font power icons
    property string powerIcon: " "
    property string powerShutdownIcon: "⏻"
    property string powerRebootIcon: ""
    property string powerLockIcon: "󰌾"
    property string powerLogoutIcon: "󰍃"
    property string powerSleepIcon: "󰤄"
    property string powerConfirmIcon: "󰄬"
    property string recordingIcon: "󰑊"
    property string brightnessLowIcon: "󰃞"
    property string brightnessMediumIcon: "󰃟"
    property string brightnessHighIcon: "󰃠"
    property string brightnessNightIcon: "󰃝"
    property string caffeineIcon: "󰅶"
    property string batteryChargingIcon: "󰂄"
    property string batteryFullIcon: "󰁹"
    property string batteryHighIcon: "󰂂"
    property string batteryMediumIcon: "󰁿"
    property string batteryLowIcon: "󰁼"
    property string batteryEmptyIcon: "󰂎"

    // Clock
    property string clockFormat: "dd MMM   hh:mm"
}
