return {
  -- Treesitter support for Astro
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "astro",
        "html",
        "javascript",
        "typescript",
        "css",
      },
    },
  },

  -- Formatting for Astro files
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        astro = { "prettier" },
      },
    },
  },
}
