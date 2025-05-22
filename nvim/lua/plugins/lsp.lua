return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                require("mason").setup()

                local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
                if not lspconfig_status_ok then
                    vim.notify("lspconfig status not ok")
                end

                local mason_lspconfig_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
                if not mason_lspconfig_status_ok then
                    vim.notify("mason-lspconfig status not ok")
                end

                local lsp_statics = require('static.lsp')

                mason_lspconfig.setup({
                    automatic_installation = true,
                    ensure_installed = lsp_statics.ensure_installed
                })

                vim.lsp.config('lua_ls', lsp_statics.configs.lua_ls)
                vim.lsp.config('ts_ls', lsp_statics.configs.ts_ls)
                vim.lsp.config('vue_ls', lsp_statics.configs.vue_ls)
            end
        }
    }
}
