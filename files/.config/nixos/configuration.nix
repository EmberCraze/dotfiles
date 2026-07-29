# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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
in
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
	ly.enable = true;
	defaultSession = "niri";
  };

  # Pipewire (required for screen sharing on Wayland/niri)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Add bluetooth management software
  services.blueman.enable = true;

  services.autorandr.enable = true;
  services.acpid.enable = true;
  services.ratbagd.enable = true; # logitecs mouse driver
  services.pulseaudio.enable = false;
  services.gnome.gnome-keyring.enable = true;
  services.tailscale.enable = true;
  services.dbus.packages = [ pkgs.nautilus ]; # Required by xdg-desktop-portal-gnome for niri
# fingerprint reader
  services.fprintd.enable = true;

  xdg.mime.defaultApplications = {
     "text/html" = "librewolf-current-workspace.desktop";
     "x-scheme-handler/http" = "librewolf-current-workspace.desktop";
     "x-scheme-handler/https" = "librewolf-current-workspace.desktop";
     "x-scheme-handler/about" = "librewolf-current-workspace.desktop";
     "x-scheme-handler/unknown" = "librewolf-current-workspace.desktop";
  };

xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
  config.common.default = "*";
  config.ScreenCast = {
	  portal = "gnome";
  };
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
      dunst
      pyright
      killall
      xkill
      playerctl
      peek
      pnpm
      mpv
      nomacs
      typescript-language-server # ts lsp
      prettier # js formatter
      code-cursor
      gparted
      ruff # python code formatter and linter
      uv # python package manager
      stylua # lua code formatter
      feh
      redshift # eye strain filter
      # jetbrains.pycharm
      nemo-with-extensions # file browser
      lua-language-server
      bash-language-server
	  openssl
	  # signal-desktop
	  ltex-ls-plus
	  xkb-switch
	  gh # github cli
	  # terraform
	  blanket
	  usbimager
	  # piper # Logic mouse programmer
	  kdePackages.filelight
	  gimp
	  claude-code
      # jujutsu
	  opencode
	  # audacity
      foliate
	  jq
	  # obsidian
	  # ansible
	  ffmpeg
	  tail-tray
	  vscode-json-languageserver # json lsp
	  zed-editor
	  wdisplays # wayland
	  wl-clipboard # wayland
	  grim # screenshot flameshot
	  # logseq # commented out because of old elektron version
	  sox # cloude code voice input
	  zathura # pdf reader
	  # handy
	  # wtype
	  ghostty
	  vicinae
    ];
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
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --replace";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RestartSec = 60;
      KillMode = "process";
    };
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
	keyMode = "vi";
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

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.mononoki
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Workaround: niri 26.04 vendors libdisplay-info-sys 0.3.0, whose build.rs
  # requires the system libdisplay-info to be < 0.4.0. nixos-unstable bumped
  # libdisplay-info to 0.4.0, which breaks the niri build. Build niri against a
  # pinned 0.3.0 (only affects niri; the rest of the system keeps 0.4.0).
  # Remove once niri in nixpkgs is updated to accept libdisplay-info 0.4.
  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.override {
        libdisplay-info = prev.libdisplay-info.overrideAttrs (old: {
          version = "0.3.0";
          src = prev.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "emersion";
            repo = "libdisplay-info";
            rev = "0.3.0";
            hash = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
          };
        });
      };
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fuzzel swaylock mako swayidle i3bar-river waybar pipewire # niri
	nodejs
    librewolfCurrentWorkspace
    librewolfCurrentWorkspaceDesktop
  ];
  security.pam.services.swaylock = {};
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
  '';
};

  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
	MOZ_ENABLE_WAYLAND="1";
    BROWSER = "librewolf-current-workspace";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
	GDK_BACKEND = "wayland";
	CLUTTER_BACKEND = "wayland";
  };


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
