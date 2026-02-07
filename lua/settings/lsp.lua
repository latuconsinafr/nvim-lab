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
vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "pyright",
  "rust_analyzer",
})

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
    -- Override default for semantics
    --------------------------------------------------
    map("n", "gl", vim.diagnostic.open_float, "Show diagnostic float")

    --------------------------------------------------
    -- Navigation (single/certain results - keep as default)
    --------------------------------------------------
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

    --------------------------------------------------
    -- Split window alternatives
    --------------------------------------------------
    map("n", "<C-W>gd", function()
      vim.cmd.vsplit()
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
    -- Built-in completion (auto-trigger as you type)
    --------------------------------------------------
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
  end,
})
