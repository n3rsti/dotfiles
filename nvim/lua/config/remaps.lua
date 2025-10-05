vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")

vim.keymap.set("n", "<leader>x", ":!go run .<CR>", { desc = "Execute file" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- local copilot = require("CopilotChat")
--
-- vim.keymap.set("n", "<leader>ch", copilot.open)

local map = function(keys, func, desc, mode)
	mode = mode or "n"
	vim.keymap.set(mode, keys, func, { desc = "LSP: " .. desc })
end

map("rn", vim.lsp.buf.rename, "[R]e[n]ame")

map("ca", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-j>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-k>", function()
	harpoon:list():next()
end)
