{ config, pkgs, pkgs-unstable, ... }:

{
  # Shared packages used by both Linux and Darwin systems
  shared = with pkgs; [
    # Terminal tools
    vim
    wget
    curl
    btop
    zsh
    zsh-vi-mode
    git
    tree
    unzip
    rsync
    mosh
    fastfetch
    jq
    file
    doggo
    dig
    openssl
    ripgrep
    flac
    gh

    # Development tools
    gnumake
    mkcert

    # Kubernetes tools
    kubectl
    kubernetes-helm
    krew
    kubie
    kubectx
    helm-docs

    # System tools
    apg
    gnupg

    # Python with OpenStack clients
    (python3.withPackages (ps: with ps; [
      python-openstackclient
      python-glanceclient
      python-keystoneclient
      python-neutronclient
      python-ironicclient
      python-octaviaclient
      semver
    ]))
  ];

  # Shared home-manager packages
  home = with pkgs; [
    httpie 
    fzf 
    go 
    direnv
    nix-direnv
    tmux
  ];
}
