-- rainbow-delimiters: colorize nested brackets via treesitter.
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("rainbow-delimiters.setup").setup({})
  end,
}
