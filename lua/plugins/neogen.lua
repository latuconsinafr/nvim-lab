return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",
  cmd = "Neogen",
  keys = {
    { "<leader>ng", "<cmd>Neogen<cr>",       desc = "Generate doc (auto-detect)" },
    { "<leader>nf", "<cmd>Neogen func<cr>",  desc = "Generate function doc" },
    { "<leader>nc", "<cmd>Neogen class<cr>", desc = "Generate class doc" },
    { "<leader>nt", "<cmd>Neogen type<cr>",  desc = "Generate type doc" },
  },
  opts = {
    enabled = true,
    snippet_engine = "nvim",
    languages = {
      lua = {
        template = {
          annotation_convention = "ldoc",
        },
      },
      typescript = {
        template = {
          annotation_convention = "tsdoc",
        },
      },
      javascript = {
        template = {
          annotation_convention = "jsdoc",
        },
      },
      python = {
        template = {
          annotation_convention = "google_docstrings",
        },
      },
      rust = {
        template = {
          annotation_convention = "rustdoc",
        },
      },
    },
  },
}
