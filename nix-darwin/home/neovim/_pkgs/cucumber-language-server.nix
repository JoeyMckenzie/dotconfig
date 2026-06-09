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
    hash = lib.fakeHash;
  };

  npmDepsHash = lib.fakeHash;

  dontNpmBuild = false;

  meta = {
    description = "LSP for Gherkin/Cucumber .feature files";
    homepage = "https://github.com/cucumber/language-server";
    license = lib.licenses.mit;
    mainProgram = "cucumber-language-server";
  };
}
