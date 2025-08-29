{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
      lua-language-server
      gopls
      pyright
      yaml-language-server
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
      trouble-nvim
      nvim-lspconfig
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

-- LSP Configuration
local lspconfig = require('lspconfig')

-- Common LSP keybindings
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Configure LSP servers
lspconfig.gopls.setup{
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

lspconfig.pyright.setup{
  on_attach = on_attach,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true
      }
    }
  }
}

lspconfig.yamlls.setup{
  on_attach = on_attach,
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*/action.yml",
        ["https://json.schemastore.org/ansible-stable-2.9.json"] = "/roles/tasks/*.{yml,yaml}",
        ["https://json.schemastore.org/prettierrc.json"] = "/.prettierrc.{yml,yaml}",
        ["https://json.schemastore.org/kustomization.json"] = "/kustomization.{yml,yaml}",
        ["https://json.schemastore.org/chart.json"] = "/Chart.{yml,yaml}",
        ["https://json.schemastore.org/circleciconfig.json"] = "/.circleci/**/*.{yml,yaml}",
      },
    },
  },
}
local blink = require("blink.cmp")
blink.setup {
  keymap = { preset = "super-tab" },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    accept = {
      auto_brackets = {
        enabled = true,
        kind_resolution = {
          blocked_filetypes = { "typescriptreact", "javascriptreact" },
        },
      },
    },
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        name = "LSP",
        module = "blink.cmp.sources.lsp",
        enabled = true,
        score_offset = 90,
      },
      path = {
        name = "Path",
        module = "blink.cmp.sources.path",
        score_offset = 3,
        opts = {
          trailing_slash = false,
          label_trailing_slash = true,
          get_cwd = function(context) return vim.fn.expand(("#%d:p:h"):format(context.bufnr)) end,
          show_hidden_files_by_default = false,
        }
      },
      snippets = {
        name = "Snippets",
        module = "blink.cmp.sources.snippets",
        score_offset = 85,
      },
      buffer = {
        name = "Buffer",
        module = "blink.cmp.sources.buffer",
        score_offset = 5,
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
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
      au ColorScheme * hi Statusline guifg=NONE guibg=#000000 gui=bold
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
