{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "1.0.0-beta.12";

  sources = {
    "aarch64-darwin" = {
      asset = "rustfs-macos-aarch64-v${version}.zip";
      hash = "sha256-9SZu2iRfpNq1rPKL73u6tsHafz6Vdd3H24A4lBB+CfU=";
    };
    "aarch64-linux" = {
      asset = "rustfs-linux-aarch64-musl-v${version}.zip";
      hash = "sha256-GmQlFFl3xVoFVJqnL5r1vTFIk6dCTjUr/oUv5o/CtQw=";
    };
    "x86_64-linux" = {
      asset = "rustfs-linux-x86_64-musl-v${version}.zip";
      hash = "sha256-aDvvFiR6sEvtt20ERHNvKG0hlDN10tV9Le2ewndJhCc=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "rustfs: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "rustfs";
  inherit version;

  src = fetchurl {
    url = "https://github.com/rustfs/rustfs/releases/download/${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 rustfs $out/bin/rustfs
    runHook postInstall
  '';

  meta = {
    description = "High-performance distributed object storage, S3-compatible MinIO alternative written in Rust";
    homepage = "https://github.com/rustfs/rustfs";
    license = lib.licenses.asl20;
    platforms = lib.attrNames sources;
    mainProgram = "rustfs";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
