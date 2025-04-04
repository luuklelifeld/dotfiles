return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                require("mason").setup({})

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
                        "volar",
                        "lemminx",
                        "yamlls"
                    }
                })

                mason_lspconfig.setup_handlers({
                    function(server_name)
                        lspconfig[server_name].setup {}
                    end,
                    ["ts_ls"] = function()
                        local vue_ls_path = require('mason-registry').get_package('vue-language-server')
                            :get_install_path() .. '/node_modules/@vue/language-server'

                        lspconfig.ts_ls.setup {
                            init_options = {
                                plugins = {
                                    {
                                        name = "@vue/typescript-plugin",
                                        location = vue_ls_path,
                                        languages = { "vue" }
                                    }
                                }
                            },
                            filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
                        }
                    end,
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup {
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" }
                                    }
                                }
                            }
                        }
                    end
                })
            end
        }
    }
}
