# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
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
      ]);
  };

  # Voxtype voice dictation daemon (recording toggled via niri Mod+V ->
  # `voxtype record toggle`; config lives in ~/.config/voxtype/config.toml)
  systemd.user.services.voxtype = {
    description = "Voxtype push-to-talk voice-to-text daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      # Via the per-user profile so it always matches the installed package
      ExecStart = "/etc/profiles/per-user/embercraze/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  programs.tmux.keyMode = "vi";

}
