# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  librewolfCurrentWorkspace = pkgs.writeShellApplication {
    name = "librewolf-current-workspace";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      librewolf
      niri
    ];
    text = builtins.readFile ./scripts/librewolf-current-workspace.sh;
  };

  librewolfCurrentWorkspaceDesktop = pkgs.makeDesktopItem {
    name = "librewolf-current-workspace";
    desktopName = "LibreWolf Current Workspace";
    exec = "${librewolfCurrentWorkspace}/bin/librewolf-current-workspace %u";
    terminal = false;
    mimeTypes = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };

  braveCurrentWorkspace = pkgs.writeShellApplication {
    name = "brave-current-workspace";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      brave
      niri
    ];
    text = builtins.readFile ./scripts/brave-current-workspace.sh;
  };

  braveCurrentWorkspaceDesktop = pkgs.makeDesktopItem {
    name = "brave-current-workspace";
    desktopName = "Brave Current Workspace";
    exec = "${braveCurrentWorkspace}/bin/brave-current-workspace %u";
    terminal = false;
    mimeTypes = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];
  };
in
{
  imports = [ ./configuration.common.nix ];

  services.dbus.packages = [ pkgs.nautilus ]; # Required by xdg-desktop-portal-gnome for niri
  services.fprintd.enable = true; # fingerprint reader

  services.gvfs.enable = true; # for nemo remote file explorer
  services.upower.enable = true; # for battery indicator in Dank bar

  xdg.mime.defaultApplications = {
     "text/html" = "brave-current-workspace.desktop";
     "x-scheme-handler/http" = "brave-current-workspace.desktop";
     "x-scheme-handler/https" = "brave-current-workspace.desktop";
     "x-scheme-handler/about" = "brave-current-workspace.desktop";
     "x-scheme-handler/unknown" = "brave-current-workspace.desktop";
  };

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
      ghostty
      herdr
      vicinae
    ]);
  };

  # Autostart the vicinae launcher daemon with the graphical session.
  # Mirrors the unit shipped in ${pkgs.vicinae}/share/systemd/user/vicinae.service,
  # which is never enabled by just installing the package. Redefining it here
  # (rather than symlinking the packaged unit into graphical-session.target.wants)
  # because /etc/systemd/user is a read-only store dir we can't add subdirs to.
  systemd.user.services.vicinae = {
    description = "Vicinae Launcher Daemon";
    documentation = [ "https://docs.vicinae.com" ];
    requires = [ "dbus.socket" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    # Give launched apps a real user PATH — the default unit PATH only has
    # coreutils etc., so bare Exec= entries in .desktop files (e.g. wdisplays)
    # fail to resolve.
    environment.PATH = lib.mkForce "/home/embercraze/.local/bin:/run/wrappers/bin:/home/embercraze/.nix-profile/bin:/etc/profiles/per-user/embercraze/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --replace";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RestartSec = 60;
      KillMode = "process";
    };
  };

  programs.tmux.keyMode = "vi";
  programs.dms-shell.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	pipewire # niri
	nodejs
    librewolfCurrentWorkspace
    librewolfCurrentWorkspaceDesktop
    braveCurrentWorkspace
    braveCurrentWorkspaceDesktop
  ];
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
  '';
};

  environment.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
	MOZ_ENABLE_WAYLAND="1";
    BROWSER = "brave-current-workspace";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
	GDK_BACKEND = "wayland";
	CLUTTER_BACKEND = "wayland";
  };

}
