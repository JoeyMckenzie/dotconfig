{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ripgrep
    fzf
    bat
    eza
    jq
    process-compose
    aspell
    figlet
    glow
    mailpit
    lazysql
    harlequin
    mysql84
    postgresql_17
    redis
    claude-code
    caddy
    devenv
    (callPackage ./_pkgs/ldcli.nix { })
    agent-browser
    graphite-cli
    prek
    taskwarrior3

    nil
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
