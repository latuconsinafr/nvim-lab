return {
  "echasnovski/mini.cursorword",
  event = "CursorHold",
  config = function()
    require("mini.cursorword").setup({
      delay = 350,
    })

    vim.api.nvim_set_hl(0, "MiniCursorword", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { link = "MiniCursorword" })

    -- Disable mini.cursorword during command-line mode (fixes conflicts with :s///gc)
    -- After disabling there might be highlighting left; it will be removed after next highlighting update.
    vim.api.nvim_create_autocmd("CmdlineEnter", {
      desc = "Disable mini.cursorword in command mode",
      callback = function()
        vim.b.minicursorword_disable = true
      end,
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      desc = "Re-enable mini.cursorword after command mode",
      callback = function()
        vim.b.minicursorword_disable = false
      end,
    })
  end,
}
