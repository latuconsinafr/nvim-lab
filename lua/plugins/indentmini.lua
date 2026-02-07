return {
  "nvimdev/indentmini.nvim",
  event = "BufReadPre",
  config = function()
    require("indentmini").setup({
      char = "│",
    })

    vim.api.nvim_set_hl(0, "IndentLine", { fg = "#6e6a86" })
    vim.api.nvim_set_hl(0, "IndentLineCurrent", { fg = "#c0bcd4", bold = true })
  end,
}
