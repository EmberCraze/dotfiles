# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./configuration.common.nix ];

  xdg.mime.defaultApplications = {
     "text/html" = "librewolf.desktop";
     "x-scheme-handler/http" = "librewolf.desktop";
     "x-scheme-handler/https" = "librewolf.desktop";
     "x-scheme-handler/about" = "librewolf.desktop";
     "x-scheme-handler/unknown" = "librewolf.desktop";
  };

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
      nodejs
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
      nemo-with-extensions # file browser
      lua-language-server
      bash-language-server
	  openssl
	  signal-desktop
	  ltex-ls-plus
	  xkb-switch
	  gh # github cli
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
      audacity
      foliate
      opencode
      inkscape
      blender
      android-tools
      scrcpy
      telegram-desktop
      jq
      wdisplays
      codex
	  just
	  tail-tray
	  logseq
	  google-chrome
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
                "electron-37.10.3"
				"electron-39.8.10"
              ];

  programs.openvpn3.enable = true;
  security.pam.services.swaylock = {};

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.mononoki
	poppins
	libertinus
  ];

  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [
	fuzzel swaylock mako swayidle i3bar-river waybar # niri
	xwayland-satellite # xwayland support
  ];

}
