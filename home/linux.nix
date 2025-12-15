{ config, pkgs, pkgs-unstable, ... }:

let
  syncthingBin = "${pkgs.syncthing}/bin/syncthing";
in {
  imports = [
    ./home-manager.nix
  ];
  
  home.packages = with pkgs; [ 
    syncthing 
    mpdscribble
    claude-code
    incus
    teleport_18
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

  programs.swaylock = {
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
}
