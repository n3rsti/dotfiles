if vim.g.typst_preview_setup_done then
	return
end

vim.g.typst_preview_setup_done = true

require("typst-preview").setup({
	dependencies_bin = {
		tinymist = "tinymist",
		websocat = "websocat",
	},
})
