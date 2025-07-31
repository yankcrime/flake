{ config, lib, pkgs, pkgs-unstable, ... }:

{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Locale and time
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # User configuration
  users.users.nick = {
    isNormalUser = true;
    description = "Nick Jones";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcfkOqEi+AeoSeJcij7ltWV/1n4A5opWh6PQDyo/6vI nick@deadline.local" 
    ];
    shell = pkgs.zsh;
  };

  # Programs
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
  };

  # Security
  security.sudo.extraRules = [   
    {   
      users = ["nick"];   
      commands = [   
        {   
          command = "ALL";   
          options = ["NOPASSWD"];   
        }   
      ];   
    }   
  ];

  # Nixpkgs configuration
  nixpkgs.config.allowUnfree = true;

  # Common packages
  environment.systemPackages = with pkgs; [
    # Fonts
    corefonts
    inter
    roboto-mono
    jetbrains-mono
    noto-fonts-emoji

    # Terminal tools
    vim
    neovim
    wget
    curl
    viddy
    btop
    zsh
    git
    tree
    tmux
    unzip
    rsync
    mosh
    fastfetch
    jq

    # Development tools
    qemu

    # Kubernetes tools
    kubectl
    kubernetes-helm
    krew
    kubie

    # System tools
    gnupg
    powertop
    imwheel
    nfs-utils
    throttled
    wl-clipboard
    libnotify

    # GUI applications
    ghostty
    firefox
    google-chrome
    slack
    discord
    newsflash
    obsidian
    signal-desktop
    syncthing
    gnome-tweaks
    _1password-gui
    _1password-cli
    resources
    eog
    code-cursor
    vscode

    # Media
    ncmpcpp

    # Python with OpenStack clients
    (python3.withPackages (ps: with ps; [
      python-openstackclient
      python-glanceclient
      python-keystoneclient
      python-ironicclient
    ]))
  ] ++ (with pkgs-unstable; [
    claude-code
  ]);

  # Font configuration
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

  # Environment
  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Services
  services = {
    throttled.enable = true;
    fwupd.enable = true;
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    openssh.enable = true;
    qemuGuest.enable = true;
    mpd.user = "nick";
  };

  # Networking
  networking.networkmanager.enable = true;

  # Nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];   
  nix.optimise.automatic = true;

  # Virtualization
  virtualisation.docker.enable = true;

  # Power management
  powerManagement.powertop.enable = true;

  # Swap
  swapDevices = [
    {
      device = "/.swap";
      size = 4096;
    }
  ];

  system.stateVersion = "25.05";
}