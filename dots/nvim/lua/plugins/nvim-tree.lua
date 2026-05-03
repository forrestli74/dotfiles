-- nvim-tree: file-tree sidebar (replaces NERDTree).
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- lazy = false so the plugin is registered at startup; this makes
  -- `:e .` (or any directory edit) hijack into nvim-tree without first
  -- needing an explicit :NvimTreeToggle to load it.
  lazy = false,
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
      -- Unmap default <C-t> (open-in-new-tab) so the global fzf-lua
      -- files picker takes over inside the tree pane. Use `t` for tab.
      pcall(vim.keymap.del, "n", "<C-t>", { buffer = bufnr })
    end,
  },
}
