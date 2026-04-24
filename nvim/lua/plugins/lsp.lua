return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },

		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	opts = {
		servers = {
			lua_ls = {},
			gopls = {},
			clangd = {},
			vtsls = {},
			vue_ls = {},
			nil_ls = {},
			air = {},
			vhdl_ls = {},
			r_language_server = {},
			jsonls = {},
			tailwindcss = {},
			rust_analyzer = {},
			jdtls = {},
			qmlls = {},
			cssls = {},
			texlab = {},
			basedpyright = {},
			roslyn_ls = {},
			eslint = {},
			tinymist = {},
			blueprint_ls = {},
			kotlin_language_server = {},
			emmet_language_server = {},
			angularls = {},
			html = {},
		},
	},
	config = function(_, opts)
		for server, config in pairs(opts.servers) do
			vim.lsp.config[server] = config
			vim.lsp.enable(server)
		end
	end,
}
