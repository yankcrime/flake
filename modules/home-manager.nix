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
    zsh = {
      enable = true;
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
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
export EDITOR="nvim"
export GPG_TTY=$(tty)
export BAT_THEME="ansi"
export FZF_DEFAULT_OPTS="--color=bw"
export KEYTIMEOUT=1

# history and general options
#
HISTSIZE=10000000
SAVEHIST=10000000
TMOUT=0
HISTFILE=~/.history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt nohup
umask 022

autoload -Uz +X compaudit compinit
autoload -Uz +X bashcompinit

# only bother with rebuilding, auditing, and compiling the compinit
# file once a whole day has passed. The -C flag bypasses both the
# check for rebuilding the dump file and the usual call to compaudit.
# via @emilyst
#
setopt EXTENDEDGLOB
for dump in $HOME/.zcompdump(N.mh+24); do
  echo 'Re-initializing ZSH completions'
  touch $dump
  compinit
  bashcompinit
  if [[ -s "$dump" && (! -s "$dump.zwc" || "$dump" -nt "$dump.zwc") ]]; then
    zcompile "$dump"
  fi
done
unsetopt EXTENDEDGLOB
compinit -C

# other stuff that makes zsh worthwhile
#
autoload -U promptinit && promptinit
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
local knownhosts
zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts

# some other {sensible,useful} shortcuts
#
alias publicip='curl http://icanhazip.com'
alias ls='ls -F'
alias view='vim -R'
alias sshx='ssh -c arcfour,blowfish-cbc -XC'
alias uuidgen="uuidgen | tr 'A-Z' 'a-z'"
alias docekr='docker'
alias vim='nvim'
alias k='kubectl'

# prompt and window title
#
setopt print_exit_value
setopt PROMPT_SUBST

export KEYTIMEOUT=1

bindkey '^[[Z' reverse-menu-complete # make shift-tab work in reverse

# Allow use of Ctrl-S in vim
#
stty -ixon

# zsh-vi-mode stuff
# Always start in insert mode
#
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

function zvm_after_init() {
    [ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    [ -f ${pkgs.fzf}/share/fzf/completion.zsh ] && source ${pkgs.fzf}/share/fzf/completion.zsh
}

export PATH="''${PATH}:''${HOME}/.krew/bin:''${HOME}/go/bin:''${HOME}/bin"

#zmodload zsh/zprof
# vim:ts=4:sw=4:ft=zsh:et
      '';
    };
  };

  home.stateVersion = "25.05";
}
