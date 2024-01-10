-- Setting up lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "

require("lazy").setup("plugins")

--local mason_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
--if not mason_status_ok then
--    vim.notify("Couldn't load Mason-LSP-Config" .. mason_lspconfig, "error")
--    return
--end
--
--local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
--if not status_ok then
--    vim.notify("Problems with lspconfig")
--    return
--end
--
--
--local opts = {
    --    on_attach = require("plugins.lsp.lsp-config").on_attach,
    --    capabilities = require("plugins.lsp.lsp-config").capabilities,
    --}
    --mason_lspconfig.setup_handlers {
        --    function (server_name)
            --        vim.notify("Setting up lsp " .. server_name)
            --        lspconfig[server_name].setup {
                --            on_attach = opts.on_attach,
                --            capabilites = opts.capabilities
                --        }
                --    end
                --}

