# LSP Configuration Guide

This directory contains LSP server configurations for Neovim. Each `.lua` file defines settings for a specific language server.

## How It Works

The main LSP setup is in `lua/settings/lsp.lua`, which:
1. Adds Mason's bin directory to PATH (so servers can be found)
2. Calls `vim.lsp.enable()` with a list of server names
3. Automatically loads config from `/lsp/<server_name>.lua` for each server
4. Sets up diagnostics, keymaps, and completion when LSP attaches

## Config File Structure

Each LSP config file (`/lsp/<server_name>.lua`) returns a table with:

```lua
return {
  cmd = { "command-to-start-server", "--stdio" },  -- Required: How to launch the server
  filetypes = { "filetype1", "filetype2" },        -- Required: When to activate
  root_markers = { "project.file", ".git" },       -- Required: Project root detection
  settings = {                                      -- Optional: Server-specific settings
    -- Only needed if server requires custom config
  },
}
```

### Field Descriptions

- **cmd**: Command array to start the LSP server (must be in PATH or full path)
- **filetypes**: List of filetypes that trigger this server
- **root_markers**: Files/directories that identify project root (searched upward from current file)
- **settings**: Server-specific configuration (usually optional, check server docs)

## Adding a New Language

Follow these steps to add support for a new programming language:

### 1. Install Treesitter Parser

Treesitter provides syntax highlighting and folding.

```vim
:TSInstall <language>
```

**Example:**
```vim
:TSInstall go
:TSInstall python
:TSInstall rust
```

### 2. Install LSP Server via Mason

Mason manages LSP server installations.

```vim
:Mason
```

- Use `/` to search for your language's server
- Navigate to it and press `i` to install
- Press `q` to quit when done

**Common servers:**
- Go: `gopls`
- Python: `pyright` or `pylsp`
- Rust: `rust_analyzer`
- Java: `jdtls`
- C/C++: `clangd`

### 3. Create LSP Config File

Create `/lsp/<server_name>.lua` with the server's configuration.

**Simple template (most servers):**

```lua
return {
  cmd = { "server-binary-name" },
  filetypes = { "language" },
  root_markers = { "project.file", ".git" },
}
```

**Finding the right values:**
- Check Mason's info: `:Mason` → select server → press `g?`
- Check [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- Usually the defaults work fine

**Example: Go (gopls)**

Create `/lsp/gopls.lua`:
```lua
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
}
```

**Example: Python (pyright)**

Create `/lsp/pyright.lua`:
```lua
return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
}
```

### 4. Enable the Server

Edit `lua/settings/lsp.lua` and add your server name to the `vim.lsp.enable()` call:

```lua
vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "pyright",
  "rust_analyzer",
  "gopls",        -- ADD YOUR NEW SERVER HERE
})
```

### 5. Restart Neovim

```vim
:qa
nvim your-file.go
```

### 6. Verify Installation

Check that the server is running:

```vim
:LspInfo
```

You should see your server listed as "Attached" with client id.

## When to Add `settings = {}`

Most servers work fine without custom settings. Only add a `settings` table if:

- **Server docs require it** - Some servers need specific configuration to work
- **You see errors** - Like lua_ls complaining about undefined `vim` global
- **You want custom behavior** - Enable/disable specific features

**Example: lua_ls (requires settings for Neovim)**

```lua
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },  -- Don't error on 'vim' global in Neovim config
      },
      runtime = {
        version = "LuaJIT",  -- Neovim uses LuaJIT
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),  -- Index Neovim runtime
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
```

Check the server's documentation to see available settings:
- [LSP Config Docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- Server's official documentation
- Search for "nvim <server_name> settings"

## Troubleshooting

### Server not starting

1. **Check if installed:**
   ```vim
   :Mason
   ```
   Verify server shows as installed

2. **Check PATH:**
   Mason installs to `~/.local/share/nvim/mason/bin/`
   The `lsp.lua` file adds this to PATH automatically

3. **Check logs:**
   ```vim
   :LspLog
   ```

### Wrong filetype detected

Check the filetype Neovim detects:
```vim
:set filetype?
```

Make sure it matches the `filetypes` in your config.

### Server attaches but gives errors

Check the server's `settings` - it might need custom configuration.
See the server's documentation or check existing configs in nvim-lspconfig.

## Quick Reference

```
New Language Checklist:
□ :TSInstall <language>
□ :Mason → install server
□ Create /lsp/<server_name>.lua
    └─ cmd, filetypes, root_markers
□ Add server to vim.lsp.enable() in lua/settings/lsp.lua
□ Restart Neovim (:qa)
□ Verify with :LspInfo
```

## Existing Configurations

- **lua_ls** - Lua (configured for Neovim development)
- **ts_ls** - TypeScript/JavaScript
- **pyright** - Python
- **rust_analyzer** - Rust

## LSP Keymaps

Once a server is attached, these keymaps are available (defined in `lua/settings/lsp.lua`):

### Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `<C-W>gd` - Definition in vertical split
- `<C-W>gD` - Declaration in horizontal split

### Inspection
- `K` - Hover documentation (default)
- `gl` - Show diagnostic float
- `grn` - Rename symbol (default)

### With fzf-lua (fuzzy search)
- `grr` - References
- `grt` - Type definitions
- `gra` - Code actions
- `gri` - Implementations
- `grd` - Document diagnostics
- `gO` - Document symbols

### Other
- `<leader>f` - Format buffer
- `[d` / `]d` - Navigate diagnostics (default)

## See Also

- [Neovim LSP docs](https://neovim.io/doc/user/lsp.html)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [Mason registry](https://mason-registry.dev/)
