{ pkgs, ... }:

{
  packages = [
    pkgs.black
    pkgs.ruff
    pkgs.pyright
  ];

  languages.python = {
    enable = true;
    version = "3.12";
    venv.enable = true;
    venv.requirements = ./requirements.txt;
  };

  scripts.lint-code.exec = ''
    black --check .
    ruff check .
    pyright .
  '';

  scripts.starter-kit.exec = ''
    python -m starter_kit
  '';
}
