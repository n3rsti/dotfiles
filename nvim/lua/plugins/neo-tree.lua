return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		{ "3rd/image.nvim", opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	lazy = false, -- neo-tree will lazily load itself
	---@module "neo-tree"
	---@type neotree.Config?
	opts = {
		filesystem = {
			window = {
				mappings = {
					["<C-b>"] = "close_window",
					["P"] = {
						"toggle_preview",
						config = {
							use_float = false,
							use_image_nvim = true,
							title = "Neo-tree Preview",
						},
					},
				},
			},
		},
	},
	keys = {
		{ "<C-b>", "<Cmd>Neotree toggle<CR>", mode = { "n", "i" }, desc = "NeoTree toggle", silent = true },
	},
}
