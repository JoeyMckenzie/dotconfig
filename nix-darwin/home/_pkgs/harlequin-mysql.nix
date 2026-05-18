{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  mysql-connector,
  duckdb,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "harlequin-mysql";
  version = "1.3.0";
  pyproject = true;

  src = fetchPypi {
    pname = "harlequin_mysql";
    inherit version;
    hash = "sha256-mIQLDgO+HBbqYsW7ri6Lh80Wslp5E8cjmu46HAYUMTE=";
  };

  build-system = [ hatchling ];

  dependencies = [
    mysql-connector
  ]
  ++ lib.optional (pythonAtLeast "3.14") duckdb;

  doCheck = false;

  pythonRemoveDeps = [
    "harlequin"
    "mysql-connector-python"
  ];

  meta = {
    description = "Harlequin adapter for MySQL";
    homepage = "https://pypi.org/project/harlequin-mysql/";
    license = lib.licenses.mit;
  };
}
