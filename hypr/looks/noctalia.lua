hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
	},
	decoration = {
		rounding = 20,
		rounding_power = 2,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
		},
	},
})

hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^(noctalia-background-.*$|noctalia-notifications-.*$|noctalia-toast-.*$)" },
	ignore_alpha = 0.3,
	blur = true,
	blur_popups = true,
})
