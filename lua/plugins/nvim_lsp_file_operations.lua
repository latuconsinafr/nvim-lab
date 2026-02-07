return {
  "antosha417/nvim-lsp-file-operations",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-tree.lua",
  },
  event = "LspAttach",
  opts = {
    debug = false,
    timeout_ms = 10000,
  },
  config = function(_, opts)
    require("lsp-file-operations").setup(opts)
  end,
}
