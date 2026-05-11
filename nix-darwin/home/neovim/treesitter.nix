{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          incremental_selection.enable = true;
        };
      };

      treesitter-context = {
        enable = true;
        settings = {
          max_lines = 3;
          min_window_height = 20;
        };
      };
    };

    extraPackages = [ pkgs.tree-sitter ];
  };
}
