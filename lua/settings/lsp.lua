--------------------------------------------------
-- 1. Mason bin PATH (so Neovim can find servers)
--------------------------------------------------
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

--------------------------------------------------
-- 2. Enable language servers (configs in lsp/ dir)
--------------------------------------------------
-- List of LSP servers to enable (add/remove as needed)
local servers = {
  "lua_ls",
  "ts_ls",
  "eslint",
  "pyright",
  "rust_analyzer",
}

-- Load blink.cmp capabilities if available
local has_blink, blink = pcall(require, "blink.cmp")
local capabilities = has_blink and blink.get_lsp_capabilities() or nil

-- Inject blink capabilities into each server config
if capabilities then
  local config_path = vim.fn.stdpath("config") .. "/lsp"

  for _, server in ipairs(servers) do
    local config_file = config_path .. "/" .. server .. ".lua"

    if vim.fn.filereadable(config_file) == 1 then
      local config = dofile(config_file)

      config.capabilities = capabilities
      vim.lsp.config[server] = config
    end
  end
end

vim.lsp.enable(servers)

--------------------------------------------------
-- 3. Diagnostics
--------------------------------------------------
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "󰗖",
      [vim.diagnostic.severity.HINT]  = "󰘥",
      [vim.diagnostic.severity.INFO]  = "󰋼",
    },
  },
})

--------------------------------------------------
-- 4. LspAttach: keymaps + built-in completion
--------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP keymaps and completion",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then return end

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    --------------------------------------------------
    -- Neovim 0.11 Default LSP Keymaps (NOT overridden)
    --------------------------------------------------
    -- These work out of the box, listed here for reference:
    --   grn         - Rename
    --   <C-X><C-O>  - Omnifunc
    --   K           - Hover documentation
    --   [d / ]d     - Navigate diagnostics
    --   <C-S>       - Signature help (insert mode)
    --   <C-W>d      - Open diagnostic float in new window
    --   <C-W><C-D>  - Same as above

    --------------------------------------------------
    -- Navigation (single/certain results - keep as default)
    --------------------------------------------------
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

    --------------------------------------------------
    -- Split window alternatives
    --------------------------------------------------
    map("n", "<C-W>gd", function()
      vim.cmd.split()
      vim.lsp.buf.definition()
    end, "Go to definition in vsplit")

    map("n", "<C-W>gD", function()
      vim.cmd.split()
      vim.lsp.buf.declaration()
    end, "Go to declaration in split")

    --------------------------------------------------
    -- Override defaults with FzfLua (multiple results benefit from fuzzy search)
    --------------------------------------------------
    local ok, fzf = pcall(require, "fzf-lua")
    if ok then
      map("n", "grr", fzf.lsp_references, "References (FzfLua)")
      map("n", "grt", fzf.lsp_typedefs, "Type definitions (FzfLua)")
      map({ "n", "x" }, "gra", fzf.lsp_code_actions, "Code actions (FzfLua)")
      map("n", "gri", fzf.lsp_implementations, "Implementations (FzfLua)")
      map("n", "grd", fzf.diagnostics_document, "Document diagnostics (FzfLua)")
      map("n", "gO", fzf.lsp_document_symbols, "Document symbols (FzfLua)")
    end

    --------------------------------------------------
    -- Format
    --------------------------------------------------
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")

    --------------------------------------------------
    -- Built-in completion (disabled when using blink.cmp)
    --------------------------------------------------
    -- Native completion is disabled in favor of blink.cmp
    -- If you remove blink.cmp, uncomment below:
    -- if client:supports_method("textDocument/completion") then
    --   vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    -- end
  end,
})

--------------------------------------------------
-- Helper: Check LSP status for current buffer
--------------------------------------------------
vim.api.nvim_create_user_command("LspStatus", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients == 0 then
    vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
    return
  end

  local lines = { "LSP Clients attached to this buffer:\n" }

  for _, client in ipairs(clients) do
    table.insert(lines, string.format("• %s (id: %d)", client.name, client.id))

    if client.config.root_dir then
      table.insert(lines, string.format("  root: %s", client.config.root_dir))
    end
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show LSP client status for current buffer" })

--------------------------------------------------
-- 5. SQL Formatting (standalone, no LSP required)
--------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function(args)
    vim.keymap.set("n", "<leader>f", function()
      if vim.fn.executable("sql-formatter") == 0 then
        vim.notify("sql-formatter not found. Install: npm install -g sql-formatter", vim.log.levels.WARN)
        return
      end

      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
      local content = table.concat(lines, "\n")
      local formatted = vim.fn.system("sql-formatter", content)

      if vim.v.shell_error == 0 then
        vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, vim.split(formatted, "\n"))
        vim.notify("SQL formatted", vim.log.levels.INFO)
      else
        vim.notify("Failed to format SQL: " .. formatted, vim.log.levels.ERROR)
      end
    end, { buffer = args.buf, desc = "Format SQL" })
  end,
})
