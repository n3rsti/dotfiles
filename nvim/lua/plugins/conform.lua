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
				css = { "prettier" },
				scss = { "prettier" },
				typescript = { "deno_fmt" },
				python = { "black" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
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
