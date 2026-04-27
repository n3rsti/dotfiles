vim.pack.add({

	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
	"https://github.com/nvim-lua/plenary.nvim",
})

local map = function(keys, func, desc, mode)
	mode = mode or "n"
	vim.keymap.set(mode, keys, func, { desc = "Harpoon: " .. desc })
end

local harpoon = require("harpoon")

harpoon:setup()

map("<leader>a", function()
	harpoon:list():add()
end, "Add")

map("<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, "Toggle quick menu")

for i = 1, 4 do
	map("<leader>" .. i, function()
		harpoon:list():select(i)
	end, i)
end

map("<C-j>", function()
	harpoon:list():prev()
end, "Jump back")
map("<C-k>", function()
	harpoon:list():next()
end, "Jump forward")
