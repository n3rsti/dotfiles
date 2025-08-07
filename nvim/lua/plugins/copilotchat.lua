return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		opts = {
			model = "claude-sonnet-4", -- AI model to use
			temperature = 0.1, -- Lower = focused, higher = creative
			window = {
				layout = "vertical", -- 'vertical', 'horizontal', 'float'
				width = 0.5,
			},
			auto_insert_mode = true, -- Enter insert mode when opening

			mappings = {
				complete = {
					insert = "<Tab>",
				},
				close = {
					normal = "<Esc>",
				},
				reset = false, -- Disable the default <C-l> reset binding
			},
		},
	},
}
