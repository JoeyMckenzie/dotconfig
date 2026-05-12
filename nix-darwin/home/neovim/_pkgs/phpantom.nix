{
  lib,
  fetchurl,
  runCommand,
  makeRustPlatform,
  rust-bin,
  src,
}:

let
  rustToolchain = rust-bin.stable.latest.default;
  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };

  manifest = (lib.importTOML "${src}/Cargo.toml").package;
  stubsLock = lib.importTOML "${src}/stubs.lock";
  repoParts = lib.splitString "/" stubsLock.repo;
  owner = builtins.elemAt repoParts 0;
  repo = builtins.elemAt repoParts 1;

  stubsTarball = fetchurl {
    url = "https://github.com/${owner}/${repo}/archive/${stubsLock.commit}.tar.gz";
    sha256 = stubsLock.sha256;
  };

  stubsSrc = runCommand "phpstorm-stubs" { } ''
    mkdir -p $out
    tar -xzf ${stubsTarball} --strip-components=1 -C $out
  '';
in
rustPlatform.buildRustPackage {
  pname = manifest.name;
  version = manifest.version;

  src = lib.cleanSource src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  postPatch = ''
    mkdir -p stubs/jetbrains
    cp -a ${stubsSrc} stubs/jetbrains/phpstorm-stubs
    chmod u+wx stubs/jetbrains/phpstorm-stubs
    echo "${stubsLock.commit}" > stubs/jetbrains/phpstorm-stubs/.commit
  '';

  checkFlags = [
    "--test"
    "completion_inheritance"
  ];

  postInstall = ''
    mv $out/bin/phpantom_lsp $out/bin/phpantom-lsp
    ln -s $out/bin/phpantom-lsp $out/bin/phpantom_lsp
  '';

  meta = {
    description = "Fast PHP language server with deep type intelligence";
    homepage = "https://github.com/AJenbo/phpantom_lsp";
    license = lib.licenses.mit;
    mainProgram = "phpantom-lsp";
  };
}
