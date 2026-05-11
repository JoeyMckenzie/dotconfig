{ ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;
    extensions.fzf-native.enable = true;
    settings.defaults = {
      file_ignore_patterns = [
        "%.git/"
        "node_modules/"
        "vendor/"
        "%.phpstan%.cache/"
        "storage/framework/"
        "bootstrap/cache/"
        "%.worktrees/"
        "target/"
        "dist/"
        "%.next/"
      ];
      path_display = [ "truncate" ];
    };
  };
}
