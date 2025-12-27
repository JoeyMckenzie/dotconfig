return {
  -- Run both intelephense and phpactor
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          -- phpactor handles composer.json nicely
          filetypes = { "php", "json" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "php-debug-adapter")
        end,
      },
    },
    config = function()
      local dap = require("dap")

      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
      }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = {
            -- Adjust if using Docker/Sail: ["/var/www/html"] = "${workspaceFolder}"
          },
        },
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug (port 9000)",
          port = 9000,
        },
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "pint", "php_cs_fixer" },
      },
      formatters = {
        php_cs_fixer = {
          command = "vendor/bin/php-cs-fixer",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        php = { "phpstan" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "olimorris/neotest-phpunit",
    },
  },
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "kevinhwang91/promise-async",
    },
    cmd = { "Laravel" },
    keys = {
      { "<leader>la", "<cmd>Laravel artisan<cr>", desc = "Laravel: Artisan" },
      { "<leader>lr", "<cmd>Laravel routes<cr>", desc = "Laravel: Routes" },
      { "<leader>lm", "<cmd>Laravel make<cr>", desc = "Laravel: Make" },
      { "<leader>lc", "<cmd>Laravel commands<cr>", desc = "Laravel: Commands" },
      { "<leader>lo", "<cmd>Laravel resources<cr>", desc = "Laravel: Resources" },
    },
    event = { "VeryLazy" },
    opts = {
      features = {
        pickers = {
          provider = "snacks", -- "snacks | telescope | fzf-lua | ui-select"
        },
      },
    },
  },
}
