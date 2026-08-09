# Shared NixOS configuration used by both machines.

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
  options.my.sharedUserPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [];
    description = "Packages shared by users on all configured machines.";
  };

  options.my.sharedUserExtraGroups = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Extra groups shared by users on all configured machines.";
  };

  config = {
    networking = {
	# Enable networking
    networkmanager = {
      enable = true;
    };
    firewall.checkReversePath = false; # for wireguard
    nameservers = [ "45.90.28.223" "45.90.30.223" ];
  };

  services.resolved.enable = true;

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "se,us,iq";
      options = "grp:alt_shift_toggle";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3blocks
        i3status-rust
        scrot
      ];
    };
  };

  programs.i3lock.enable = true;
  security.pam.services.swaylock = {};

  services.displayManager = {
    ly.enable = true;
    defaultSession = "niri";
  };

  # Required for niri screen sharing
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.blueman.enable = false;
  services.autorandr.enable = true;
  services.acpid.enable = true;
  # services.ratbagd.enable = true; # Mouse driver
  services.pulseaudio.enable = false;
  services.gnome.gnome-keyring.enable = true;
  services.tailscale.enable = true;

  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [];

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Preferences = {
        "apz.autoscroll.enabled" = true;
      };
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.sensible
      tmuxPlugins.yank
      tmuxPlugins.catppuccin
    ];
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "embercraze";
        email = "maher.shaker@live.se";
      };
    };
  };

  programs.niri.enable = true;

  my.sharedUserPackages = with pkgs; [
    neovim
    alacritty
    gnumake
    stow
    pavucontrol
    rofi
    keychain
    zoxide
    bottom
    lsd
    bat
    fzf
    slack
    wireguard-tools
    lazygit
    flameshot
    xclip
    gcc
    pyright
    python313
    arandr
    ripgrep
    brave
    brightnessctl
    libnotify
    killall
    xkill
    playerctl
    peek
    pnpm
    mpv
    nomacs
    typescript-language-server # ts lsp
    prettier # js formatter
    gparted
    ruff # python code formatter and linter
    uv # python package manager
    stylua # lua code formatter
    feh
    redshift # eye strain filter
    nemo-with-extensions # file browser
    lua-language-server
    bash-language-server
    openssl
    ltex-ls-plus
    xkb-switch
    gh # github cli
    blanket
    usbimager
    kdePackages.filelight
    gimp
    claude-code
    foliate
    opencode
    jq
    tail-tray
    wdisplays # wayland
    ghostty
    herdr
    vicinae
  ];

  my.sharedUserExtraGroups = [ "networkmanager" "wheel" "docker" ];

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.mononoki
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fuzzel
    swaylock
    mako
    swayidle
    i3bar-river
    waybar
    xwayland-satellite
    librewolfCurrentWorkspace
    librewolfCurrentWorkspaceDesktop
    braveCurrentWorkspace
    braveCurrentWorkspaceDesktop
  ];

  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
    BROWSER = "brave-current-workspace";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.mime.defaultApplications = {
    "text/html" = "brave-current-workspace.desktop";
    "x-scheme-handler/http" = "brave-current-workspace.desktop";
    "x-scheme-handler/https" = "brave-current-workspace.desktop";
    "x-scheme-handler/about" = "brave-current-workspace.desktop";
    "x-scheme-handler/unknown" = "brave-current-workspace.desktop";
  };

  # Enable the packaged user unit with a PATH that exposes user-profile apps.
  systemd.user.services.vicinae = {
    description = "Vicinae Launcher Daemon";
    documentation = [ "https://docs.vicinae.com" ];
    requires = [ "dbus.socket" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    environment.PATH = lib.mkForce "%h/.local/bin:/run/wrappers/bin:%h/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --replace";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RestartSec = 60;
      KillMode = "process";
    };
  };

  hardware = {
    acpilight.enable = true;
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };
  };

    virtualisation.docker.enable = true;
  };
}
