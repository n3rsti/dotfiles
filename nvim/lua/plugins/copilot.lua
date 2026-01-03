return {
	-- 	{
	-- 		"zbirenbaum/copilot.lua",
	-- 		cmd = "Copilot",
	-- 		event = "InsertEnter",
	-- 		enabled = false,
	-- 		config = function()
	-- 			require("copilot").setup({
	-- 				suggestion = {
	-- 					enabled = true,
	-- 					auto_trigger = true,
	-- 					debounce = 75,
	-- 					keymap = {
	-- 						accept = "<M-CR>",
	-- 					},
	-- 				},
	-- 				server_opts_overrides = {
	-- 					settings = {
	-- 						telemetry = {
	-- 							telemetryLevel = "off",
	-- 						},
	-- 					},
	-- 				},
	-- 			})
	-- 		end,
	-- 	},
	{
		"github/copilot.vim",
		enabled = false,
		config = function()
			vim.keymap.set("i", "<M-CR>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
			vim.g.copilot_no_tab_map = true
		end,
	},
}
