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
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN]  = "W",
      [vim.diagnostic.severity.HINT]  = "H",
      [vim.diagnostic.severity.INFO]  = "I",
    },
  },
})

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic (float)" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

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

    -- Navigation (supplement Neovim 0.11 defaults)
    -- Defaults already provide: grn (rename), gra (code action),
    -- grr (references), gri (implementation), gO (document symbols),
    -- K (hover), [d / ]d (diagnostic nav), <C-s> (signature help)
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")

    -- Override default K with bordered hover
    map("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, "Hover documentation")

    -- Workspace
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")

    -- Format
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")

    -- Fzf-lua LSP pickers (if available)
    local ok, fzf = pcall(require, "fzf-lua")
    if ok then
      map("n", "<leader>ls", fzf.lsp_document_symbols, "Document symbols")
      map("n", "<leader>lS", fzf.lsp_workspace_symbols, "Workspace symbols")
      map("n", "<leader>ld", fzf.lsp_definitions, "Definitions")
      map("n", "<leader>lD", fzf.lsp_declarations, "Declarations")
      map("n", "<leader>lr", fzf.lsp_references, "References")
      map("n", "<leader>li", fzf.lsp_implementations, "Implementations")
      map("n", "<leader>lt", fzf.lsp_typedefs, "Type definitions")
      map("n", "<leader>lI", fzf.lsp_incoming_calls, "Incoming calls")
      map("n", "<leader>lO", fzf.lsp_outgoing_calls, "Outgoing calls")
      map("n", "<leader>ldd", fzf.diagnostics_document, "Document diagnostics")
      map("n", "<leader>ldw", fzf.diagnostics_workspace, "Workspace diagnostics")
      map("n", "<leader>lc", fzf.lsp_code_actions, "Code actions")
    end

    -- Built-in completion (auto-trigger as you type)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
  end,
})
