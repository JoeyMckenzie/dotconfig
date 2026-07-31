{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
}:

let
  version = "17.2.1";

  sources = {
    "aarch64-darwin" = {
      arch = "darwin-arm64";
      hash = "sha256-t17dsZup7EAf7l7LNbPOtd3Ehwjpi1oRMTbfXWXyvtg=";
    };
    "x86_64-darwin" = {
      arch = "darwin-x64";
      hash = "sha256-0jwZfZMkMSLvmjWiR73YUHXEwTVt0fpKCA+qotrkuQU=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "oh-my-pi: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-${source.arch}";
    inherit (source) hash;
  };

  nativeBuildInputs = [ installShellFiles ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/omp

    export HOME=$TMPDIR
    installShellCompletion --cmd omp \
      --bash <($out/bin/omp completions bash) \
      --fish <($out/bin/omp completions fish) \
      --zsh <($out/bin/omp completions zsh)

    runHook postInstall
  '';

  meta = {
    description = "AI coding agent with an integrated IDE tool harness";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    platforms = lib.attrNames sources;
    mainProgram = "omp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
