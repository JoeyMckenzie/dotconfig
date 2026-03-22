return {
  -- Formatting with Prettier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "prettier", "oxfmt" },
        typescriptreact = { "prettier", "oxfmt" },
        javascript = { "prettier", "oxfmt" },
        javascriptreact = { "prettier", "oxfmt" },
        svelte = { "prettier" },
        json = { "prettier", "oxfmt" },
        css = { "prettier", "oxfmt" },
        html = { "prettier", "oxfmt" },
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
