return {
  -- themes
  "folke/tokyonight.nvim",
  { "dracula/vim", name = "dracula", lazy = false, priority = 1000 },
  "morhetz/gruvbox",
  "rakr/vim-one",

  -- UI / editing
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {},
  },
  "christoomey/vim-tmux-navigator",
  "farmergreg/vim-lastplace",

  -- which-key: popup lists keybindings after any prefix press (<leader>,
  -- g, z...) so chords are self-documenting. <leader>? shows buffer maps.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end,
        desc = "which-key: buffer keymaps" },
    },
  },

  -- gitsigns: git gutter + per-hunk stage/preview/diff.
  -- All actions: :Gitsigns <Tab>. Only one user keymap bound.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    config = function(_, opts)
      require("gitsigns").setup(opts)
      local ok, wk = pcall(require, "which-key")
      if ok then wk.add({ { "<leader>g", group = "git" } }) end
    end,
    keys = {
      { "<leader>gd", ":Gitsigns diffthis<CR>", mode = "n", silent = true,
        desc = "gitsigns: diff buffer vs HEAD (split)" },
      { "<leader>gb", ":Gitsigns blame<CR>", mode = "n", silent = true,
        desc = "gitsigns: blame (full window)" },
    },
  },

  -- Treesitter: parser-driven highlighting, indent, folds. Local library;
  -- no server. Each language parser compiled on first use (needs cc).
  --
  -- Pinned to `master`: upstream was archived 2026-04-03. `main` is an
  -- incompatible rewrite requiring Nvim 0.12; master is frozen but works
  -- on 0.11 and will receive no more fixes.
  --
  -- auto_install works only for parsers that ship a pre-generated
  -- src/parser.c (cc compiles directly). Parsers flagged
  -- `requires_generate_from_grammar` in parsers.lua need the `tree-sitter`
  -- CLI to regenerate parser.c, and master's install.lua passes the
  -- `--no-bindings` flag that was removed in CLI 0.25+. Master is archived
  -- so this will never be fixed upstream. We derive the skip list from
  -- parsers.lua itself; those filetypes fall back to Neovim's built-in
  -- regex syntax.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = function()
      local ignore = {}
      for lang, cfg in pairs(require("nvim-treesitter.parsers").get_parser_configs()) do
        if cfg.install_info and cfg.install_info.requires_generate_from_grammar then
          table.insert(ignore, lang)
        end
      end
      return {
        auto_install = true,
        ignore_install = ignore,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- fzf.vim: fuzzy pickers (Files, History, Rg, GFiles, Buffers...).
  -- Needs `fzf` binary on PATH; junegunn/fzf supplies the vim helpers.
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    cmd = { "Files", "GFiles", "Buffers", "History", "Rg", "RG", "Lines", "BLines", "Commits", "Marks" },
    keys = {
      { "<C-p>", ":History:<CR>", mode = "n", silent = true, desc = "fzf: command history" },
      { "<C-t>", ":Files<CR>",    mode = "n", silent = true, desc = "fzf: find files" },
    },
    init = function()
      vim.g.fzf_layout = { window = { width = 0.8, height = 0.8 } }
      vim.g.fzf_preview_window = { "up:80%" }
      vim.env.FZF_DEFAULT_OPTS = "--layout=default"
    end,
  },

  -- file tree (replaces NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen", "NvimTreeClose", "NvimTreeFocus" },
    -- Eager-load when nvim is invoked with a directory arg or no arg,
    -- so the tree opens up front. `nvim file.txt` stays lazy.
    init = function()
      local no_arg = vim.fn.argc() == 0
      local arg = vim.fn.argv(0)
      local dir_arg = arg ~= "" and vim.fn.isdirectory(arg) == 1
      if no_arg or dir_arg then
        require("lazy").load({ plugins = { "nvim-tree.lua" } })
      end
      if no_arg then
        vim.api.nvim_create_autocmd("VimEnter", {
          once = true,
          callback = function() require("nvim-tree.api").tree.open() end,
        })
      end
    end,
    opts = {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = true },
      filesystem_watchers = { enable = true },
      filters = { dotfiles = false },
      actions = { change_dir = { enable = true, global = false } },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "t", api.node.open.tab,
          { buffer = bufnr, silent = true, nowait = true, desc = "nvim-tree: open in new tab" })
      end,
    },
  },

  "tpope/vim-rsi",

  -- nvim-surround: lua-native replacement for tpope/vim-surround.
  -- ys/cs/ds semantics; drop-in.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

}
