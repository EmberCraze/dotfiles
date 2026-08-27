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
        # T3 web as an app-mode Brave window, launchable from vicinae
        (makeDesktopItem {
          name = "t3-web";
          desktopName = "T3code";
          genericName = "T3 Chat";
          exec = "brave --app=https://maher01-dev-hel1.tail48d7ff.ts.net/ --ozone-platform=wayland";
          icon = fetchurl {
            url = "https://t3.codes/apple-touch-icon.png";
            sha256 = "0382rb8d8757qp361nlm4gnpcbymnjis2v8kair5w9bxzmpvvwnk";
          };
          terminal = false;
          categories = [ "Development" ];
        })
        # OpenChamber as an app-mode Brave window, launchable from vicinae
        (makeDesktopItem {
          name = "openchamber-web";
          desktopName = "OpenChamber";
          genericName = "OpenChamber";
          exec = "brave --app=https://openchamber.maher.gigapay.dev/ --ozone-platform=wayland";
          icon = fetchurl {
            url = "https://openchamber.maher.gigapay.dev/apple-touch-icon.png";
            sha256 = "0pamjqxins1bqh8k6i26sj96q91jxndh6hjx6gryymmhcmzh9w09";
          };
          terminal = false;
          categories = [ "Development" ];
        })
        adwaita-icon-theme # DMS dock icon fallback
        hicolor-icon-theme
        papirus-icon-theme
      ]);
  };

  programs.tmux.keyMode = "vi";

}
