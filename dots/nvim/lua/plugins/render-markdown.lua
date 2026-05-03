-- render-markdown.nvim: in-buffer rendering of headings, code fences,
-- tables, checkboxes, etc. Uses core treesitter (nvim 0.12+); the
-- markdown/markdown_inline parsers auto-install via tree-sitter-manager.
return {
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
}
