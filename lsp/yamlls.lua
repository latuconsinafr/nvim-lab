return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
  root_markers = { ".git" },
  single_file_support = true,
  settings = {
    yaml = {
      schemas = {}, -- Will be populated by lsp.lua if schemastore available
      validate = true,
      format = { enable = true },
      hover = true,
      completion = true,
      schemaStore = {
        enable = false, -- Will be enabled by lsp.lua if schemastore available
        url = "",
      },
    },
  },
}
