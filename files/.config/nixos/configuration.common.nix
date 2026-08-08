# Shared NixOS configuration used by both machines.

{ config, pkgs, lib, ... }:

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
  ];

  environment.shells = with pkgs; [ zsh ];

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
