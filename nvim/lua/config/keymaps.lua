-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- PHP docblock navigation
vim.keymap.set("n", "<leader>fv", function()
  require("telescope.builtin").live_grep({
    default_text = "@var.*" .. vim.fn.expand("<cword>"),
    type_filter = "php",
  })
end, { desc = "Find @var annotations" })

vim.keymap.set("n", "<leader>ft", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").live_grep({
    default_text = "@phpstan-type " .. word,
  })
end, { desc = "Find PHPStan type definition" })

vim.keymap.set("n", "<leader>fr", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").live_grep({
    default_text = word,
  })
end, { desc = "Find type references" })
