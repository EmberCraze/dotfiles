# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  networking = {
	  # Enable networking
	networkmanager = {
		enable = true;
		# dns = "none";
	 };
	firewall.checkReversePath = false; # for wireguard
	nameservers = [ "45.90.28.223" "45.90.30.223" ];
  };
  services.resolved.enable = true; # for wireguard


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
        i3blocks
		i3status-rust
		scrot # for screenshot on lock
      ];
    };
  };
  programs.i3lock.enable = true;

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
  services.ratbagd.enable = true; # logitecs mouse driver
  services.pulseaudio.enable = true;
  services.gnome.gnome-keyring.enable = true;


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
      arandr
      ripgrep
      brave
      brightnessctl
      libnotify
      dunst
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
      jetbrains.pycharm
      nemo-with-extensions # file browser
      lua-language-server
      nodePackages_latest.bash-language-server
	  openssl
	  signal-desktop
	  ltex-ls-plus
	  xkb-switch
	  gh # github cli
	  terraform
	  blanket
	  vscode # desktop computer
	  usbimager
	  piper # Logic mouse programmer
	  kdePackages.filelight
	  super-productivity
	  gimp
	  claude-code
	  gemini-cli
      jujutsu
	  opencode
	  audacity
      foliate
	  jq
	  obsidian
	  ansible
	  ffmpeg
	  tail-tray
	  vscode-json-languageserver # json lsp
    ];
  };

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

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.mononoki
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


  # Hardware stuff
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

  # Enable docker
  virtualisation.docker.enable = true;
}
