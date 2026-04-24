local vue_language_server_path = vim.fn.expand("~/.npm-global/lib/node_modules/@vue/language-server")

local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }

local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "javascript", "typescript", "vue" },
	configNamespace = "typescript",
}

return {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	filetypes = tsserver_filetypes,
}
