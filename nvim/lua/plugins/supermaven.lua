vim.pack.add({

	"https://github.com/supermaven-inc/supermaven-nvim",
})

require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = "<M-CR>",
		clear_suggestion = "<M-BS>",
		accept_word = "<M-Right>",
	},
})
