_:

{
  # gitsigns replaced by mini.diff (signs + hunk operators) and mini.git
  # (status, branch info for mini.statusline) — see home/neovim/ui.nix.
  programs.nixvim.plugins.lazygit = {
    enable = true;
    settings = {
      floating_window_scaling_factor = 0.95;
      floating_window_winblend = 0;
    };
  };
}
