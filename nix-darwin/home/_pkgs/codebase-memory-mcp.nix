{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.8.1";

  sources = {
    "aarch64-darwin" = {
      asset = "codebase-memory-mcp-ui-darwin-arm64.tar.gz";
      hash = "sha256-Ex994KlpGXSmVlAkQ/hsfCnLieYt3EPJVTE0pQdbUvs=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "codebase-memory-mcp: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "codebase-memory-mcp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 codebase-memory-mcp $out/bin/codebase-memory-mcp
    runHook postInstall
  '';

  meta = {
    description = "Local-first codebase memory MCP server with knowledge graph indexing (UI build)";
    homepage = "https://github.com/DeusData/codebase-memory-mcp";
    license = lib.licenses.mit;
    platforms = lib.attrNames sources;
    mainProgram = "codebase-memory-mcp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
