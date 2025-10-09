return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				on_colors = function(colors)
					colors.bg = "#090a0f"
				end,
			})
		end,
	},
	{
		"rose-pine/neovim",
		config = function()
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
		end,
	},
}
