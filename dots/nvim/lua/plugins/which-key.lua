-- which-key: popup lists keybindings after any prefix press (<leader>,
-- g, z...) so chords are self-documenting. <leader>? shows buffer maps.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = {
      rules = {
        { pattern = "yank", icon = "󰆏", color = "yellow" },
      },
    },
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end,
      desc = "which-key: buffer keymaps" },
  },
}
