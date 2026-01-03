return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local ui = require("dapui")

		ui.setup()

		require("nvim-dap-virtual-text").setup()
		require("dap-go").setup()

		vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
		vim.keymap.set("n", "<space>gb", dap.run_to_cursor)
		vim.keymap.set("n", "<space>?", function()
			ui.eval(nil, { enter = true })
		end)

		vim.keymap.set("n", "<F1>", dap.continue)
		vim.keymap.set("n", "<F2>", dap.step_over)
		vim.keymap.set("n", "<F3>", dap.step_back)
		vim.keymap.set("n", "<F4>", dap.terminate)
		vim.keymap.set("n", "<F5>", dap.restart)
		vim.keymap.set("n", "<F6>", dap.step_into)
		vim.keymap.set("n", "<F7>", dap.step_out)

		dap.listeners.before.attach.dapui_config = function()
			ui.open()
		end

		dap.listeners.before.launch.dapui_config = function()
			ui.open()
		end

		dap.listeners.before.event_terminated.dapui_config = function()
			ui.close()
		end

		dap.listeners.before.event_exited.dapui_config = function()
			ui.close()
		end
	end,
}
