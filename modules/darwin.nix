{ inputs, pkgs, pkgs-unstable, config, ... }:

let
  commonPackages = import ./common.nix { inherit config pkgs pkgs-unstable; };
in
{
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "uninstall";
    };
    casks  = [
      "1password"
      "antinote"
      "alfred"
      "conductor"
      "font-jetbrains-mono"
      "linear-linear"
      "notion"
      "gpg-suite-no-mail"
      "discord"
      "google-chrome"
      "firefox"
      "imageoptim"
      "monodraw"
      "rectangle"
      "slack"
      "zoom"
      "claude-code"
      "docker-desktop"
      "mimestream"
      "signal"
      "obsidian"
      "chatgpt"
      "visual-studio-code"
      "netnewswire"
      "zed"
      "tailscale-app"
      "codex"
    ];

    brews = [
      "awscli"
      "gnupg"
      "clusterctl"
      "syncthing"
      "colima"
      "hl"
      "incus"
      "make"
      "vcluster"
      "lame"
      "terraform"
      "teleport"
      "k9s"
      "docker-buildx"
      "incus"
      "ipcalc"
      "k3sup"
      "yq"
      "tmate"
      "viddy"
    ];
  };

  # Nixpkgs configuration
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = commonPackages.shared ++ (with pkgs;
  [
    nh
  ]);

  users.users.nick = {
    home = "/Users/nick";
    shell = pkgs.zsh;
  };

  # System settings
  system.stateVersion = 5;
  
  # Set primary user for system-wide configuration
  system.primaryUser = "nick";
  
  # Disable nix-darwin's Nix management (using Determinate installer)
  nix.enable = false;

  # System preferences
  system.defaults = {
    dock = {
      autohide = false;
      show-recents = true;
      launchanim = true;
      mouse-over-hilite-stack = true;
      orientation = "bottom";
      tilesize = 42;
    };
    
    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };
    
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSWindowShouldDragOnGesture = true;
    };
  };
}
