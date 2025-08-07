{ config, lib, pkgs, pkgs-unstable, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.gui = {
    enable = mkEnableOption "GUI desktop environment and applications";
  };

  config = mkIf config.modules.gui.enable {
    # X11/Wayland and desktop environment
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # D-Bus (required for GUI applications and desktop environments)
    services.dbus.enable = true;

    services.flatpak.enable = true;

    # GUI-specific programs
    programs.dconf.enable = true;

    # Home Manager dconf settings for GNOME
    home-manager.users.nick = {
      dconf.enable = true;
      dconf.settings = {
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
        "org/gnome/desktop/interface" = {
          enable-animations = false;
          cursor-size = 32;  # Default is 24
        };
        "org/gnome/desktop/wm/preferences" = {
          resize-with-right-button = true;
        };
        "org/gnome/desktop/wm/keybindings" = {
          show-desktop = [ "<Super>d" ];
        };
        "org/gnome/shell/keybindings" = {
          toggle-message-tray = [];  # Disables Super+V
        };
      };
    };

    # Fonts
    fonts.fontconfig = {
      enable = true;
      localConf = ''
        <!-- Replace Helvetica with Arial -->
        <match target="pattern">
          <test qual="any" name="family">
            <string>Helvetica</string>
          </test>
          <edit name="family" mode="assign" binding="strong">
            <string>Arial</string>
          </edit>
        </match>
      '';
    };

    # GUI applications and tools
    environment.systemPackages = with pkgs; [
      # Fonts
      corefonts
      inter
      roboto-mono
      jetbrains-mono
      noto-fonts-emoji

      # Clipboard and notification support
      wl-clipboard
      libnotify

      # Terminal applications
      ghostty

      # Browsers
      firefox
      google-chrome

      # Communication
      slack
      discord
      signal-desktop

      # Productivity
      obsidian
      newsflash
      syncthing

      # Development
      vscode
      code-cursor

      # GNOME applications
      gnome-tweaks
      eog
      resources
      tuba
      gnome-sound-recorder

      # Security
      _1password-gui

      # Media and utilities
      zoom-us
      x11docker
      pkgs-unstable.euphonica
    ];

    # Environment variables for Wayland
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
