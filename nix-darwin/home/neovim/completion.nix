{ ... }:

{
  programs.nixvim = {
    plugins.luasnip.enable = true;

    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        completion = {
          accept.auto_brackets.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text.enabled = true;
        };
        signature.enabled = true;
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        snippets.preset = "luasnip";
      };
    };
  };
}
