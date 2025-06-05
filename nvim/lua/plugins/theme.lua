return {
	{
		"folke/tokyonight.nvim",
		-- lazy = false,
		-- priority = 1000,
		-- config = function()
		-- 	require("tokyonight").setup({
		-- 		-- use the night style
		-- 		style = "night",
		-- 		-- disable italic for functions
		-- 		styles = {
		-- 			functions = {},
		-- 		},
		-- 		-- Change the "hint" color to the "orange" color, and make the "error" color bright red
		-- 		on_colors = function(colors)
		-- 			colors.bg = "#090a0f"
		-- 		end,
		-- 	})
		-- 	vim.cmd.colorscheme("tokyonight-night")
		-- end,
	},
	{
		"rose-pine/neovim",
		config = function()
			require("rose-pine").setup({
				variant = "main",

				-- variant = "moon", -- or "dawn" or "main"
				-- dark_variant = "moon", -- or "dawn" or "main"
				-- disable_background = true, -- disable background color
				-- disable_float_background = true, -- disable background color for floating windows
				-- groups = {
				-- 	warn = "rose",
				--                 ba
				-- },
				palette = {
					main = {
						base = "#111111",
					},
				},

				highlight_groups = {
					TelescopeNormal = { bg = "base" },
					TelescopeBorder = { fg = "highlight_high", bg = "base" }, -- Border color
				},
			})
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		"cdmill/neomodern.nvim",
		-- lazy = false,
		-- priority = 1000,
		-- config = function()
		-- 	require("neomodern").setup({
		-- 		colors = {
		-- 			orange = "#ff8800", -- define a new color
		-- 			keyword = "#817faf", -- redefine an existing color
		-- 		},
		-- 		highlights = {
		-- 			["@keyword"] = { fg = "#817faf", fmt = "bold" },
		-- 			-- ["@function"] = { bg = "$orange", fmt = "underline,italic" },
		-- 		},
		-- 	})
		-- 	require("neomodern").load()
		-- end,
	},
	-- {
	-- 	"gipo355/rose-pine-prime.nvim",
	-- 	as = "rose-pine-prime",
	-- },
	{
		"nvim-treesitter/playground",
	},
}
