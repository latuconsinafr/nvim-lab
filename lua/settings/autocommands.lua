local create_autocmd = vim.api.nvim_create_autocmd

--------------------------------------------------
-- 1. Global
--------------------------------------------------
-- Yank feedback
-- Disabled, already use yanky
-- create_autocmd("TextYankPost", {
--   desc = "Highlight yanked text",
--   callback = function()
--     vim.highlight.on_yank({ timeout = 100 })
--   end,
-- })

-- Large file protection
create_autocmd("BufReadPre", {
  desc = "Disable expensive features for large files",
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, args.file)
    if not ok or not stats then return end

    if stats.size > 1024 * 1024 then -- 1 MB threshold
      vim.b.large_file = true
      vim.opt_local.syntax = "off"
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
    end
  end,
})

--------------------------------------------------
-- 2. Buffer specific
--------------------------------------------------
-- Disable <C-l> for window navigation if we use netrw
vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable netrw <C-l> for window navigation",
  pattern = "netrw",
  callback = function()
    -- Use pcall to safely try to delete the mapping
    pcall(vim.keymap.del, "n", "<C-l>", { buffer = true })  
  end,
})

-- Prose-oriented buffers
create_autocmd("FileType", {
  desc = "Enable wrap and spell for prose",
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
  end,
})

-- Help buffer ergonomics
create_autocmd("FileType", {
  desc = "Make help buffers easy to close",
  pattern = "help",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = true, silent = true })
  end,
})

-- Line numbers by context
create_autocmd("FileType", {
  desc = "Disable line numbers in reading-oriented buffers",
  pattern = { "help", "gitcommit" },
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

