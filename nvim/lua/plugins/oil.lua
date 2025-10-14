return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		win_options = {
			wrap = true,
			foldcolumn = "2",
		},
		keymaps = {
			["<Esc>"] = {
				function()
					require("oil").close()
				end,
				mode = "n",
			},
			["<C-b>"] = {
				function()
					require("oil").close()
				end,
				mode = "n",
			},
		},
	},
	-- Optional dependencies
	-- dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
