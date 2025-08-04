{ config, pkgs, ... }:

let
  syncthingBin = "${pkgs.syncthing}/bin/syncthing";
in {
  imports = [
    ../configs/zsh.nix
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

  home.stateVersion = "25.05";
}
