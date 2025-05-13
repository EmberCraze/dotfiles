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

  version = "1.5.6";
  pname = "windsurf";

  executableName = "windsurf";
  longName = "Windsurf";
  shortName = "windsurf";

  src = fetchurl {
	url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/164066c0badcfdea724847b1a24fd88eb96f9510/Windsurf-linux-x64-1.5.6.tar.gz";
    hash = "sha256-WwHOCROdfYkyvlwpehxxqJGimYJbLVME8/7SI2cYjss=";
  };

  sourceRoot = "Windsurf";

  tests = nixosTests.vscodium;

  updateScript = "nil";

  meta = with lib; {
    description = "The first agentic IDE, and then some";
  };
}
