{ inputs, pkgs, pkgs-unstable, ... }:

{
  homebrew = {
    enable = true;
    casks  = [
      "1password"
      "alfred"
      "font-jetbrains-mono"
      "linear-linear"
      "notion"
      "gpg-suite-no-mail"
      "discord"
      "google-chrome"
      "imageoptim"
      "monodraw"
      "rectangle-pro"
      "slack"
    ];

    brews = [
      "gnupg"
      "syncthing"
    ];
  };

  # Nixpkgs configuration
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs-unstable; [
    claude-code
  ];

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
