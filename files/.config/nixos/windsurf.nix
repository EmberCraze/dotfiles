{
  lib,
  stdenv,
  pkgs,
  callPackage,
  fetchurl,
  nixosTests,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:
# https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest
callPackage "${pkgs.path}/pkgs/applications/editors/vscode/generic.nix" rec {
  inherit commandLineArgs useVSCodeRipgrep;

  version = "1.2.6";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
	url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/d08b8ea13d580d24be204c76e5dd1651d7234cd2/Windsurf-linux-x64-1.2.6.tar.gz";
    hash = "sha256-rXHrArkwLUzxQTwKg3Y/Rf5FXlvnTunhR3vqLoWgLKo=";
  };

  sourceRoot = "Windsurf";

  tests = nixosTests.vscodium;

  updateScript = "nil";

  meta = with lib; {
    description = "The first agentic IDE, and then some";
  };
}
