hl.bind("CTRL + mouse_down", hl.dsp.exec_cmd("ydotool click C0"), { non_consuming = true })
hl.bind("CTRL + mouse_up", hl.dsp.exec_cmd("ydotool click C0"), { non_consuming = true })
hl.bind("CTRL + SHIFT + mouse_down", hl.dsp.exec_cmd("ydotool click C0"), { non_consuming = true })
hl.bind("CTRL + SHIFT + mouse_up", hl.dsp.exec_cmd("ydotool click C0"), { non_consuming = true })
hl.bind(
	"F4",
	hl.dsp.exec_cmd("~/.config/dotfiles/scripts/path-of-exile/poe_type.sh /menagerie"),
	{ non_consuming = true }
)
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
