_:

{
  programs.nixvim = {
    plugins.luasnip.enable = true;

    plugins.blink-cmp = {
      enable = true;
      settings = {
        # "enter" maps <CR> to accept the selected item while keeping the
        # default <C-y> accept, <C-n>/<C-p> nav, and <Tab>/<S-Tab> snippet
        # jumps. With "default" (blink's literal default), <CR> isn't bound
        # at all and falls through to a literal newline.
        keymap.preset = "enter";
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
