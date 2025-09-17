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
      "alfred"
      "font-jetbrains-mono"
      "linear-linear"
      "notion"
      "gpg-suite-no-mail"
      "discord"
      "google-chrome"
      "firefox"
      "imageoptim"
      "monodraw"
      "rectangle-pro"
      "slack"
      "leader-key"
      "zoom"
      "claude-code"
      "docker"
      "signal"
      "ghostty"
      "chatgpt"
    ];

    brews = [
      "gnupg"
      "syncthing"
      "colima"
      "codex"
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
      tilesize = 48;
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
