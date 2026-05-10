return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { mason = false },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.nix = { "statix", "deadnix" }
    end,
  },
}
