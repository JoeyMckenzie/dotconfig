{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellScriptBin,
  coreutils,
}:

# Laravel's official language server. Distributed as self-contained static
# binaries per platform (bundling their own PHP runtime) via GitHub releases —
# NOT built from source, so we just fetchurl the prebuilt `server-*` asset.
# This is the arm64-darwin build; bump `version` + `hash` together on a new
# release (hash = the asset's sha256 digest from
# `gh release view --repo laravel/lsp --json assets`).
#
# The binary speaks LSP over stdio directly (its default command is the LSP
# server; there is no download-at-runtime step). At runtime it shells out to
# the PROJECT's php (Herd/Valet/local) for indexing scripts — independent of
# this binary's own bundled PHP.
#
# WHY THE WRAPPER: the app is a Laravel Zero PHAR. When running as a compiled
# binary it hardcodes its log path to `dirname(Phar::running(false))/logs/
# lsp.log` — i.e. a `logs/` dir right next to the binary — and this is NOT
# overridable by any env var (it's set unconditionally in the app's
# AppServiceProvider, bypassing config/LARAVEL_STORAGE_PATH). The nix store is
# read-only, so launching the store binary directly dies with `mkdir():
# Permission denied` before it ever serves a request. We therefore copy the
# binary into a writable per-user cache dir once per version and exec that, so
# its sibling `logs/` dir lands somewhere writable.
let
  version = "0.0.28";

  server = stdenvNoCC.mkDerivation {
    pname = "laravel-lsp-server";
    inherit version;

    src = fetchurl {
      url = "https://github.com/laravel/lsp/releases/download/v${version}/server-v${version}-arm64-darwin";
      hash = "sha256-pTJr664olashzLQR/YVKRhd1vCCcsEYQtS0+qLKctn0=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm555 $src $out/libexec/laravel-lsp/laravel-lsp
      runHook postInstall
    '';

    meta = {
      description = "Laravel's framework-aware language server (raw arm64-darwin binary)";
      homepage = "https://github.com/laravel/lsp";
      license = lib.licenses.mit;
      platforms = [ "aarch64-darwin" ];
    };
  };
in
writeShellScriptBin "laravel-lsp" ''
  set -eu
  dir="''${XDG_CACHE_HOME:-$HOME/.cache}/laravel-lsp/${version}"
  bin="$dir/laravel-lsp"
  if [ ! -x "$bin" ]; then
    ${coreutils}/bin/mkdir -p "$dir"
    # Copy via a temp file + atomic rename so concurrent editor launches racing
    # the first run can't exec a half-written binary.
    tmp="$(${coreutils}/bin/mktemp "$dir/.laravel-lsp.XXXXXX")"
    ${coreutils}/bin/cp ${server}/libexec/laravel-lsp/laravel-lsp "$tmp"
    ${coreutils}/bin/chmod 0755 "$tmp"
    ${coreutils}/bin/mv -f "$tmp" "$bin"
  fi
  exec "$bin" "$@"
''
