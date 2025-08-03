return {
	"nvim-java/nvim-java",
	enabled = false,
	-- config = function()
	-- 	-- local config = {
	-- 	-- 	cmd = { "/run/current-system/sw/bin/jdtls" },
	-- 	-- 	root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
	-- 	-- }
	-- 	require("java").setup()
	-- end,
	config = function()
		require("java").setup()
	end,
}
