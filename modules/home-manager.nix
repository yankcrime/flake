{ config, pkgs, ... }:

let
  syncthingBin = "${pkgs.syncthing}/bin/syncthing";
in {
  imports = [
    ../configs/neovim.nix
    ../configs/starship.nix
  ];

  home.sessionPath = [ "$HOME/bin" ];
  
  home.packages = with pkgs; [ 
    atool 
    httpie 
    fzf 
    go 
    syncthing 
    mpdscribble
    direnv
    nix-direnv
    tmux
  ];

  services.mpd = {
    enable = true;
    musicDirectory = "/syn/audio/";
    extraConfig = ''
audio_output {
  type "pipewire"
  name "PipeWire"
}
audio_output {
       type            "fifo"
       name            "Visualizer feed"
       path            "/tmp/mpd.fifo"
       format          "44100:16:2"
}
  '';
    network.startWhenNeeded = true; 
  };

  services.mpdscribble = {
    enable = true;
    endpoints."last.fm".username = "yankcrime";
    endpoints."last.fm".passwordFile = "${config.home.homeDirectory}/.local/share/lastfm";
  };

  systemd.user.services.syncthing = {
    Unit = {
      Description = "Syncthing (User)";
      After = [ "network.target" ];
    };
  
    Service = {
      ExecStart = "${syncthingBin} serve --no-browser --logflags=0";
      Restart = "on-failure";
    };
  
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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

    swaylock = {
      enable = true;
      settings = {
        font = "Adwaita Sans";
        font-size = 40;
        color = "1e1e2e";
        indicator-radius = "400";
        bs-hl-color = "f5e0dc";
        caps-lock-bs-hl-color = "f5e0dc";
        caps-lock-key-hl-color = "a6e3a1";
        inside-color = "00000000";
        inside-clear-color = "00000000";
        inside-caps-lock-color = "00000000";
        inside-ver-color = "00000000";
        inside-wrong-color = "00000000";
        key-hl-color = "a6e3a1";
        layout-bg-color = "00000000";
        layout-border-color = "00000000";
        layout-text-color = "cdd6f4";
        line-color = "00000000";
        line-clear-color = "00000000";
        line-caps-lock-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        ring-color = "b4befe";
        ring-clear-color = "f5e0dc";
        ring-caps-lock-color = "fab387";
        ring-ver-color = "89b4fa";
        ring-wrong-color = "eba0ac";
        separator-color = "00000000";
        text-color = "cdd6f4";
        text-clear-color = "f5e0dc";
        text-caps-lock-color = "fab387";
        text-ver-color = "89b4fa";
        text-wrong-color = "eba0ac";
      };
    };
  };

  home.stateVersion = "25.05";
}
