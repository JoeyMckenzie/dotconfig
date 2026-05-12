{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "3.0.4";

  sources = {
    "aarch64-darwin" = {
      arch = "darwin_arm64";
      hash = "sha256-ECOENt5UIXjE0oZlLPLGYYf4AL6gbsnQopHmfUfiaVw=";
    };
    "x86_64-darwin" = {
      arch = "darwin_amd64";
      hash = "sha256-+6K83o6BLkSuZFF/ZLdeZA1nixzNYPyoVifTg6brhus=";
    };
    "aarch64-linux" = {
      arch = "linux_arm64";
      hash = "sha256-9Ocn7rI0uFI5+QSuuyDc4sCpU8ec4e+fTu8Y1srqzkw=";
    };
    "x86_64-linux" = {
      arch = "linux_amd64";
      hash = "sha256-gB8QGVPkGuaNw2IPY2GZqYTxD2UhlYXcoFm+xbtVfPo=";
    };
  };

  source = sources.${stdenvNoCC.hostPlatform.system} or (throw "ldcli: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "ldcli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/launchdarkly/ldcli/releases/download/v${version}/ldcli_${version}_${source.arch}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 ldcli $out/bin/ldcli
    runHook postInstall
  '';

  meta = {
    description = "CLI for managing LaunchDarkly feature flags";
    homepage = "https://launchdarkly.com/docs/home/getting-started/ldcli";
    license = lib.licenses.asl20;
    platforms = lib.attrNames sources;
    mainProgram = "ldcli";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
