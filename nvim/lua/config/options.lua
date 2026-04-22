-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_php_lsp = "phpantom"

-- Workaround for NeoVim 0.11.3 inlay hint rendering bug
vim.lsp.inlay_hint.enable(false)
