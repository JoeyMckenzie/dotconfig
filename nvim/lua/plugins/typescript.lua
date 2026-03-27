return {
  -- Formatting with Prettier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "oxfmt", "prettier", stop_after_first = true },
        typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
        javascript = { "oxfmt", "prettier", stop_after_first = true },
        javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
        svelte = { "prettier" },
        json = { "oxfmt", "prettier", stop_after_first = true },
        css = { "oxfmt", "prettier", stop_after_first = true },
        html = { "oxfmt", "prettier", stop_after_first = true },
      },
    },
  },

  -- Linting with ESLint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        typescript = { "eslint", "oxlint" },
        typescriptreact = { "eslint", "oxlint" },
        javascript = { "eslint", "oxlint" },
        javascriptreact = { "eslint", "oxlint" },
        svelte = { "eslint" },
      },
    },
  },

  -- Svelte LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
      },
    },
  },

  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "svelte",
        "typescript",
        "javascript",
        "css",
        "html",
      },
    },
  },
}
