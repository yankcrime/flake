# NixOS configuration for a ThinkPad X230

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.extraEntries = ''
    menuentry "Windows 10" {
     chainloader (hd0,1)+1
   }
   '';

  networking = {
     hostName = "bluetip";
     firewall.enable = false;
     wireless.enable = true;
     nameservers = [ "1.1.1.1" "1.0.0.1" ];
     extraHosts = "192.168.0.249 micro.int.dischord.org micro\n192.168.0.251 syn.int.dischord.org syn";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    zsh
    wget
    vim
    fzf
    gitAndTools.gitFull
    tmux
    htop
    unzip
    gtk_engines
    hicolor_icon_theme
    lxappearance
    mosh
    pamixer
    paprefs
    pavucontrol
    powertop
    rxvt_unicode
    slack
    gnome3.adwaita-icon-theme
    xdg-user-dirs
    xdg_utils
    xclip
    xlibs.mkfontdir
    xlibs.xcursorthemes
    xlibs.xev
    xlibs.xprop
    xorg.xmodmap
    xcape
    firefoxWrapper
    chromium
    vagrant
    rox-filer
    emacs
    pwgen
    pulseaudioFull
    ncmpcpp
    neovim
    gnumake
    gcc
    glibc
    pkgconfig
    kitty
  ];

  fonts.fonts = with pkgs; [
    source-code-pro dejavu_fonts liberation_ttf vistafonts corefonts
    cantarell_fonts fira fira-mono fira-code
  ];

  fonts.fontconfig = {
    ultimate = {
      enable = true;
    };
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  sound.enable = true;
  sound.mediaKeys = {
    enable = true;
    volumeStep = "5%";
  };

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.windowManager.i3.enable = true;

  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
    trackpoint.enable = true;
    trackpoint.emulateWheel = true;
    opengl.enable = true;
    opengl.extraPackages = [ pkgs.vaapiIntel ];
  };

  virtualisation.docker.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
     enableAdobeFlash = true;
     enableAdobeReader = true;
     enableGoogleTalkPlugin = true;
     enableOfficialBranding = true;
     supportsJDK = true;
    };

    chromium = {
     enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
     enablePepperPDF = true;
    };


  };

  programs.zsh.enable = true;

  systemd.services.power-tune = {
    description = "Power Management tunings";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.powertop}/bin/powertop --auto-tune
      ${pkgs.iw}/bin/iw dev wlp3s0 set power_save on
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo powersave > $cpu
      done
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.user.services."xcape" = {
    enable = true;
    description = "xcape to act ctrl as escape when pressed alone";
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "forking";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.xcape}/bin/xcape";
  };

  systemd.user.services."urxvtd" = {
    enable = true;
    description = "rxvt unicode daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rxvt_unicode ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.rxvt_unicode}/bin/urxvtd -q -o";
  };

  users.extraUsers.nick = {
    isNormalUser = true;
    uid = 1000;
    description = "Nick Jones";
    extraGroups = ["wheel" "audio" "docker"];
    shell = pkgs.zsh;
  };

  system.stateVersion = "18.03";

}
