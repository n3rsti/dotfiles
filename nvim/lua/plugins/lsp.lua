return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },

		-- -- Allows extra capabilities provided by blink.cmp
		-- "saghen/blink.cmp",
	},
	opts = {
		servers = {
			lua_ls = {},
			gopls = {},
			clangd = {
				capabilities = {
					offsetEncoding = { "utf-16" },
				},
			},
			ts_ls = {},
			nil_ls = {
				settings = {
					["nil"] = {
						nix = {
							flake = {
								autoArchive = true,
							},
						},
					},
				},
			},
			air = {},
			vhdl_ls = {},
			glsl_analyzer = {},
			r_language_server = {},
			glsl_ls = {},
			jsonls = {},
		},
	},
	config = function(_, opts)
		for server, config in pairs(opts.servers) do
			vim.lsp.config[server] = config
			vim.lsp.enable(server)
		end
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),

			callback = function(event)
				local function client_supports_method(client, method, bufnr)
					return client:supports_method(method, bufnr)
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})
	end,
}
