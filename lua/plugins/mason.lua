return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  opts = {},
  config = function(_, opts)
    require("mason").setup(opts)
  end,
}
