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
        css = { "prettier" },
        html = { "prettier" },
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

  -- Neotest with Vitest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-vitest"))
    end,
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
