-- tree-sitter-manager: lightweight parser installer for nvim 0.12+
-- core treesitter (replaces archived nvim-treesitter). Requires
-- `tree-sitter` CLI on PATH (brew install tree-sitter).
-- Use :TSManager — i install / x remove / u update / r refresh / q close.
return {
  "romus204/tree-sitter-manager.nvim",
  cmd = "TSManager",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("tree-sitter-manager").setup({ auto_install = true })
    -- jsonl has no dedicated grammar; each line is plain JSON.
    vim.treesitter.language.register("json", "jsonl")
  end,
}
