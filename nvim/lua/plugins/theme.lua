vim.pack.add({
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/rose-pine/neovim",
})

require("tokyonight").setup({
	style = "night",
	on_colors = function(colors)
		colors.bg = "#090a0f"
	end,
})

require("rose-pine").setup({
	variant = "main",
	palette = {
		main = {
			base = "#111111",
		},
	},

	highlight_groups = {
		TelescopeNormal = { bg = "base" },
		TelescopeBorder = { fg = "highlight_high", bg = "base" }, -- Border color
		NormalFloat = { bg = "base" },
		FloatBorder = { bg = "base" },
		Pmenu = { bg = "base" },
		BlinkCmpDoc = { bg = "base" },
		BlinkCmpDocBorder = { bg = "base" },
	},
})

vim.cmd.colorscheme("rose-pine")
