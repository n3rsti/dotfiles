require("hardware.monitors")
require("system.autostart")
require("looks.layers")
require("bindings.base")
require("hardware.input")
require("system.envs")
require("looks.base")
require("looks.noctalia")
require("looks.windows")
-- require("override")

hl.config({
	xwayland = {
		enabled = true,
		use_nearest_neighbor = false,
		force_zero_scaling = true,
		create_abstract_socket = false,
	},
	cursor = {
		no_warps = true,
	},
})
