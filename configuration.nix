{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
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
    firefoxWrapper
    chromium
    vagrant
    rox-filer
    emacs
    pwgen
    pulseaudioFull
    ncmpcpp
    lightdm
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
     enableGoogleTalkPlugin = true;
     enableAdobeFlash = true;
    };

    chromium = {
     enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
     enablePepperPDF = true;
    };


  };

  programs.zsh.enable = true;

  # Define a user account.
  users.extraUsers.nick = {
    isNormalUser = true;
    uid = 1000;
    description = "Nick Jones";
    extraGroups = ["wheel" "audio" "docker" "kvm" "libvirtd"];
    shell = pkgs.zsh;
  };

  # Audio
  hardware.pulseaudio.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # sudo
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Emacs
  # services.emacs.enable = true;

  # Virtualisation
  virtualisation.libvirtd = {
    enable = true;
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

  networking = {
     hostName = "zaphod";
     firewall.enable = false;
     extraHosts = "192.168.1.251 syn.int.dischord.org syn";
  };

  services.xserver.displayManager.lightdm = {
    enable = true;
  }

  system.stateVersion = "19.09";

}
