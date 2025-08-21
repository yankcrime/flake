{ config, pkgs, ... }:

{
  imports = [
    ../configs/neovim.nix
    ../configs/starship.nix
  ];

  home.sessionPath = [ "$HOME/bin" ];
  
  home.packages = with pkgs; [ 
    httpie 
    fzf 
    go 
    direnv
    nix-direnv
    tmux
    zsh
    zsh-vi-mode
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
    mkcert

    # Kubernetes tools
    kubectl
    kubernetes-helm
    krew
    kubie
    helm-docs
    # Python with OpenStack clients
    (python3.withPackages (ps: with ps; [
      python-openstackclient
      python-glanceclient
      python-keystoneclient
      python-ironicclient
      python-octaviaclient
    ]))
  ]; 

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = false;
      nix-direnv.enable = true;
    };

    tmux = {
      enable = true;
      plugins = with pkgs;
      [
          tmuxPlugins.extrakto
      ];
    extraConfig = builtins.readFile ../files/tmux/tmux.conf + ''

# Enable extrako
run-shell ${pkgs.tmuxPlugins.extrakto}/share/tmux-plugins/extrakto/extrakto.tmux
'';

    };

    zsh = {
      enable = true;
      plugins = [
        {
          name = "evalcache";
          src = pkgs.fetchFromGitHub {
            owner = "mroth";
            repo = "evalcache";
            rev = "master";
            sha256 = "0rs7095s70c7v465b4gzvxfflz3vwvm1ljzz250rgx3c096yq20q";
          };
        }
        {
          name = "zsh-z";
          src = "${pkgs.zsh-z}/share/zsh-z";
        }
      ];

      initContent = ''
# Load zsh-vi-mode plugin manually
source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

'' + builtins.readFile ../files/zsh/zshrc + ''

function zvm_after_init() {
    _evalcache fzf --zsh
}
      '';
    };
  };

  home.stateVersion = "25.05";
}
