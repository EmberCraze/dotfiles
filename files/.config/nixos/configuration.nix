# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [ ./configuration.common.nix ];

  services.dbus.packages = [ pkgs.nautilus ]; # Required by xdg-desktop-portal-gnome for niri
  services.fprintd.enable = true; # fingerprint reader

  services.gvfs.enable = true; # for nemo remote file explorer
  services.upower.enable = true; # for battery indicator in Dank bar

xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
  config.common.default = "*";
  config.ScreenCast = {
	  portal = "gnome";
  };
};


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.embercraze = {
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = config.my.sharedUserExtraGroups;
    packages = config.my.sharedUserPackages ++ (with pkgs; [
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
      zed-editor
      wl-clipboard # wayland
      grim # screenshot flameshot
      # logseq # commented out because of old elektron version
      sox # cloude code voice input
      zathura # pdf reader
      # handy
      # wtype
    ]);
  };

  programs.tmux.keyMode = "vi";
  programs.dms-shell.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	pipewire # niri
	nodejs
  ];
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
  '';
};

}
