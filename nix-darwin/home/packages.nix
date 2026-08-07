{
  pkgs,
  inputs,
  ...
}:

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
    (callPackage ./_pkgs/rustfs.nix { })
    agent-browser
    graphite-cli
    inputs.tuicr.packages.${pkgs.system}.default
    inputs.hermes-agent.packages.${pkgs.system}.default
    (callPackage ./_pkgs/jcode.nix { })
    prek
    superfile
    taskwarrior3
    rdap
    sops
    age
    croc

    nil
    nixfmt
    statix
    deadnix

    intelephense
    typescript-language-server
    vscode-langservers-extracted
    svelte-language-server
    vue-language-server
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
