_:

{
  programs.nixvim.plugins.aerial = {
    enable = true;
    settings = {
      # Try treesitter first (cheap, no LSP attach needed), then LSP for
      # richer symbol info, then the markdown / man fallbacks.
      backends = [
        "treesitter"
        "lsp"
        "markdown"
        "man"
      ];

      # Single shared outline window — switching buffers updates it instead
      # of opening a new one per window.
      attach_mode = "global";

      autojump = false;

      # Close aerial when it's the only window left so `:q` from the
      # outline doesn't leave a stranded session.
      close_automatic_events = [ "unsupported" ];

      layout = {
        default_direction = "right";
        min_width = 28;
        max_width = [
          0.2
          40
        ];
      };

      show_guides = true;
    };
  };
}
