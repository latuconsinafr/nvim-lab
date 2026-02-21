return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git", "package.json" },
  single_file_support = true,
  settings = {
    json = {
      schemas = {}, -- Will be populated by lsp.lua if schemastore available
      validate = { enable = true },
      format = { enable = true },
    },
  },
}
