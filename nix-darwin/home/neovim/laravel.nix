{
  inputs,
  pkgs,
  ...
}:

let
  laravel-nvim = pkgs.callPackage ./_pkgs/laravel-nvim.nix {
    src = inputs.laravel-nvim;
  };
in
{
  programs.nixvim = {
    # laravel.nvim runtime deps. nui / plenary / nvim-nio are pulled from
    # nixpkgs.vimPlugins; laravel-nvim itself is built from the flake input
    # above since it isn't packaged in nixpkgs. blink-compat is the shim
    # that lets blink.cmp consume laravel.nvim's nvim-cmp-style completion
    # source (see plugins.blink-cmp.settings below).
    extraPlugins = with pkgs.vimPlugins; [
      nui-nvim
      plenary-nvim
      nvim-nio
      blink-compat
      laravel-nvim
    ];

    # Register laravel.nvim's cmp source through blink.compat and scope it
    # to PHP/Blade buffers. score_offset=95 ranks Laravel-aware suggestions
    # above plain LSP results (routes, view names, config keys, .env vars,
    # model columns). `inherit_defaults` reuses the global source list from
    # completion.nix and appends "laravel".
    plugins.blink-cmp.settings.sources = {
      providers.laravel = {
        name = "laravel";
        module = "blink.compat.source";
        score_offset = 95;
      };
      per_filetype = {
        php.__raw = ''{ inherit_defaults = true, "laravel" }'';
        blade.__raw = ''{ inherit_defaults = true, "laravel" }'';
      };
    };

    # Setup runs unconditionally — laravel.nvim's bootstrap is cheap and
    # registers an autocmd that only does real work inside a Laravel project
    # (detected via `artisan` / `composer.json`). Picker provider is
    # `ui-select` so commands flow through vim.ui.select, which ui.nix
    # already reroutes to MiniPick.ui_select.
    extraConfigLua = ''
      require("laravel").setup({
        features = {
          pickers = {
            provider = "ui-select";
          },
        },
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>ll";
        action.__raw = "function() Laravel.pickers.laravel() end";
        options.desc = "Laravel: picker";
      }
      {
        mode = "n";
        key = "<leader>la";
        action.__raw = "function() Laravel.pickers.artisan() end";
        options.desc = "Laravel: artisan";
      }
      {
        mode = "n";
        key = "<leader>lr";
        action.__raw = "function() Laravel.pickers.routes() end";
        options.desc = "Laravel: routes";
      }
      {
        mode = "n";
        key = "<leader>lm";
        action.__raw = "function() Laravel.pickers.make() end";
        options.desc = "Laravel: make";
      }
      {
        mode = "n";
        key = "<leader>lc";
        action.__raw = "function() Laravel.pickers.commands() end";
        options.desc = "Laravel: commands";
      }
      {
        mode = "n";
        key = "<leader>lo";
        action.__raw = "function() Laravel.pickers.resources() end";
        options.desc = "Laravel: resources";
      }
      {
        mode = "n";
        key = "<leader>lt";
        action.__raw = "function() Laravel.commands.run('actions') end";
        options.desc = "Laravel: actions";
      }
      {
        mode = "n";
        key = "<leader>lu";
        action.__raw = "function() Laravel.commands.run('hub') end";
        options.desc = "Laravel: hub";
      }
      {
        mode = "n";
        key = "<leader>lh";
        action.__raw = "function() Laravel.run('artisan docs') end";
        options.desc = "Laravel: docs";
      }
    ];
  };
}
