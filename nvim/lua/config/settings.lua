vim.opt.number = true
vim.g.have_nerd_font = true
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
	virtual_text = true,
	signs = false,
})

vim.opt.updatetime = 50
vim.opt.signcolumn = "yes"

vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.timeoutlen = 300

vim.opt.tabstop = 4
vim.opt.softtabstop = 4 -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true

vim.opt.cursorline = true

vim.o.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.scrolloff = 10

vim.api.nvim_set_hl(0, "LineNr", { fg = "#8a8c8e" })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
