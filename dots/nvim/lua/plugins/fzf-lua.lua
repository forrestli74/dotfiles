-- fzf-lua: lua rewrite of fzf.vim. Same fzf binary backend; adds LSP
-- pickers (lsp_references, document_symbols, diagnostics) and richer
-- git UI (:FzfLua git_status with inline stage/unstage). All pickers
-- under the :FzfLua command — :FzfLua builtin to discover them.
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  keys = {
    { "<C-p>",      "<cmd>FzfLua command_history<cr>", mode = "n", silent = true, desc = "fzf-lua: command history" },
    { "<C-t>",      "<cmd>FzfLua files<cr>",           mode = "n", silent = true, desc = "fzf-lua: find files" },
    { "<leader>/",  "<cmd>FzfLua live_grep<cr>",       mode = "n", silent = true, desc = "fzf-lua: live grep" },
  },
  opts = {
    winopts = {
      width  = 0.8,
      height = 0.8,
      preview = { layout = "vertical", vertical = "up:80%" },
    },
  },
}
