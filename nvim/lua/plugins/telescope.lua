return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local themes = require("telescope.themes")

		local function map(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { desc = desc })
		end

		-- Setup telescope
		telescope.setup({
			pickers = {
				buffers = {
					sort_mru = true,
					ignore_current_buffer = true,
				},
			},
		})

		telescope.load_extension("fzf")

		-- File and search keymaps
		map("<leader>sf", function()
			builtin.find_files({ no_ignore = true })
		end, "Telescope find files")
		map("<leader>sg", builtin.live_grep, "Telescope live grep")
		map("<leader><leader>", builtin.buffers, "Telescope buffers")
		map("<leader>fh", builtin.help_tags, "Telescope help tags")
		map("<C-p>", builtin.lsp_document_symbols, "Telescope document symbols")
		map("<leader>/", builtin.current_buffer_fuzzy_find, "[/] Fuzzily search in current buffer")

		-- LSP keymaps
		map("gr", builtin.lsp_references, "LSP: [G]oto [R]eferences")
		map("gi", builtin.lsp_implementations, "LSP: [G]oto [I]mplementation")
		map("gd", builtin.lsp_definitions, "LSP: [G]oto [D]efinition")
		map("grt", builtin.lsp_type_definitions, "LSP: [G]oto [T]ype Definition")
	end,
}
