{ ... }:

{
  programs.nixvim.plugins.gitsigns = {
    enable = true;
    settings = {
      signs = {
        add.text = "│";
        change.text = "│";
        delete.text = "_";
        topdelete.text = "‾";
        changedelete.text = "~";
      };
      current_line_blame = false;
    };
  };

  programs.nixvim.plugins.lazygit = {
    enable = true;
    settings = {
      floating_window_scaling_factor = 0.95;
      floating_window_winblend = 0;
    };
  };
}
