{
  lib,
  buildPythonApplication,
  fetchPypi,
  hatchling,
  hatch-vcs,
  docker,
  keyring,
  pyperclip,
  sqlparse,
  textual-fastdatatable,
  textual,
  # DB drivers — sqlite ships with the stdlib; add the ones matching the
  # databases already in home.packages (postgresql_17, mysql84).
  pymysql,
  psycopg2,
}:

buildPythonApplication rec {
  pname = "sqlit-tui";
  version = "1.5.2";
  pyproject = true;

  src = fetchPypi {
    pname = "sqlit_tui";
    inherit version;
    hash = "sha256-d/3H4Ylk2eAH5TgpbQeIg8w7gvDMnDXtypbLrwz8KvM=";
  };

  # hatch-vcs reads the version from git tags, absent in the PyPI sdist.
  env.HATCH_VCS_PRETEND_VERSION = version;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    docker
    keyring
    pyperclip
    sqlparse
    textual-fastdatatable
    pymysql
    psycopg2
  ]
  ++ textual.optional-dependencies.syntax;

  doCheck = false;

  meta = {
    description = "User-friendly TUI for SQL databases";
    homepage = "https://github.com/Maxteabag/sqlit";
    license = lib.licenses.mit;
    mainProgram = "sqlit";
  };
}
