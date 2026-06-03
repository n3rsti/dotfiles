hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "centered-floating-windows-by-class",
	match = {
		class = "^(org.pulseaudio.pavucontrol|.blueman-manager-wrapped|Bitwarden|signal|org.gnome.Calendar|Spotify|discord|xdg-desktop-portal-gtk|eog|org.gnome.Evince|net.nokyan.Resources|org.gnome.clocks|io.github.mrvladus.List|org.gnome.Weather)$",
	},
	center = true,
	float = true,
})

hl.window_rule({
	name = "centered-floating-windows-by-title",
	match = { title = "^(Wiremix|Btop|Impala|Image Resizer|Network Manager|ghostty_float|Select folder)$" },
	center = true,
	float = true,
})

hl.window_rule({
	name = "size-1-title",
	match = { title = "^(Wiremix|Impala|Network Manager)$" },
	size = { 800, 600 },
})

hl.window_rule({
	name = "size-1-class",
	match = { class = "^(.blueman-manager-wrapped|org.pulseaudio.pavucontrol|org.gnome.clocks|org.gnome.Weather)" },
	size = { 800, 600 },
})

hl.window_rule({
	name = "size-1-wider-class",
	match = { class = "^(Bitwarden)$" },
	size = { 1000, 600 },
})

hl.window_rule({
	name = "dialog",
	match = { title = "^(ghostty_float)" },
	size = { 1000, 800 },
})

hl.window_rule({
	name = "poe-rule",
	match = { class = "^(pathofexilesteam.exe|steam_app_238960)$" },
	tile = true,
	content = "game",
})

hl.window_rule({
	name = "apt-rule",
	match = { class = "^(awakened-poe-trade|Awakened-poe-trade|exiled-exchange-2)$" },
	float = true,
	border_size = 0,
	no_blur = true,
	no_shadow = true,
	no_anim = true,
	no_follow_mouse = true,
})

hl.window_rule({
	name = "size-2-class",
	match = { class = "^(spotify|legcord|discord|signal|xdg-desktop-portal-gtk|eog|Btop|org.gnome.Calendar)$" },
	size = { 1400, 800 },
})

hl.window_rule({
	name = "size-vertical-class",
	match = { class = "^(org.gnome.Evince)" },
	size = { 800, 950 },
})

hl.window_rule({
	name = "fullscreen-class",
	match = { class = "^(com.moonlight_stream.Moonlight)" },
	fullscreen = true,
})

hl.window_rule({ match = { class = "^(Rofi)$" }, stay_focused = true })
hl.window_rule({ match = { class = "^(steam_app_238960)" }, tile = true })

hl.window_rule({ match = { class = "steam" }, opacity = "1 1", float = true })
hl.window_rule({ match = { class = "steam", title = "Steam" }, center = true })
hl.window_rule({ match = { class = "steam", title = "Steam" }, size = { 1100, 700 } })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })
