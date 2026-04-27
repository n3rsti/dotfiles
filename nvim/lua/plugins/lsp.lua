vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

local servers = {
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
}

for server, config in pairs(servers) do
	vim.lsp.config[server] = config
	vim.lsp.enable(server)
end
