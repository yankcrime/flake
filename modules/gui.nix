{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

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

      # Ghostty
      xdg.configFile."ghostty/config".source = ../files/ghostty/config;
      xdg.configFile."ghostty/cursor_smear_fade.glsl".source = ../files/ghostty/cursor_smear_fade.glsl;

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

      services.swayidle = {
        enable = true;
        systemdTarget = "graphical-session.target";
        timeouts = [
          {
            timeout = 600;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 601;
            command = "${pkgs-unstable.niri}/bin/niri msg action power-off-monitors";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
      };

      services.mako = {
        enable = true;
        settings = {
          group-by = "app-name,summary";
          font = "Adwaita Sans 14";
          layer = "top";
          default-timeout = 5000;
          ignore-timeout = 0;
          max-visible = 5;
          anchor = "bottom-right";
          outer-margin = 12;
          margin = 8;
          padding = 16;
          width = 460;
          height = 180;
          border-size = 1;
          border-radius = 18;
          icon-location = "left";
          icons = 1;
          max-icon-size = 48;
          icon-border-radius = 12;
          format = "<b>%s</b>\\n%b";
          background-color = "#242424E6";
          text-color = "#FFFFFFFF";
          border-color = "#FFFFFF1A";
          "urgency=critical" = {
            border-color = "#2B1A1AE6";
            background-color = "#242424E6";
          };
          "mode=do-not-disturb"= {
            invisible = 1;
          };
        };
      };
      programs = {
        waybar = {
          enable = true;
          style = builtins.readFile ../files/waybar/style.css;
          settings = [{
            layer = "top";
            position = "top";
            spacing = 0;
            height = 35;
            modules-left = [
              "custom/nixos-logo"
              "niri/workspaces"
              "niri/window"
            ];
            modules-center = [
              "clock" 
              "custom/weather"
            ];
            modules-right = [
              "tray"
              "network"
              "pulseaudio"
              "battery"
            ];
            tray = {
              icon-size = 20;
              tooltip = false;
              spacing = 10;
            };
            clock = {
              format = "{:%a %d %h %H:%M}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "year";
                mode-mon-col = 3;
                weeks-pos = "right";
                on-scroll = 1;
                format = {
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  days = "<span color='#ecc6d9'><b>{}</b></span>";
                  weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                  weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                  today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                };
              };
            };
            "cffi/niri-taskbar" = {
              module_path = "/home/nick/Sync/Configs/Misc/libniri_taskbar.so";
              notifications = {
                enabled = true;
              };
              apps = {
                slack = [
                  { match = "\\([0-9]+\\)$"; class = "unread"; }
                ];
              };
              workspace_grouping = {
                enabled = true;
                show_separators = true;
              };
            };
            "niri/workspaces" = {
              format = "{icon}";
              format-icons = {
                "web" = "";
                "messaging" = "";
                "dev" = "";
              };
            };
            "niri/window" = {
              format = "{title}";
            };
            "wlr/taskbar" = {
              on-click = "activate";
              on-click-middle = "close";
              on-click-right = "fullscreen";
              icon-size = 20;
            };
            "custom/weather" = {
              format = "{}";
              tooltip = true;
              interval = 3600;
              exec = ''
                wttrbar --location Edinburgh --custom-indicator "{ICON} {FeelsLikeC}° ({areaName})"
              '';
              return-type = "json";
            };
            network = {
              format-wifi = " ";
              format-ethernet = "  {ifname}";
              format-disconnected = " ";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
              tooltip-format-wifi = "{essid} ({signalStrength}%)  ";
            };
            battery = {
              format = "{icon} {capacity}%";
              format-charging = "  {capacity}%";
              format-plugged = "  {capacity}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
            };
            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = " ";
              format-source = " {volume}%";
              format-source-muted = " ";
              format-icons = {
                headphone = " ";
                headset = " ";
                default = " ";
              };
            };
            "custom/nixos-logo" = {
              format = " ";
              tooltip = false;
            };
            "custom/mako" = {
              format = "{icon}";
              format-icons = {
                default = " ";
              };
              exec = "~/bin/mako-dnd.sh";
              interval = 0;
              return-type = "json";
              on-click = "~/bin/mako-dnd.sh";
            };

          }];
        };
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
      noto-fonts-emoji
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
      papers
      apostrophe

      # Security
      pkgs-unstable._1password-gui

      # Media and utilities
      zoom-us
      x11docker
      pkgs-unstable.euphonica
      swaybg
      xwayland-satellite
      fuzzel
      waybar
      swaylock
      swayidle
      mako
      pavucontrol
      wttrbar
      pkgs-unstable.niriswitcher
    ];

    # Environment variables for Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
