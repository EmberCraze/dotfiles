# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  orcaVersion = "1.4.197";
  orcaAppImage = pkgs.appimageTools.extract {
    pname = "orca";
    version = orcaVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${orcaVersion}/orca-linux.AppImage";
      sha256 = "0ss14scxg0l10b2mxvafcszp8m6cdnqnnr2clpx11w0z2lnldj2b";
    };
  };
  orcaIde = pkgs.appimageTools.wrapAppImage {
    pname = "orca";
    version = orcaVersion;
    src = orcaAppImage;
    extraPkgs = pkgs: [ pkgs.libsecret ];
    extraInstallCommands = ''
      install -Dm644 ${orcaAppImage}/orca-ide.desktop \
        $out/share/applications/orca-ide.desktop
      cp -r ${orcaAppImage}/usr/share/icons $out/share/
      substituteInPlace $out/share/applications/orca-ide.desktop \
        --replace-fail "Exec=AppRun %U" "Exec=orca %U"
    '';
  };
in

{
  imports = [ ./configuration.common.nix ];

  users.users.embercraze = {
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = config.my.sharedUserExtraGroups;
    packages =
      config.my.sharedUserPackages
      ++ (with pkgs; [
        # networkmanagerapplet
        # dunst
        # code-cursor
        vscode # desktop computer
        # piper # Logic mouse programmer
        # super-productivity
        # gemini-cli
        # jujutsu
        # audacity
        inkscape
        # blender
        android-tools
        scrcpy
        telegram-desktop
        codex
        just
        logseq
        google-chrome
        orcaIde
      ]);
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-37.10.3"
    "electron-39.8.10"
  ];

  programs.openvpn3.enable = true;
  fonts.packages = with pkgs; [
    poppins
    libertinus
  ];

  services.geoclue2.enable = true;
  services.redshift = {
    enable = true;
    package = pkgs.gammastep;
  };
  location.provider = "geoclue2";

  security.polkit.extraConfig = ''
    // Fingerprint templates are per-user; permit this account to manage its own.
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll" &&
          subject.user == "embercraze") {
        return polkit.Result.YES;
      }
    });
  '';

}
