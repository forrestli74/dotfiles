-- nvim-tmux-navigation: lua rewrite of vim-tmux-navigator. Same tmux-side
-- plugin (christoomey/vim-tmux-navigator in tmux.conf) keeps working.
-- Trade-off vs original: no save-on-switch, no tmate support.
return {
  "alexghergh/nvim-tmux-navigation",
  event = "VeryLazy",
  opts = {
    disable_when_zoomed = true,
    keybindings = {
      left  = "<C-h>",
      down  = "<C-j>",
      up    = "<C-k>",
      right = "<C-l>",
      last_active = "<C-\\>",
    },
  },
}
