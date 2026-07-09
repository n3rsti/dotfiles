-- Replace these with the actual classes from `hyprctl clients`
local game_classes = {
	["steam_app_238960"] = true,
}

local scroll_click_enabled = false

local function is_game_window(w)
	return w ~= nil and w.class ~= nil and game_classes[w.class] == true
end

local function update_scroll_click_state(w)
	scroll_click_enabled = is_game_window(w)
end

-- Initialize once on config load/reload.
update_scroll_click_state(hl.get_active_window())

-- Correct Lua event name: window.active
hl.on("window.active", function(w, reason)
	update_scroll_click_state(w)
end)

-- Some games/class wrappers may update class after the window appears.
-- This keeps the cached state correct if the active window's class changes.
hl.on("window.class", function(w)
	local active = hl.get_active_window()

	if active ~= nil and w ~= nil and active.address == w.address then
		update_scroll_click_state(w)
	end
end)

local function scroll_click()
	if scroll_click_enabled then
		hl.dispatch(hl.dsp.exec_cmd("ydotool click C0"))
	end
end

hl.bind("CTRL + mouse_down", scroll_click, { non_consuming = true })
hl.bind("CTRL + mouse_up", scroll_click, { non_consuming = true })
hl.bind("CTRL + SHIFT + mouse_down", scroll_click, { non_consuming = true })
hl.bind("CTRL + SHIFT + mouse_up", scroll_click, { non_consuming = true })
hl.bind("F4", hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_type.sh /exit"), { non_consuming = true })
hl.bind(
	"F5",
	hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_type.sh /hideout"),
	{ non_consuming = true }
)
hl.bind(
	"F6",
	hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_type.sh /kingsmarch"),
	{ non_consuming = true }
)
hl.bind(
	"F7",
	hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_type.sh /monastery"),
	{ non_consuming = true }
)

-- hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_enter.sh"))
