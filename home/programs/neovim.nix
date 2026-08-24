{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets $EDITOR/$VISUAL
    viAlias = true;
    vimAlias = true;

    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = snacks-nvim;
        type = "lua";
        config = ''
          require("snacks").setup({
            picker = { enabled = true },
            notifier = { enabled = true},
            input = { enabled = true }
          })

          vim.keymap.set("n", "<leader>f", function() Snacks.picker.files() end, {desc = "Find Files"})
          vim.keymap.set("n", "<leader>s", function() Snacks.picker.grep() end, {desc = "Search Text"})
          vim.keymap.set("n", "<leader>b", function() Snacks.picker.buffers() end, {desc = "Buffers"})
          vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, {desc = "Goto Definition"})
        '';
      }
      {
        plugin = oil-nvim;
        type = "lua";
        config = ''
          require("oil").setup({
            view_options = { show_hidden = true },
          })

          vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File Browser" })
        '';
      }
      {
        plugin = neogit;
        type = "lua";
        config = ''
          require("neogit").setup({ })

          vim.keymap.set("n", "<leader>g", function() require("neogit").open() end, { desc = "Neogit" })
        '';
      }
      plenary-nvim  # for neogit
      diffview-nvim # for neogit
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup({
            current_line_blame = true
          })
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require("which-key").setup({})
        '';
      }
    ];

    initLua = ''
      local o = vim.opt
      vim.g.mapleader = ' '
      o.number = true
      o.relativenumber = true

      o.expandtab = true
      o.tabstop = 2
      o.shiftwidth = 2
      o.softtabstop = 2
      o.ignorecase = true
      o.smartcase = true      -- case-sensitive if capital is present
      o.scrolloff = 16        -- keep cursor away from screen edges
      o.undofile = true       -- persistant undo across sessions

      vim.cmd("syntax on")
      vim.cmd("filetype plugin indent on")

      vim.cmd("colorscheme habamax")

      -- Keybinds
      -- save by Esc
      vim.keymap.set('n', '<Esc>', ':w<CR>', { desc = Save })
      -- select all
      vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
      -- don't clobber buffer on selection paste
      vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
    '';
  };
}
