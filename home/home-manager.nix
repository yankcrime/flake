{ config, pkgs, pkgs-unstable, ... }:

let
  commonPackages = import ../modules/common.nix { inherit config pkgs pkgs-unstable; };
in
{
  imports = [
    ../configs/neovim.nix
    ../configs/starship.nix
  ];

  home.sessionPath = [ "$HOME/bin" ];
  
  home.packages = commonPackages.home;

  # Ghostty
  xdg.configFile."ghostty/config".source = ../files/ghostty/config;
  xdg.configFile."ghostty/cursor_smear_fade.glsl".source = ../files/ghostty/cursor_smear_fade.glsl;

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          email = "nick@dischord.org";
          name = "Nick Jones";
        };
        signing = {
          key = "B264F01E309D20E4";
          signByDefault = true;
        };
        alias = {
          up = "!git remote update -p; git merge --ff-only @{u}";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit";
        };
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
          column = {
            ui = "auto";
          };
          branch = {
            sort = "-committerdate";
          };
          tag = {
            sort = "version:refname";
          };
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };
          merge = {
            conflictstyle = "zdiff3";
          };
          credential = {
            helper = "cache --timeout=7200";
          };
          gitreview = {
            username = "yankcrime";
          };
          github = {
            user = "yankcrime";
          };
          "url \"ssh://git@github.com/\"" = {
            insteadOf = [ "https://github.com/" "git://github.com/" ];
          };
          "filter \"lfs\"" = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
        };
      };
    };

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
      enableCompletion = false;
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
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = ''

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
