{ ... }:

{
  programs.nixvim = {
    plugins.neotest = {
      enable = true;

      # Adapters discover their runners automatically:
      #   - vitest looks for ./node_modules/.bin/vitest (project-local install)
      #   - phpunit looks for ./vendor/bin/phpunit (project-local install)
      # Both fall back to global if not present. Add more adapters here later
      # (jest, pest, go, rspec, pytest, rust, ...) — each one is a single
      # `.enable = true`.
      adapters = {
        vitest.enable = true;
        phpunit.enable = true;
      };

      settings = {
        # Inline virtual_text + sign-column markers on each test for
        # pass/fail/skipped state. The output_panel auto-opens on test run
        # so failures aren't silent.
        status = {
          virtual_text = true;
          signs = true;
        };
        output = {
          open_on_run = true;
        };
        quickfix = {
          open = false;
        };
        summary = {
          mappings = {
            expand = [
              "<CR>"
              "<2-LeftMouse>"
            ];
            jumpto = "i";
            output = "o";
            run = "r";
            stop = "u";
            target = "t";
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action.__raw = "function() require('neotest').run.run() end";
        options.desc = "Run nearest test";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end";
        options.desc = "Run tests in file";
      }
      {
        mode = "n";
        key = "<leader>tl";
        action.__raw = "function() require('neotest').run.run_last() end";
        options.desc = "Run last test";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action.__raw = "function() require('neotest').summary.toggle() end";
        options.desc = "Toggle test summary";
      }
      {
        mode = "n";
        key = "<leader>to";
        action.__raw = "function() require('neotest').output.open({ enter = true }) end";
        options.desc = "Open test output";
      }
      {
        mode = "n";
        key = "<leader>tO";
        action.__raw = "function() require('neotest').output_panel.toggle() end";
        options.desc = "Toggle test output panel";
      }
      {
        mode = "n";
        key = "<leader>tS";
        action.__raw = "function() require('neotest').run.stop() end";
        options.desc = "Stop test";
      }
    ];
  };
}
