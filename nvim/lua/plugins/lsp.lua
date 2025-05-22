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

                mason_lspconfig.setup({
                    automatic_installation = true,
                    ensure_installed = {
                        "clangd",
                        "cmake",
                        "cssls",
                        "dockerls",
                        "docker_compose_language_service",
                        "eslint",
                        "graphql",
                        "html",
                        "jsonls",
                        "ts_ls",
                        "lua_ls",
                        "marksman",
                        "powershell_es",
                        "pyright",
                        "sqlls",
                        "vue_ls",
                        "lemminx",
                        "yamlls"
                    }
                })

                vim.lsp.config('lua_ls', {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "hs" }
                            }
                        }
                    }
                })
                vim.lsp.config('vue_ls', {
                    init_options = {
                        vue = {
                            hybridMode = true
                        }
                    }
                })
                vim.lsp.config('ts_ls', {
                    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
                    init_options = {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location =
                                "Users/luuklelifeld/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server",
                                languages = { "vue" }
                            }
                        }
                    }
                })
            end
        }
    }
}
