vim.pack.add({
    "https://github.com/stevearc/conform.nvim"
})

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        cpp = { "clang-format" },
        go = { "gofmt" },
        json = { "fixjson" },
        jsonc = { "fixjson" },
        nix = { "nixfmt" },
        typescript = { "prettierd" },
        python = { "black" },
        vue = { "prettierd" },
        kotlin = { "ktlint" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})
