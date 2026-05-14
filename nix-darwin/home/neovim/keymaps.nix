{ ... }:

{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>w<cr>";
      options.desc = "Save";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<cr>";
      options.desc = "Quit";
    }

    # Pick (mini.pick + mini.extra)
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Pick files<cr>";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fF";
      # mini.pick.builtin.files has no hidden/no-ignore flags; drop to a raw
      # rg invocation via builtin.cli that bypasses .gitignore and includes
      # dotfiles (but still excludes .git/).
      action = "<cmd>lua MiniPick.builtin.cli({ command = { 'rg', '--files', '--hidden', '--no-ignore', '--glob', '!.git' } }, { source = { name = 'Files (hidden + ignored)' } })<cr>";
      options.desc = "Find files (hidden + ignored)";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>Pick grep_live<cr>";
      options.desc = "Live grep";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>Pick buffers<cr>";
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>Pick oldfiles<cr>";
      options.desc = "Recent files";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>Pick help<cr>";
      options.desc = "Help tags";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action = "<cmd>Pick diagnostic<cr>";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>fs";
      action = "<cmd>Pick lsp scope='document_symbol'<cr>";
      options.desc = "Document symbols";
    }

    # File explorer
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>lua if not MiniFiles.close() then MiniFiles.open() end<cr>";
      options.desc = "File explorer";
    }

    # Window navigation
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
    }

    # Buffer nav
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<cr>";
      options.desc = "Prev buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      # MiniBufremove preserves window layout when deleting the last buffer
      # in a window (plain :bdelete kills the window).
      action = "<cmd>lua MiniBufremove.delete()<cr>";
      options.desc = "Delete buffer";
    }

    # Clear search highlight
    {
      mode = "n";
      key = "<esc>";
      action = "<cmd>noh<cr>";
    }

    # Diagnostics
    {
      mode = "n";
      key = "]d";
      action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
      options.desc = "Next diagnostic";
    }
    {
      mode = "n";
      key = "[d";
      action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
      options.desc = "Prev diagnostic";
    }
    {
      mode = "n";
      key = "<leader>cd";
      action.__raw = "function() vim.diagnostic.open_float() end";
      options.desc = "Line diagnostics";
    }

    # Format
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cf";
      action.__raw = "function() require('conform').format({ async = true, lsp_fallback = true }) end";
      options.desc = "Format";
    }

    # Aerial symbol outline
    {
      mode = "n";
      key = "<leader>co";
      action = "<cmd>AerialToggle!<cr>";
      options.desc = "Symbol outline";
    }
    {
      mode = "n";
      key = "[s";
      action = "<cmd>AerialPrev<cr>";
      options.desc = "Prev symbol";
    }
    {
      mode = "n";
      key = "]s";
      action = "<cmd>AerialNext<cr>";
      options.desc = "Next symbol";
    }

    # Lazygit (kdheepak/lazygit.nvim — needs lazygit on PATH via programs.lazygit)
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options.desc = "Lazygit";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>lua MiniGit.show_at_cursor()<cr>";
      options.desc = "Git blame at cursor";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>gf";
      action = "<cmd>lua MiniGit.show_range_history()<cr>";
      options.desc = "Git file history";
    }

    # Stay centered when scrolling
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
    }
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
    }
  ];
}
