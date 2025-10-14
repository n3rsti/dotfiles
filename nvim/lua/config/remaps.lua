local map = function(keys, func, desc, mode)
	mode = mode or "n"
	vim.keymap.set(mode, keys, func, { desc = "LSP: " .. desc })
end

map("J", ":m '>+1<CR>gv=gv", "Visual: move line down", "v")
map("K", ":m '<-2<CR>gv=gv", "Visual: move line up", "v")

vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")

map("rn", vim.lsp.buf.rename, "[R]e[n]ame")

map("ca", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

map("<Up>", function()
	vim.diagnostic.setqflist()
	vim.cmd.copen()
end, "Open quickfix diagnostics")

map("<Down>", vim.cmd.cclose, "Quickfix: close")
map("<Right>", vim.cmd.cnext, "Quickfix: jump to next")
map("<Left>", vim.cmd.cprev, "Quickfix: jump to previous")

map("<leader>x", ":!go run .<CR>", "Execute file")

map("<Esc>", "<cmd>nohlsearch<CR>", "Stop highlighting")

map("<leader>e", vim.diagnostic.open_float, "Open floating diagnostics")

map("J", "mzJ`z", "Move line below up")

map("<C-d>", "<C-d>zz", "Jump down")
map("<C-u>", "<C-u>zz", "Jump up")

map("<C-b>", require("oil").open, "Open oil")

local harpoon = require("harpoon")

map("<leader>a", function()
	harpoon:list():add()
end, "Harpoon: add")
map("<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, "Harpoon: toggle quick menu")

for i = 1, 4 do
	map("<leader>" .. i, function()
		harpoon:list():select(i)
	end, "Harpoon: " .. i)
end

map("<C-j>", function()
	harpoon:list():prev()
end, "Harpoon: jump back")
map("<C-k>", function()
	harpoon:list():next()
end, "Harpoon: jump forward")
