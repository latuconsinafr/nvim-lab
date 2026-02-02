-- Auto-install lazy.nvim if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if lazy.nvim folder exists, if not clone the stable branch from GitHub
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- Add lazy.nvim path to the beginning of runtimepath so Neovim loads it first
vim.opt.rtp:prepend(lazypath)

-- Load lazy.nvim
local status_ok, lazy = pcall(require, "lazy")

if not status_ok then
  vim.notify("Failed to load lazy.nvim", vim.log.levels.ERROR)

  return
end

-- Call lazy.nvim setup with configuration table
lazy.setup({
  -- Specify plugin specs by importing Lua modules/folders with plugin lists
  spec = {
    { import = "plugins" },              -- main plugins folder
    { import = "plugins.colorschemes" }, -- all color scheme related plugins folder
  },
  checker = { enabled = true }, -- automatically check for plugin updates
})
