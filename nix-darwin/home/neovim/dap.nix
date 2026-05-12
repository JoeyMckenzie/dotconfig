{ pkgs, ... }:

let
  # vscode-php-debug ships as a VS Code extension package in nixpkgs. The
  # entry script lives inside the extension dir. This becomes the `command`
  # we hand to `node` when nvim-dap launches the PHP adapter.
  phpDebugAdapter = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js";
in
{
  programs.nixvim = {
    # nvim-dap-ui and nvim-dap-virtual-text used to live under
    # plugins.dap.extensions.* but were promoted to top-level plugins in
    # nixvim; they're now siblings of plugins.dap.
    plugins.dap-ui.enable = true;
    plugins.dap-virtual-text.enable = true;

    plugins.dap = {
      enable = true;

      adapters.executables.php = {
        command = "node";
        args = [ phpDebugAdapter ];
      };

      # Default PHP / Xdebug 3 listener. Add Docker pathMappings or
      # additional configs per-project via .vscode/launch.json — DAP loads
      # those automatically through dap.ext.vscode (see extraConfigLuaPost).
      configurations.php = [
        {
          type = "php";
          request = "launch";
          name = "Listen for Xdebug";
          port = 9003;
        }
      ];
    };

    # Project-level vscode-php-debug isn't needed at runtime — bringing the
    # nixpkgs derivation in via plugins.dap.adapters references it, but we
    # still want xdebug itself installed on the system. That's a PHP
    # extension, not an nvim concern.

    extraConfigLuaPost = ''
      local dap, dapui = require('dap'), require('dapui')

      -- Auto-open dap-ui when a session starts; close when it ends.
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- .vscode/launch.json in the project root is now loaded automatically
      -- on-demand by nvim-dap's provider system (see :h dap-providers) — no
      -- explicit load_launchjs call needed. Per-project configs (Docker
      -- pathMappings, multiple Xdebug ports, custom envs) drop into
      -- .vscode/launch.json alongside the project and stay portable to VS Code.
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>db";
        action.__raw = "function() require('dap').toggle_breakpoint() end";
        options.desc = "Toggle breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dB";
        action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end";
        options.desc = "Conditional breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action.__raw = "function() require('dap').continue() end";
        options.desc = "Continue / start";
      }
      {
        mode = "n";
        key = "<leader>di";
        action.__raw = "function() require('dap').step_into() end";
        options.desc = "Step into";
      }
      {
        mode = "n";
        key = "<leader>do";
        action.__raw = "function() require('dap').step_over() end";
        options.desc = "Step over";
      }
      {
        mode = "n";
        key = "<leader>dO";
        action.__raw = "function() require('dap').step_out() end";
        options.desc = "Step out";
      }
      {
        mode = "n";
        key = "<leader>dr";
        action.__raw = "function() require('dap').repl.toggle() end";
        options.desc = "Toggle REPL";
      }
      {
        mode = "n";
        key = "<leader>dl";
        action.__raw = "function() require('dap').run_last() end";
        options.desc = "Run last";
      }
      {
        mode = "n";
        key = "<leader>du";
        action.__raw = "function() require('dapui').toggle() end";
        options.desc = "Toggle DAP UI";
      }
      {
        mode = "n";
        key = "<leader>dt";
        action.__raw = "function() require('dap').terminate() end";
        options.desc = "Terminate";
      }
      {
        mode = "n";
        key = "<leader>dK";
        action.__raw = "function() require('dapui').eval(nil, { enter = true }) end";
        options.desc = "Evaluate expression";
      }
    ];
  };
}
