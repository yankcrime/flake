{ config, pkgs, ... }:

{
  programs.zsh = {
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

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats 'on %b '
zstyle ':vcs_info:*' enable git

# make it work like vim
#
bindkey -v
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-pattern-search-backward
export KEYTIMEOUT=1

bindkey '^[[Z' reverse-menu-complete # make shift-tab work in reverse

# change cursor shape based on which vi mode we're in
# via https://emily.st/2013/05/03/zsh-vi-cursor/
#
function zle-keymap-select zle-line-init
{
    case $KEYMAP in
        vicmd)      print -n -- "\e[1 q";;  # block cursor
        viins|main) print -n -- "\e[5 q";;  # line cursor
    esac

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    print -n -- "\e[1 q"  # block cursor
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Allow use of Ctrl-S in vim
#
stty -ixon

[ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
[ -f ${pkgs.fzf}/share/fzf/completion.zsh ] && source ${pkgs.fzf}/share/fzf/completion.zsh

export PATH="''${PATH}:''${HOME}/.krew/bin"

#zmodload zsh/zprof
# vim:ts=4:sw=4:ft=zsh:et
    '';
  };
}