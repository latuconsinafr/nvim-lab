return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "default",
      -- Add <CR> (Enter) as ergonomic alternative to <C-y> for accepting
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
    },
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
        },
      },
      per_filetype = {
        sql = { "lsp", "dadbod", "snippets", "buffer", "path" },
        mysql = { "lsp", "dadbod", "snippets", "buffer", "path" },
        plsql = { "lsp", "dadbod", "snippets", "buffer", "path" },
      },
    },
  },
}
