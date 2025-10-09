vim.o.number = true
vim.g.have_nerd_font = true
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
	virtual_text = true,
	signs = false,
})

vim.o.updatetime = 50
vim.o.signcolumn = "yes"

vim.o.showmode = false

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.timeoutlen = 300

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.cursorline = true

vim.o.relativenumber = true

vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

vim.o.winborder = "rounded"

vim.o.scrolloff = 10
vim.o.wrap = false

vim.api.nvim_set_hl(0, "LineNr", { fg = "#8a8c8e" })

vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", {
	link = "LspReferenceWrite",
})

vim.api.nvim_set_hl(0, "MiniCursorword", {
	link = "LspReferenceWrite",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "nix",
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.expandtab = true
	end,
})

vim.filetype.add({
	extension = {
		razor = "razor",
	},
})
