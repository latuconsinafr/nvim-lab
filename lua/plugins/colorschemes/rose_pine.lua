return {
  {
    "rose-pine/neovim",
    name = "rose-pine", 
    config = function()
      require('rose-pine').setup({
        variant = "auto",
        dark_variant = "main",

        styles = {
          bold = false,
          italic = false,
        },
      })

      vim.cmd("colorscheme rose-pine")
    end
  }
}
