return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "^.git/",
        "^node_modules/",
        "^vendor/",
        ".phpstan.cache/",
        "^storage/framework/",
        "^bootstrap/cache/",
      },
    },
  },
  keys = {
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
          file_ignore_patterns = { "^.git/" },
        })
      end,
      desc = "Find Files (incl hidden + gitignored)",
    },
  },
}
