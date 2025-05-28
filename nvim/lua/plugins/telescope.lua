return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({
			pickers = {
				buffers = {
					sort_lastused = true,
					sort_mru = true,
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Telescope find files" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Telescope live grep" })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Telescope buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
	end,
}
