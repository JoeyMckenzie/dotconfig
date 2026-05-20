{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "1.45.1";

  sources = {
    "aarch64-darwin" = {
      asset = "backlog-bun-darwin-arm64";
      hash = "sha256-T2Of8aPFJp9UWbfeevtrrEg8Jgmhrq9AFsqqD4xo32Q=";
    };
    "x86_64-darwin" = {
      asset = "backlog-bun-darwin-x64";
      hash = "sha256-pvkP7okM49TJO0y6Q4kkkOet1j9DMpk1GOySBQ+HVf0=";
    };
    "aarch64-linux" = {
      asset = "backlog-bun-linux-arm64";
      hash = "sha256-Grf84c+VC7SSzgGMQgAkYm4Y3kRmEFhe0HN1zSQWzM8=";
    };
    "x86_64-linux" = {
      asset = "backlog-bun-linux-x64-baseline";
      hash = "sha256-w0+e704hS55BtVJ3bGvLMwgsKkwEEk9MRBYK4qiZnUs=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "backlog: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "backlog";
  inherit version;

  src = fetchurl {
    url = "https://github.com/MrLesk/Backlog.md/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/backlog
    runHook postInstall
  '';

  meta = {
    description = "Markdown-native task manager and Kanban for Git repositories";
    homepage = "https://github.com/MrLesk/Backlog.md";
    license = lib.licenses.mit;
    platforms = lib.attrNames sources;
    mainProgram = "backlog";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
