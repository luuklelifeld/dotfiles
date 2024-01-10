return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile"},
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = {
                "williamboman/mason.nvim",
            },
            config = function()
                require("mason").setup{}

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
                })


                mason_lspconfig.setup_handlers({
                    function (server_name)
                        lspconfig[server_name].setup {}
                    end
                })

               -- local servers = mason_lspconfig.get_installed_servers()

               -- for _, server_name in ipairs(servers) do
               --     vim.notify("setting up " .. server_name)
               --     lspconfig[server_name].setup {}
               -- end
            end
        }

    }
}
