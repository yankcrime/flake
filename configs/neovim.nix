{ config, pkgs, ... }:

{
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
}