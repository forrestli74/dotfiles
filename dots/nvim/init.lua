-- Leader: no mappings use it yet, but plugins may. Must precede lazy.setup.
vim.g.mapleader = " "

-- Disable netrw (recommended by nvim-tree)
-- https://github.com/nvim-tree/nvim-tree.lua#setup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Built-in markdown ftplugin folds by heading level when this is set.
vim.g.markdown_folding = 1

-- Bootstrap lazy.nvim (https://lazy.folke.io/installation)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")

----------------------------- OPTIONS -----------------------------
local opt = vim.opt

opt.cursorline = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true

opt.colorcolumn = "80"
opt.number = false
opt.relativenumber = false

opt.list = true

opt.termguicolors = true

opt.autowriteall = true
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.whichwrap = "b,s,h,l,<,>,[,],~"
opt.display:append("uhex")

opt.wildmode = "list:longest,list:full"
opt.splitbelow = true
opt.splitright = true

opt.diffopt:append("vertical")
opt.complete = "."
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.foldtext = ""
opt.scrolloff = 3

opt.undofile = true

opt.mouse = "a"

pcall(vim.cmd.colorscheme, "catppuccin")

----------------------------- KEYMAPS -----------------------------
local map = vim.keymap.set

map("i", "jk", "<Esc>")

map("", "0", "^")
map("", "gy", '"+y')
map("", "gp", '"+p')
map("", "gP", '"+P')

map("c", "%%", "<C-r>=expand('%:h')<CR>/")

map("n", "<leader>w", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("wrap: " .. (vim.wo.wrap and "on" or "off"), vim.log.levels.INFO)
end, { desc = "toggle wrap" })

-- Tab: native keyword completion after a word char; literal tab otherwise.
map("i", "<Tab>", function()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("[%w_]") == nil then
    return "<Tab>"
  end
  return "<C-p>"
end, { expr = true })

----------------------------- AUTOCMDS -----------------------------
local grp = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Built-in tree-sitter highlighting where a parser exists; silently no-op
-- otherwise, so files without parsers fall through to regex syntax.
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "markdown", "gitcommit" },
  callback = function() vim.wo.spell = true end,
})

-- nowrap: in-buffer markdown renderers (render-markdown.nvim) skip
-- table rendering when lines wrap, since extmark column math breaks.
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = "markdown",
  callback = function()
    vim.bo.textwidth = 80
    vim.wo.wrap = false
  end,
})

----------------------------- LOCAL -----------------------------
local local_cfg = vim.fn.expand("~/.vimrc.local")
if vim.fn.filereadable(local_cfg) == 1 then
  vim.cmd.source(local_cfg)
end

----------------------------- TODO ------------------------------
-- Open decisions:
--   [ ] pick colorscheme; prune the rest.
--
-- Kept with caveats:
--   lazyredraw removed; risky in nvim.
--   whichwrap all-on; watch for l-at-EOL surprise.
--   colorcolumn=80 fixed; won't follow per-ft textwidth.
