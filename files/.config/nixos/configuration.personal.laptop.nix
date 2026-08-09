# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./configuration.common.nix ];

  users.users.embercraze = {
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = config.my.sharedUserExtraGroups;
    packages =
      config.my.sharedUserPackages
      ++ (with pkgs; [
        networkmanagerapplet
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
