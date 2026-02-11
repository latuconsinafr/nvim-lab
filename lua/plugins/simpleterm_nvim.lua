return {
  "latuconsinafr/simpleterm.nvim",
  config = function()
    require("simpleterm").setup({
      window = {
        row_offset = 0.25,
      }
    })
  end
}
