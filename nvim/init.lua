-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

--
-- General stuff
--
vim.opt.swapfile = false

--
-- codecompanion.nvim
--
require("codecompanion").setup({
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
  },
})

--
-- comment.nvim
--
require("Comment").setup()

--
-- harpoon.nvim
--
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<C-h>", function()
  harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-t>", function()
  harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-n>", function()
  harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-s>", function()
  harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
  harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
  harpoon:list():next()
end)

--
-- harpoon + telescope
--
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({
        results = file_paths,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

vim.keymap.set("n", "<C-e>", function()
  toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })

--
-- PHP doc tag highlighting
--
vim.api.nvim_create_augroup("PHPDocTags", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "PHPDocTags",
  pattern = "php",
  callback = function()
    -- Define a blueish highlight group for PHP doc tags
    vim.api.nvim_set_hl(0, "PHPDocTag", { fg = "#7aa2f7", bold = true })

    -- Use matchadd with higher priority to overlay the pattern on top of Treesitter highlighting
    -- Note: longer patterns like property-read and property-write must come before property to avoid partial matches
    vim.fn.matchadd(
      "PHPDocTag",
      "@\\(property-read\\|property-write\\|var\\|param\\|return\\|throws\\|deprecated\\|see\\|link\\|example\\|since\\|version\\|author\\|todo\\|fixme\\|note\\|warning\\|psalm\\|template\\|implements\\|extends\\|readonly\\|internal\\|package\\|suppress\\|noinspection\\|use\\|property\\|method\\|mixin\\|requires\\|copyright\\)",
      30
    )
  end,
})
