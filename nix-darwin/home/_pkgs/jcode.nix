{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.63.0";
in
stdenvNoCC.mkDerivation {
  pname = "jcode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/1jehuang/jcode/releases/download/v${version}/jcode-macos-aarch64.tar.gz";
    hash = "sha256-hCs/Rknf1FfnPnqu/z3tkIzb6e5inlut0yDCCb8AaQg=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 jcode-macos-aarch64 $out/bin/jcode
    runHook postInstall
  '';

  meta = {
    description = "A resource-efficient coding agent harness";
    homepage = "https://github.com/1jehuang/jcode";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "jcode";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
