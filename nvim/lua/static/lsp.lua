local ensure_installed = {
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

local configs = {
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim", "hs" }
                }
            }
        }
    },
    ts_ls = {
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
    },
    vue_ls = {
        init_options = {
            vue = {
                hybridMode = true
            }
        }
    }
}

return {
    ensure_installed = ensure_installed,
    configs = configs
}
