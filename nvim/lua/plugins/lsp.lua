local vue_language_server_path = "~/.npm-global/lib/node_modules/@vue/language-server"
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "javascript", "typescript", "vue" },
	configNamespace = "typescript",
}
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
			clangd = {
				capabilities = {
					offsetEncoding = { "utf-16" },
				},
			},
			ts_ls = {
				-- init_options = {
				-- 	plugins = {
				-- 		{
				-- 			name = "@vue/typescript-plugin",
				-- 			location = "",
				-- 			languages = { "javascript", "typescript", "vue" },
				-- 		},
				-- 	},
				-- },
				filetypes = {
					"javascript",
					"typescript",
				},
			},
			vtsls = {
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								vue_plugin,
							},
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			},
			nil_ls = {
				settings = {
					["nil"] = {
						formatting = {
							command = { "nixfmt" }, -- or "nixfmt" or "alejandra"
						},
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
			r_language_server = {},
			jsonls = {},
			vue_ls = {},
			tailwindcss = {},
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						diagnostics = {
							enable = true,
						},
					},
				},
			},
			jdtls = {},
			qmlls = {
				cmd = { "qmlls" },
			},
			cssls = {},
			texlab = {
				settings = {
					texlab = {

						bibtexFormatter = "texlab",
						build = {
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
							executable = "latexmk",
							forwardSearchAfter = false,
							onSave = true,
						},
						chktex = {
							onEdit = true,
							onOpenAndSave = false,
						},
						diagnosticsDelay = 300,
						formatterLineLength = 80,
						forwardSearch = {
							args = {},
						},
						latexFormatter = "latexindent",
						latexindent = {
							modifyLineBreaks = false,
						},
					},
				},
			},
			basedpyright = {},
			csharp_ls = {},
			roslyn_ls = {},
			eslint = {},
		},
	},
	config = function(_, opts)
		for server, config in pairs(opts.servers) do
			vim.lsp.config[server] = config
			vim.lsp.enable(server)
		end
	end,
}
