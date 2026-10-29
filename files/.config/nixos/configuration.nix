# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  bbVersion = "0.47.1";
  bbAppImage = pkgs.appimageTools.extract {
    pname = "bb";
    version = bbVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/get-bb/bb/releases/download/desktop-v${bbVersion}/bb-${bbVersion}-x86_64.AppImage";
      sha256 = "ac40a4fdf9a065ff127d39c3f8394aed2e1c79981b9f1ba416dd7bd97175d2c0";
    };
  };
  bbIde = pkgs.appimageTools.wrapAppImage {
    pname = "bb";
    version = bbVersion;
    src = bbAppImage;
    extraPkgs = pkgs: [ pkgs.libsecret ];
    extraInstallCommands = ''
      install -Dm644 ${bbAppImage}/bb.desktop \
        $out/share/applications/bb.desktop
      cp -r ${bbAppImage}/usr/share/icons $out/share/
      substituteInPlace $out/share/applications/bb.desktop \
        --replace-fail "Exec=AppRun %U" "Exec=bb %U"
    '';
  };
in

{
  imports = [ ./configuration.common.nix ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.embercraze = {
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = config.my.sharedUserExtraGroups;
    packages =
      config.my.sharedUserPackages
      ++ (with pkgs; [
        # dunst  # conflicts with DMS: both claim org.freedesktop.Notifications
        # code-cursor
        # jetbrains.pycharm
        # signal-desktop
        # terraform
        # piper # Logic mouse programmer
        # jujutsu
        # audacity
        # obsidian
        # ansible
        ffmpeg
        vscode-json-languageserver # json lsp
        # zed-editor
        wl-clipboard # wayland
        grim # screenshot flameshot
        # logseq # commented out because of old elektron version
        sox # cloude code voice input
        zathura # pdf reader
        # handy
        # wtype
		vscode
        adwaita-icon-theme # DMS dock icon fallback
        hicolor-icon-theme
        papirus-icon-theme
		(voxtype.override { onnxSupport = true; }) # onnx needed for parakeet models
        bbIde
		codex
      ]);
  };

  # Voxtype voice dictation daemon (recording toggled via niri Mod+V ->
  # `voxtype record toggle`; config lives in ~/.config/voxtype/config.toml)
  systemd.user.services.voxtype = {
    description = "Voxtype push-to-talk voice-to-text daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    # The [osd] quickshell frontend execs `qs`; without it on PATH the OSD
    # child exits immediately and the daemon gives up after 3 retries.
    path = [ pkgs.quickshell "/etc/profiles/per-user/embercraze" ];
    # Custom pill-style OSD (position follows osd.position in config.toml)
    environment.VOXTYPE_OSD_QML_PATH = "/home/embercraze/.config/voxtype/osd";
    serviceConfig = {
      # Via the per-user profile so it always matches the installed package
      ExecStart = "/etc/profiles/per-user/embercraze/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  programs.tmux.keyMode = "vi";

}
