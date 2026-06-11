{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# Upstream npm package: @cucumber/language-server
# https://github.com/cucumber/language-server
#
# On first build, both hashes below will fail and Nix will print the
# correct values. Paste them back in.
buildNpmPackage rec {
  pname = "cucumber-language-server";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "cucumber";
    repo = "language-server";
    rev = "v${version}";
    hash = "sha256-GGPajuy1pOidi7Ux+i7CfLjsRT7vsLQRj1IzTXBWPQY=";
  };

  npmDepsHash = "sha256-sjoj7OLZcvFf0g/6kjhWgt/bUNKbbvYqBszNDYHxf4A=";

  # tree-sitter-cli is an optional transitive dep with a postinstall that
  # downloads a prebuilt binary from GitHub releases — blocked in the Nix
  # sandbox. It's only used as a dev CLI for grammar work, not at LSP
  # runtime, so skip install/rebuild scripts. The build phase still runs
  # `npm run build` normally.
  npmInstallFlags = [ "--ignore-scripts" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  dontNpmBuild = false;

  meta = {
    description = "LSP for Gherkin/Cucumber .feature files";
    homepage = "https://github.com/cucumber/language-server";
    license = lib.licenses.mit;
    mainProgram = "cucumber-language-server";
  };
}
