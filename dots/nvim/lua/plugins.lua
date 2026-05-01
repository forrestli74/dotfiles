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
    lazy = false,
    -- Auto-open the tree when nvim starts with no args.
    init = function()
      if vim.fn.argc() == 0 then
        vim.api.nvim_create_autocmd("VimEnter", {
          once = true,
          callback = function() require("nvim-tree.api").tree.open() end,
        })
      end
    end,
    opts = {
      hijack_cursor = true,
      hijack_directories = { enable = true, auto_open = true },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = true },
      filesystem_watchers = { enable = true },
      filters = { dotfiles = false, git_ignored = false },
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

  -- rainbow-delimiters: colorize nested brackets via treesitter.
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },

  -- render-markdown.nvim: in-buffer rendering of headings, code fences,
  -- tables, checkboxes, etc. Uses core treesitter (nvim 0.12+); the
  -- markdown/markdown_inline parsers auto-install via tree-sitter-manager.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- Disable heading icons in the sign column; keep gitsigns gutter clean.
      sign = { enabled = false },
      -- Strip source-level cell padding so wide tables fit more often.
      pipe_table = { cell = "trimmed" },
    },
  },

  -- markdown-preview.nvim (selimacerbas rewrite): browser preview with
  -- live Mermaid/KaTeX rendering. Pure-Lua HTTP server (no Node), SSE
  -- transport. Use this when render-markdown.nvim isn't enough — i.e.
  -- you actually want diagrams rendered, not just styled code blocks.
  {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewRefresh" },
    ft = { "markdown" },
    -- One-time hint per nvim session: lazy.nvim's `init` runs at startup,
    -- so the autocmd is registered before the plugin loads. The plugin
    -- itself stays lazy (only loads when the user runs :MarkdownPreview).
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.md",
        once = true,
        callback = function()
          vim.notify("markdown: <leader>mp to preview in browser, <leader>w to toggle wrap", vim.log.levels.INFO)
        end,
      })
    end,
    config = function()
      require("markdown_preview").setup({})
      local ok, wk = pcall(require, "which-key")
      if ok then wk.add({ { "<leader>m", group = "markdown" } }) end
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", mode = "n", silent = true,
        desc = "markdown-preview: open in browser" },
      { "<leader>mr", "<cmd>MarkdownPreviewRefresh<cr>", mode = "n", silent = true,
        desc = "markdown-preview: refresh" },
      { "<leader>mq", "<cmd>MarkdownPreviewStop<cr>", mode = "n", silent = true,
        desc = "markdown-preview: stop server" },
    },
  },

  -- tree-sitter-manager: lightweight parser installer for nvim 0.12+
  -- core treesitter (replaces archived nvim-treesitter). Requires
  -- `tree-sitter` CLI on PATH (brew install tree-sitter).
  -- Use :TSManager — i install / x remove / u update / r refresh / q close.
  {
    "romus204/tree-sitter-manager.nvim",
    cmd = "TSManager",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("tree-sitter-manager").setup({ auto_install = true })
      -- jsonl has no dedicated grammar; each line is plain JSON.
      vim.treesitter.language.register("json", "jsonl")
    end,
  },

}
