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
    (python3Packages.callPackage ./_pkgs/sqlit.nix { })
    visidata
    csvlens
    dua
    dust
    mysql84
    postgresql_17
    redis
    ollama
    claude-code
    opencode
    herdr
    caddy
    devenv
    just
    (callPackage ./_pkgs/ldcli.nix { })
    (callPackage ./_pkgs/backlog.nix { })
    agent-browser
    graphite-cli
    prek
    superfile
    taskwarrior3
    rdap
    sops
    age
    jujutsu

    nil
    nixfmt
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
