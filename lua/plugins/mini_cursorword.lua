return {
  "echasnovski/mini.cursorword",
  event = "CursorHold",
  config = function()
    require("mini.cursorword").setup({
      delay = 350,
    })

    vim.api.nvim_set_hl(0, "MiniCursorword", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", {}) -- use different background than rosepine when use substitute
  end,
}
