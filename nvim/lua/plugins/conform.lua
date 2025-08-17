return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				cpp = { "clang-format" },
				go = { "gofmt" },
				json = { "fixjson" },
				jsonc = { "fixjson" },
				nix = { "nixfmt" },
				css = { "css_beautify" },
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end,
}
