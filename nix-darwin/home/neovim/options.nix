_:

{
  programs.nixvim.opts = {
    number = true;
    relativenumber = true;
    swapfile = false;
    undofile = true;

    scrolloff = 8;
    sidescrolloff = 8;

    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    softtabstop = 2;
    smartindent = true;

    termguicolors = true;
    cursorline = true;
    signcolumn = "yes";
    wrap = false;

    ignorecase = true;
    smartcase = true;

    splitright = true;
    splitbelow = true;

    clipboard = "unnamedplus";

    updatetime = 250;
    timeoutlen = 300;

    completeopt = [
      "menu"
      "menuone"
      "noselect"
    ];
  };
}
