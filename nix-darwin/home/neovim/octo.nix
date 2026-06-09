{ ... }:

{
  programs.nixvim = {
    # octo.nvim's nixvim wrapper only allows telescope/fzf-lua/snacks in the
    # picker enum, but upstream also supports "default" (uses vim.ui.select,
    # which ui.nix routes to MiniPick.ui_select). Skip the auto-setup and
    # call it ourselves to keep everything funneled through mini.pick.
    plugins.octo = {
      enable = true;
      callSetup = false;
    };

    extraConfigLua = ''
      require("octo").setup({
        picker = "default",
        enable_builtin = true,
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>go";
        action = "<cmd>Octo<cr>";
        options.desc = "Octo: actions";
      }
      {
        mode = "n";
        key = "<leader>gi";
        action = "<cmd>Octo issue list<cr>";
        options.desc = "Octo: issues";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Octo pr list<cr>";
        options.desc = "Octo: PRs";
      }
      {
        mode = "n";
        key = "<leader>gR";
        action = "<cmd>Octo review start<cr>";
        options.desc = "Octo: review";
      }
    ];
  };
}
