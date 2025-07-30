{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Limit the number of entries
  boot.loader.systemd-boot.configurationLimit = 5;

  # LUKS encryption
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/b388968a-5e47-4c19-b3a0-b6c5608be206";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "void";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users.nick = {
    isNormalUser = true;
    description = "Nick Jones";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcfkOqEi+AeoSeJcij7ltWV/1n4A5opWh6PQDyo/6vI nick@deadline.local" ];
    shell = pkgs.zsh;
  };

  home-manager.users.nick = import ./home/nick.nix;

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
  };

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

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: with pkgs; {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    corefonts
    inter
    roboto-mono
    jetbrains-mono
    noto-fonts-emoji
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
    qemu
    kubectl
    kubernetes-helm
    krew
    stern
    kubectl-node-shell
    kubectl-view-allocations
    kubectl-cnpg
    kubectl-tree
    unstable.vcluster
    rsync
    mosh
    ghostty
    gnupg
    firefox
    google-chrome
    slack
    kubie
    discord
    newsflash
    obsidian
    signal-desktop
    syncthing
    gnome-tweaks
    fastfetch
    throttled
    powertop
    imwheel
    nfs-utils
    _1password-gui
    _1password-cli
    wl-clipboard
    ncmpcpp
    resources
    unstable.claude-code
    code-cursor
    vscode
    libnotify
    eog
    jq
    (python3.withPackages (ps: with ps; [
	python-openstackclient
        python-glanceclient
        python-keystoneclient
        python-ironicclient
    ]))
  ];

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

  environment.shells = with pkgs; [ zsh ];

  services.throttled.enable = true;

  services.fwupd.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  services.mpd.user = "nick";

  nix.settings.experimental-features = ["nix-command" "flakes"];   
  nix.optimise.automatic = true;

  virtualisation.docker.enable = true;

  powerManagement.powertop.enable = true;

  swapDevices = [
    {
      device = "/.swap";
      size = 4096;
    }
  ];

  system.stateVersion = "25.05";
}

# vim: set filetype=nix tabstop=2 shiftwidth=2 expandtab:

