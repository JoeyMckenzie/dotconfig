return {
  -- Linting for Lua files
  {
    "mfussenegger/nvim-lint",
    ft = "lua",
    opts = {
      linters_by_ft = {
        lua = { "luacheck" },
      },
    },
  },
  -- Testing framework with Lua/busted support
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "MisanthropicBit/neotest-busted",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-busted"))
      return opts
    end,
  },
}
