return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "lua",
      },
      auto_install = false,
    })

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Start treesitter highlighting",
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
