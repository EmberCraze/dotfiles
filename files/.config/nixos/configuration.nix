# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nixpkgs.overlays = [
    (self: super: {
      windsurf = self.callPackage ./windsurf.nix {};
    })
  ];

  # networking.hostName = "nixos"; # Define your hostname.

  networking.nameservers = [ "45.90.28.223" "45.90.30.223" ];
  networking.networkmanager.dns = "none";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
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

  # Configure keymap in X11
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
        i3lock
        i3blocks
		i3status-rust
      ];
    };
  };

  services.displayManager = {
    enable = true;
    defaultSession = "none+i3";
  };

  # Disable pipewire
  services.pipewire.enable = false;


  # Add bluetooth management software
  services.blueman.enable = true;

  services.autorandr.enable = true;
  services.acpid.enable = true;
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.sensible
      tmuxPlugins.yank
      tmuxPlugins.catppuccin
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.embercraze = {
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      neovim
      networkmanagerapplet
      alacritty
      git
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
      python312
      tabnine
      codeium
      arandr
      ripgrep
      brave
      brightnessctl
      libnotify
      dunst
      black
      pyright
      killall
      xorg.xkill
      playerctl
      peek
      nodePackages.pnpm
      nodePackages.nodejs
      mpv
      nomacs
      nodePackages_latest.typescript-language-server # ts lsp
      nodePackages_latest.prettier # js formatter
      code-cursor
      gparted
      ruff # python code formatter and linter
      uv # python package manager
      stylua # lua code formatter
      feh
      redshift # eye strain filter
      jetbrains.pycharm-professional
      nemo-with-extensions
      lua-language-server
      nodePackages_latest.bash-language-server
      bitwarden-cli
      xautolock
	  windsurf
	  openssl
	  signal-desktop
	  ltex-ls-plus
	  vscode
	  gnome-keyring
	  xkb-switch
    ];
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.mononoki
    # (nerdfonts.override { fonts = [ "Mononoki" ]; })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];
  environment.shells = with pkgs; [ zsh ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [];
  programs.firefox.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Hardware stuff
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
  hardware.acpilight.enable = true;



  # Enable docker
  virtualisation.docker.enable = true;
}
