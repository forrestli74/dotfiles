-- gitsigns: git gutter + per-hunk stage/preview/diff.
-- All actions: :Gitsigns <Tab>. Only one user keymap bound.
return {
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
}
