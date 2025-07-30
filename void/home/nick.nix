{ config, pkgs, ... }:

let
  syncthingBin = "${pkgs.syncthing}/bin/syncthing";
in {
  home.sessionPath = [ "$HOME/bin" ];
  home.packages = [ pkgs.atool pkgs.httpie pkgs.fzf pkgs.go pkgs.syncthing ];
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

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
      lua-language-server
    ];
  
    plugins = with pkgs.vimPlugins; [
      vim-nix
      telescope-nvim
      plenary-nvim
      nvim-treesitter.withAllGrammars
      lualine-nvim
			github-nvim-theme
      gruvbox-nvim
      vim-dirvish
      blink-cmp
			friendly-snippets
			telescope-fzf-native-nvim
			telescope-ui-select-nvim
    ];

    extraLuaConfig = ''
local actions = require("telescope.actions")
require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  },
	defaults = {
	        prompt_prefix = "",
	        entry_prefix = " ",
	        selection_caret = " ",
	        layout_config = {
	          prompt_position = 'bottom',
	          width = 0.7,
	          height = 0.7,
	          preview_width = 0.6,
	        },
  mappings = {
    i = {
      ["<esc>"] = actions.close,
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous
		},
  },
},
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
local blink = require("blink.cmp")
blink.setup {
  keymap = { preset = "super-tab" },
  completion = {
    documentation = { auto_show = false },
    accept = {
      auto_brackets = {
        kind_resolution = {
          blocked_filetypes = { "typescriptreact", "javascriptreact" },
        },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
}
vim.g.mapleader = ' ' -- Space
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<C-f>', builtin.find_files, {})
vim.keymap.set('n', '<C-s>', builtin.live_grep, {})
vim.keymap.set('n', '<C-b>', builtin.buffers, {})
vim.keymap.set('n', '<C-g>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<C-y>', ':Telescope yaml_schema<CR>', {})
vim.keymap.set('n', '<leader>td', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>gg', builtin.live_grep, {})

vim.keymap.set('n', '<Leader><space>', ':nohlsearch<CR>')
vim.keymap.set('n', '<Leader>tn', ':tabnext<CR>')
vim.keymap.set('n', '<Leader>tp', ':tabprevious<CR>')
vim.cmd([[
    augroup custom_appearance
      autocmd!
      au ColorScheme * hi Normal gui=NONE guifg=NONE guibg=NONE ctermfg=none ctermbg=NONE
    augroup END
    function! s:statusline_expr()
        let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : '''}"
        let ro  = "%{&readonly ? '[RO] ' : '''}"
        let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : '''}"
        let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : '''}"
        let sep = ' %= '
        let pos = ' %-5(%l:%c%V%) '
        let pct = ' %P '

        return ' [%n] %.40F %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
      endfunction
      let &statusline = s:statusline_expr()
			colorscheme github_dark_default
]])
vim.opt.number = true
vim.opt.showmatch = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = ""
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.modelines = 5
vim.opt.signcolumn = "no"
vim.opt.statuscolumn = "%=%s%C%l "
vim.opt.laststatus=3
    '';
  };

  programs.starship = {
    enable = true;
  
    settings = {
      add_newline = false;
        format = "$hostname$directory$vcsh$git_branch$git_commit$git_state$git_metrics$git_status$kubernetes$docker_context$package$buf$c$cmake$container$golang$helm$java$lua$nodejs$perl$pulumi$purescript$python$rlang$ruby$rust$swift$terraform$vagrant$nix_shell$conda$memory_usage$gcloud$openstack$azure$env_var$custom$sudo$cmd_duration$fill$time$line_break$jobs$battery$status$shell$character";
        hostname = {
          ssh_only = true;
          style = "";
          ssh_symbol = "";
        };
    
        fill.symbol = " ";
    
        c.style = "";
    
        character = {
          success_symbol = "[%](default)";
          vicmd_symbol = "[%](default)";
          error_symbol = "[%](bold red)";
        };
    
        git_branch = {
          style = "fg:dark_grey";
          symbol = " ";
        };
    
        git_status.style = "fg:dark_grey";
        git_state.style = "fg:dark_grey";
    
        git_metrics.added_style = "fg:dark_grey";
    
        directory = {
          style = "fg:dark_grey";
          truncation_symbol = "../";
        };
    
        jobs = {
          symbol = "·";
          style = "bold red";
        };
    
        time = {
          disabled = false;
          style = "";
          format = "[$time]($style) ";
        };
    
        terraform.disabled = true;
        package.disabled = true;
        java.disabled = true;
        helm.disabled = true;
        golang = {
          disabled = true;
          style = "";
          format = "via [󰟓 ($version )]($style)";
        };
    
        kubernetes = {
          style = "";
          format = "[󱃾 ($cluster in) \\($namespace\\)]($style) ";
          disabled = false;
          detect_env_vars = [ "KUBECONFIG" ];
        };
    
        python = {
          disabled = false;
          format = "via [ ($version )]($style)(($virtualenv))";
          style = "fg:dark_grey";
          detect_extensions = [ ];
          detect_files = [
            ".python-version"
            "Pipfile"
            "__init__.py"
            "pyproject.toml"
            "requirements.txt"
            "setup.py"
            "tox.ini"
          ];
        };
    
        openstack = {
          style = "";
          format = "on [$cloud]($style) ";
        };
    
        docker_context = {
          disabled = true;
          style = "";
        };
    
        lua.disabled = true;
        nodejs.disabled = true;
        aws.disabled = true;
        gcloud.disabled = true;
      };
    };

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
    "org/gnome/desktop/interface" = {
      enable-animations = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };
    "org/gnome/desktop/interface" = {
      cursor-size = 32;  # Default is 24
    };
    "org/gnome/desktop/wm/keybindings" = {
      show-desktop = [ "<Super>d" ];
    };
    "org/gnome/shell/keybindings" = {
      toggle-message-tray = [];  # Disables Super+V
    };
  };

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

# vim: set filetype=nix tabstop=2 shiftwidth=2 expandtab:

