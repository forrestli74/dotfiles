-- markdown-preview.nvim (selimacerbas rewrite): browser preview with
-- live Mermaid/KaTeX rendering. Pure-Lua HTTP server (no Node), SSE
-- transport. Use this when render-markdown.nvim isn't enough — i.e.
-- you actually want diagrams rendered, not just styled code blocks.
return {
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
}
