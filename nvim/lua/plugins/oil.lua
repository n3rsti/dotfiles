vim.pack.add({
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

require("oil").setup({
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
})
