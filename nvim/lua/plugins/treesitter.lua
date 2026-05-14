vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind

		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end

			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
})

local nvim_treesitter = require("nvim-treesitter")

local function contains(table, value)
	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end

	return false
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local filetype = args.match
		local lang = vim.treesitter.language.get_lang(filetype) or filetype

		local installed = nvim_treesitter.get_installed("parsers")
		local available = nvim_treesitter.get_available()

		if contains(installed, lang) then
			vim.treesitter.start(args.buf, lang)
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			return
		end

		if contains(available, lang) then
			nvim_treesitter.install(lang)
		end
	end,
})
