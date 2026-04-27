-- lua/pack/lazydev.lua

vim.pack.add({
	{
		src = "https://github.com/folke/lazydev.nvim",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		require("lazydev").setup({
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})
	end,
})
