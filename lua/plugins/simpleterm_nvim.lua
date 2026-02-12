return {
  "latuconsinafr/simpleterm.nvim",
  config = function()
    require("simpleterm").setup({
      window = {
        row_offset = 0.25,
      }
    })

    vim.api.nvim_set_hl(0, "SimpletermFooter", { fg = "#f6c177", bg = "#1f1d2e", bold = true })
  end
}
