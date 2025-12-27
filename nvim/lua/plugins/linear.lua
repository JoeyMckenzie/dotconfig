return {
  {
    "joeymckenzie/linear.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      ui = {
        statusline = {
          show_title = true,
        },
      },
    },
  },
  -- Add Linear statusline to lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local linear_statusline = require("linear").statusline
      if linear_statusline then
        table.insert(opts.sections.lualine_x, 1, linear_statusline)
      end
    end,
  },
}
