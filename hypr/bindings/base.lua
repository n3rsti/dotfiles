_G.mainMod = "SUPER"

local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "walker -t launcher"
local symbolMenu = "walker -t launcher -m symbols"
local browser = "firefox"
local discord = "discord"
local sound = "pavucontrol"
local bluetooth = "blueman-manager"
local resources = "resources -t applications"
local switchKeyboardLayout = "hyprctl switchxkblayout current next"
local windowSwitcher = "~/.config/dotfiles/scripts/windows-switcher.sh"
local screenshotArea = "grimblast copysave area"
local screenshotOutput = "grimblast copysave output"
local screenshotOutputDelayed = "bash -c 'sleep 1; grimblast copysave output'"
local volumeUp = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
local volumeDown = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
local volumeMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local micMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
local brightnessUp = "brightnessctl set +5%"
local brightnessDown = "brightnessctl set 5%-"
local mediaNext = "playerctl next"
local mediaPrev = "playerctl previous"
local mediaPlayPause = "playerctl play-pause"
local keyboardBrightnessPlaceholder = "swayosd-client --custom-message=xd --custom-icon=preferences-desktop-keyboard"

require("bindings.path-of-exile")
require("bindings.windows")
require("bindings.noctalia")

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(discord))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(sound))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(bluetooth))
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd(resources))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd(symbolMenu))

hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(switchKeyboardLayout))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(windowSwitcher), { non_consuming = true })

hl.bind("Print", hl.dsp.exec_cmd(screenshotArea))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(screenshotOutput))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(screenshotArea))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(screenshotOutput))
hl.bind("SHIFT + ALT + P", hl.dsp.exec_cmd(screenshotOutputDelayed))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volumeUp), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volumeDown), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(volumeMute), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(micMute), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightnessUp), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightnessDown), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(mediaNext), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(mediaPrev), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(mediaPlayPause), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(mediaPlayPause), { locked = true })

hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(keyboardBrightnessPlaceholder))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(keyboardBrightnessPlaceholder))
