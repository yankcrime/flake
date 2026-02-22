{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.gui = {
    enable = mkEnableOption "GUI desktop environment and applications";
  };

  config = mkIf config.modules.gui.enable {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # D-Bus (required for GUI applications and desktop environments)
    services.dbus.enable = true;

    services.flatpak.enable = true;

    # GUI-specific programs
    programs.dconf.enable = true;

    # Niri
    programs.niri.enable = true;
    programs.niri.package = pkgs-unstable.niri;

    # Home Manager dconf settings for GNOME
    home-manager.users.nick = {
      dconf.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Secret" = [
              "gnome-keyring"
            ];
          };
          niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [
              "gtk"
            ];
            "org.freedesktop.impl.portal.Notification" = [
              "gtk"
            ];
            "org.freedesktop.impl.portal.Screenshot" = [
              "gnome"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [
              "gnome"
            ];
            "org.freedesktop.impl.portal.Secret" = [
              "gnome-keyring"
            ];
          };
        };
      };
      
      # Niri configuration
      xdg.configFile."niri/config.kdl".source = ../files/niri/config.kdl;
      xdg.configFile."niriswitcher/config.toml".source = ../files/niriswitcher/config.toml;


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

      programs = {
        fuzzel = {
          enable = true;
          settings = {
            main = {
              prompt = "\"🔍   \"";
              font = "Adwaita Sans";
              line-height = 20;
              layer = "overlay";
              vertical-pad = 12;
            };
            colors = {
              background = "1e1e2edd";
              text = "cdd6f4ff";
              prompt = "bac2deff";
              placeholder = "7f849cff";
              input = "cdd6f4ff";
              match = "f9e2afff";
              selection = "585b70ff";
              selection-text = "cdd6f4ff";
              selection-match = "f9e2afff";
              counter = "7f849cff";
              border = "8c8c8cff";
            };
            border = {
              width = 2;
              radius = 0;
            };
          };
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
      noto-fonts-color-emoji
      font-awesome

      # Clipboard and notification support
      wl-clipboard
      libnotify

      # Terminal applications
      # ghostty
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default

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
      pkgs-unstable.code-cursor

      # GNOME applications
      gnome-tweaks
      eog
      resources
      tuba
      gnome-sound-recorder
      gnomeExtensions.clipboard-history
      gnomeExtensions.dash-to-dock
      gnomeExtensions.arc-menu
      gnomeExtensions.sound-output-device-chooser
      papers
      apostrophe

      pkgs-unstable.dms-shell
      pkgs-unstable.quickshell
      pkgs-unstable.dgop

      # Security
      pkgs-unstable._1password-gui

      # Media and utilities
      zoom-us
      x11docker
      pkgs-unstable.euphonica
      swaybg
      xwayland-satellite
      fuzzel
      swaylock
      swayidle
      pavucontrol
    ];

    # Environment variables for Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
