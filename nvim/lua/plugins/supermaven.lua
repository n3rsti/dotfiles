return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<M-CR>",
				clear_suggestion = "<M-BS>",
				accept_word = "<M-Right>",
			},
		})
	end,
}
