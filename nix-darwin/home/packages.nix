{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ripgrep
    fzf
    bat
    eza
    jq
    hurl
    process-compose
    aspell
    figlet
    glow
    gum
    vhs
    mailpit
    lazysql
    harlequin
    mysql84
    postgresql_17
    redis
    claude-code
    opencode
    caddy
    devenv
    (callPackage ./_pkgs/ldcli.nix { })
    (callPackage ./_pkgs/backlog.nix { })
    agent-browser
    graphite-cli
    prek
    taskwarrior3
    rdap
    sops
    age

    nil
    nixfmt-rfc-style
    statix
    deadnix

    # language servers (shared by nvim + claude code)
    typescript-language-server
    vscode-langservers-extracted
    svelte-language-server
    yaml-language-server
    bash-language-server
    lua-language-server
    gopls
    marksman
    taplo
    tailwindcss-language-server
    astro-language-server
  ];
}
