return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		enabled = false,
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						accept = "<M-CR>",
					},
				},
				server_opts_overrides = {
					settings = {
						telemetry = {
							telemetryLevel = "off",
						},
					},
				},
			})
		end,
	},
}
