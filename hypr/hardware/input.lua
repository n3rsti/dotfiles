hl.config({
	input = {
		kb_layout = "pl,us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		accel_profile = "flat",
		repeat_delay = 200,
		follow_mouse = 1,
		sensitivity = 0.2,
		touchpad = {
			natural_scroll = true,
			disable_while_typing = false,
		},
	},
})

hl.config({
	binds = {
		scroll_event_delay = 0,
	},
})

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
hl.device({ name = "synaptics-tm3471-010", sensitivity = 1 })
hl.device({ name = "tpps/2-elan-trackpoint", sensitivity = -1 })
