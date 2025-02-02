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

  version = "1.1.0";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
	url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/599ce698a84d43160da884347f22f6b77d0c8415/Windsurf-linux-x64-1.1.2.tar.gz";
    hash = "sha256-QAeq13K6Cnp9YF/bcElG1anchzLvGZHUgi9MWliy1u8=";
  };

  sourceRoot = "Windsurf";

  tests = nixosTests.vscodium;

  updateScript = "nil";

  meta = with lib; {
    description = "The first agentic IDE, and then some";
  };
}
