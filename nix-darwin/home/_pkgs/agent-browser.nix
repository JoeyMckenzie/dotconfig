{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.27.0";

  sources = {
    "aarch64-darwin" = {
      arch = "darwin-arm64";
      hash = "sha256-pwP9m3SDbShJz9besnnl2N3Ldoqns9nAA1IWbLkwdXo=";
    };
    "x86_64-darwin" = {
      arch = "darwin-x64";
      hash = "sha256-dILPyn9Vu4dKZJJH1dnCIMQEvlJ+bw4Bw2hhlJqemWk=";
    };
    "aarch64-linux" = {
      arch = "linux-arm64";
      hash = "sha256-Yi1csnOIqO+/am10NLILysSX7W1Vdl7I436qJ9wNuWM=";
    };
    "x86_64-linux" = {
      arch = "linux-x64";
      hash = "sha256-wkmpSMtqYN+UMg4xnDcqXmeUZsqOosxOabrE/MfCcPM=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "agent-browser: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "agent-browser";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-${source.arch}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/agent-browser
    runHook postInstall
  '';

  meta = {
    description = "Browser automation CLI designed for AI agents";
    homepage = "https://agent-browser.dev";
    license = lib.licenses.asl20;
    platforms = lib.attrNames sources;
    mainProgram = "agent-browser";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
