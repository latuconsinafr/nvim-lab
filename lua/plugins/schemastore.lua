return {
  "b0o/schemastore.nvim",
  filetype = { "json", "jsonc", "yaml" },
  config = function()
    -- After schemastore loads, extend LSP configs to add schemas
    local schemastore = require("schemastore")

    -- Extend jsonls config with JSON schemas
    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      },
    })

    -- Extend yamlls config with YAML schemas
    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemas = schemastore.yaml.schemas(),
          schemaStore = {
            enable = true,
            url = "",
          },
        },
      },
    })
  end,
}
