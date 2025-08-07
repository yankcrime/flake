{ config, lib, pkgs, pkgs-unstable, ... }:

{
  # Boot configuration
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
    direnv.enable = true;
    gnupg.agent.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/nick/src/flake/";
    };
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

  # Common packages (non-GUI)
  environment.systemPackages = with pkgs; [
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
    gnumake

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
    _1password-cli

    # Media (terminal-based)
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


  # Environment
  environment.shells = with pkgs; [ zsh ];

  # Services
  services = {
    throttled.enable = true;
    fwupd.enable = true;
    openssh.enable = true;
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
