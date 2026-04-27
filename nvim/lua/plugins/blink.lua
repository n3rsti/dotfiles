vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/rafamadriz/friendly-snippets",
})

require("blink.cmp").setup({
	keymap = {
		preset = "enter",
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 0,
		},
		menu = {
			auto_show = true,

			draw = {
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "source_name", "kind", gap = 1 },
				},
				components = {
					source_name = {
						width = { max = 30 },
						text = function(ctx)
							return "[" .. ctx.source_name .. "]"
						end,
						highlight = "BlinkCmpSource",
					},
				},
			},
		},
	},

	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
		},
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},

	signature = {
		enabled = true,
	},
})
