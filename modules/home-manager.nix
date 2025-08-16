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
    tmux = {
      enable = true;
      plugins = with pkgs;
      [
          tmuxPlugins.extrakto
      ];
    extraConfig = ''
unbind C-b
set -g prefix C-a
bind-key C-a send-prefix

set-option -sa terminal-overrides ",xterm-ghostty:RGB"

# Undercurl, taken from: https://github.com/folke/lsp-colors.nvim
set -g default-terminal "''${TERM}"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

# start window numbers at 1 to match keyboard order with tmux window order
set -g base-index 1
set-window-option -g pane-base-index 1

# renumber windows sequentially after closing any of them
set -g renumber-windows on

# Faster escape sequences (default is 500ms).
set -s escape-time 50

# Bigger scrollback buffer
set -g history-limit 100000

# Quickly switch to last window
bind ^space last-window

# Select next tab
bind-key Tab select-pane -t :.+

# For Neovim
set-option -g focus-events on

# Working with splits
bind-key j select-pane -D 
bind-key k select-pane -U 
bind-key h select-pane -L 
bind-key l select-pane -R

# Equally resize all panes
bind-key = select-layout even-horizontal
bind-key | select-layout even-vertical

bind | split-window -h
bind - split-window -v

# Quickly search back to occurrences of my prompt character ('%')
bind-key b copy-mode\; send-keys -X start-of-line\; send-keys -X search-backward "%"\; send-keys -X next-word

bind-key -T copy-mode-vi / command-prompt -i -p "search down" "send -X search-forward-incremental \"%%%\""
bind-key -T copy-mode-vi ? command-prompt -i -p "search up" "send -X search-backward-incremental \"%%%\""

# Rebind 'clear screen' to <prefix>+c-l
bind C-l send-keys 'C-l'

# Rebind spit and new-window commands to use current path
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Use fzf to search for a pane
bind-key space run "tmux split-window -l 12 'zsh -ci ftpane'"

# Style status bar
set -g status-style fg=white,bg=black
set -g window-status-current-style fg=green,bg=black
set -g pane-active-border-style fg=green,bg=black
set -g window-status-format " #I:#W#F "
set -g window-status-current-format " #I:#W#F "
set -g window-status-current-style bg=green,fg=black
set -g window-status-activity-style bg=black,fg=yellow
set -g window-status-separator ""
set -g status-justify centre
set -g status-left '#[fg=white]§ #S'
set -g status-right "#[fg=white]$USER@#h"

# Window renaming
set-option -g allow-rename off
bind , command-prompt "rename-window '%%'"
bind > run-shell "tmux rename-window `basename #{pane_current_path}`"

# Use vim keybindings in copy mode
setw -g mode-keys vi
# Setup 'v' to begin selection as in Vim
bind-key -T copy-mode-vi v send -X begin-selection
# Setup 'y' to copy selection as in Vim
# Use reattach-to-user-namespace with pbcopy on OS X
set -g set-clipboard off
if-shell 'test "$(uname -s)" = Darwin' 'bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy 2> /dev/null"' 'bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel wl-copy'

# Fix for ssh-agent (http://fredkelly.net/articles/2014/10/19/developing_on_yosemite.html)
set -g update-environment "SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_C"

# Mousemode
# Toggle mouse on with ^A m
bind m \
  set -g mouse on \;\
  display 'Mouse Mode: ON'

# Toggle mouse off with ^A M
bind M \
  set -g mouse off \;\
  display 'Mouse Mode: OFF'

# Move current window to the left with Ctrl-Shift-Left
bind-key -n C-S-Left swap-window -t -1
# Move current window to the right with Ctrl-Shift-Right
bind-key -n C-S-Right swap-window -t +1

# Open a scratch split-window at the bottom
bind t split-window -f -l 15 -c "#{pane_current_path}"

#set -g window-style 'fg=colour242,bg=colour233'
##set -g window-active-style 'fg=#8b949e,bg=color233'
#set -g window-active-style 'fg=colour252,bg=color233'

# Search directly from "normal" mode
bind / {
    copy-mode
    command-prompt -i -p "(search up)" { send -X search-backward-incremental '%%%' }
}

# Quickly search back to occurrences of my prompt character ('%')
bind-key b copy-mode\; send-keys -X start-of-line\; send-keys -X search-backward "%"\; send-keys -X next-word

bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Enable extrako
run-shell ${pkgs.tmuxPlugins.extrakto}/share/tmux-plugins/extrakto/extrakto.tmux
'';

    };

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
export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

#zmodload zsh/zprof
# vim:ts=4:sw=4:ft=zsh:et
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
