local map = function(keys, func, desc, mode)
	mode = mode or "n"
	vim.keymap.set(mode, keys, func, { desc = "LSP: " .. desc })
end

-- Controls
map("J", ":m '>+1<CR>gv=gv", "Visual: move line down", "v")
map("K", ":m '<-2<CR>gv=gv", "Visual: move line up", "v")

map("J", "mzJ`z", "Move line below up")

map("<C-d>", "<C-d>zz", "Jump down and center")
map("<C-u>", "<C-u>zz", "Jump up and center")

-- Use ctrl + h/l to to left/right in insert mode
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")

map("<Esc>", "<cmd>nohlsearch<CR>", "Stop highlighting")

-- Coding
map("rn", vim.lsp.buf.rename, "[R]e[n]ame")
map("ca", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

map("<leader>e", vim.diagnostic.open_float, "Diagnostics: Open floating diagnostics")

-- Diagnostics
map("<Right>", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, "Diagnostics: Jump to next error")
map("<Left>", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, "Diagnostics: Jump to previous error")

-- File explorer
map("<C-b>", require("oil").open, "Oil: toggle")

-- Floating terminal
map("<C-t>", function()
	local mode = vim.api.nvim_get_mode().mode
	vim.cmd("Floaterminal")
	if mode == "n" then
		vim.cmd("startinsert")
	end
end, "Floating terminal: toggle", { "n", "i", "t" })

-- Quickfix list
map("<Up>", function()
	vim.cmd.copen()
end, "Quickfix: open")

map("<Down>", vim.cmd.cclose, "Quickfix: close")
