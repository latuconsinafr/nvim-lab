# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration (located at `~/.config/nvim-lab`) built with Lua, using lazy.nvim as the plugin manager and Neovim 0.11+ native LSP. It follows a modular structure with clear separation between settings, plugins, and LSP configurations.

## Architecture

### Initialization Flow

1. **init.lua** - Entry point that loads modules in sequence:
   - `settings.global` → Leader keys and core globals
   - `settings.options` → Editor options and behavior
   - `settings.autocommands` → Autocmd definitions
   - `settings.maps` → Global keymaps
   - `settings.lsp` → LSP configuration and keymaps
   - `settings.plugins` → Plugin manager setup

### Directory Structure

```
.
├── init.lua                 # Entry point
├── lua/
│   ├── settings/
│   │   ├── global.lua       # Leader keys, netrw disabled
│   │   ├── options.lua      # All vim.opt settings
│   │   ├── autocommands.lua # FileType autocmds, large file handling
│   │   ├── maps.lua         # Core keybindings
│   │   ├── lsp.lua          # LSP setup, diagnostics, LspAttach
│   │   ├── plugins.lua      # lazy.nvim bootstrap & setup
│   │   └── utils/
│   │       └── buffers.lua  # Buffer utilities (close, filter special buffers)
│   └── plugins/
│       ├── *.lua            # Individual plugin specs
│       └── colorschemes/    # Color scheme plugins
└── lsp/
    ├── lua_ls.lua           # Lua LSP config
    ├── ts_ls.lua            # TypeScript/JavaScript LSP config
    ├── pyright.lua          # Python LSP config
    └── rust_analyzer.lua    # Rust LSP config
```

### Plugin Management

Uses **lazy.nvim** with automatic installation. Plugin specs are defined in `lua/plugins/` and `lua/plugins/colorschemes/` directories. Each plugin is a separate file returning a lazy.nvim spec table.

Key plugins:
- **nvim-tree.lua** - File explorer (replaces netrw)
- **fzf-lua** - Fuzzy finder for files, grep, buffers, LSP
- **mason.nvim** - LSP/DAP/linter installer
- **treesitter** - Syntax highlighting
- **gitsigns** - Git integration
- **lualine** - Statusline
- **yanky** - Yank history
- **nvim-surround** - Surround motions
- **vim-tmux-navigator** - Seamless tmux/vim navigation

### LSP Architecture

**Centralized LSP Setup** (`lua/settings/lsp.lua`):
- Mason bin path is added to $PATH
- `vim.lsp.enable()` activates servers: `lua_ls`, `ts_ls`, `pyright`, `rust_analyzer`
- LSP configs are loaded from `lsp/*.lua` files (each returns a config table)
- **LspAttach autocmd** sets up keymaps and enables built-in completion per buffer
- Diagnostics configured with rounded borders, severity signs, and virtual text

### Buffer Management

The `lua/settings/utils/buffers.lua` module provides smart buffer handling:
- **Special buffers** (NvimTree, help, qf, lazy, mason, etc.) are tracked separately
- `close_current_buffer()` - Intelligently closes buffers without leaving you stranded in a sidebar
- `close_other_buffers()` - Closes all normal buffers except current, preserves sidebars
- Used by `<leader>bc` and `<leader>bo` keymaps

### Key Mappings Philosophy

- **Leader key**: `<Space>`
- **Delete/change without yanking**: `d` and `c` use black hole register by default
- **Centered scrolling**: All navigation (n/N, C-d/C-u, {/}) centers cursor with `zz`
- **Visual mode persistence**: Indent with `<`/`>` maintains selection
- **Split navigation**: `<C-hjkl>` for window movement (overridden by vim-tmux-navigator)
- **Buffer navigation**: `<S-h>`/`<S-l>` for prev/next buffer

### LSP Keymaps (set on LspAttach)

Core navigation:
- `gd` - Go to definition
- `gD` - Go to declaration
- `gy` - Go to type definition
- `K` - Hover (bordered)
- Defaults from Neovim 0.11: `grn` (rename), `gra` (code action), `grr` (references), `gri` (implementation), `gO` (document symbols)

Workspace:
- `<leader>wa` - Add workspace folder
- `<leader>wr` - Remove workspace folder
- `<leader>wl` - List workspace folders

Formatting:
- `<leader>f` - Format buffer (async)

FzfLua LSP pickers (if available):
- `<leader>ls` - Document symbols
- `<leader>lS` - Workspace symbols
- `<leader>ld` - Definitions
- `<leader>lr` - References
- `<leader>ldd` - Document diagnostics
- `<leader>lc` - Code actions

### FzfLua Keymaps

- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fh` - Help tags
- `<leader>fb` - Buffers
- `<leader>fc` - Commands
- `<leader>fr` - Recent files (oldfiles)

### File Explorer (NvimTree)

- `<leader>e` - Toggle explorer
- `<leader>er` - Refresh explorer
- `<leader>ef` - Find current file in explorer
- `<leader>e]` - Grow explorer width by 10 cols
- `<leader>e[` - Shrink explorer width by 10 cols

### Notable Editor Options

- **Command line**: `cmdheight=0` for clean UI, with `showcmd` displayed in statusline
- **Completion**: Native LSP completion with autotrigger enabled
- **Undo/Swap**: Persistent undo, swapfile enabled for crash recovery
- **Large file protection**: Files >1MB disable syntax, folding, swap, undo
- **Search**: Smart case-sensitive, no wrap search
- **Indentation**: 2 spaces, expandtab, smartindent
- **Performance**: updatetime=200ms, timeoutlen=500ms, lazyredraw enabled

### Statusline (Lualine) Layout

**Left side (lualine_a/b):**
- Mode indicator (minimal, single letter: N/I/V/C)
- Recording indicator (shows when recording macros)
- Git branch (conditional on window width)
- Git diff (conditional on window width)
- Diagnostics (errors, warnings, etc.)

**Center (lualine_c):**
- Filename with intelligent truncation based on window width

**Right side (lualine_x/y/z):**
- Search count ([3/10] when searching)
- Showcmd (partial commands shown automatically via `showcmdloc`)
- Encoding (conditional on window width)
- File format (conditional on window width)
- Filetype (conditional on window width)
- Progress percentage
- Cursor location (line:column)

## Development Commands

This configuration does not require building or testing. To modify:

### Reload Configuration

```vim
:source %
```

Or use the keymap:
```
<leader>rr  " Force reload current file (with confirmation)
```

### Plugin Management

```vim
:Lazy          " Open lazy.nvim UI
:Lazy sync     " Install/update/clean plugins
:Lazy clean    " Remove unused plugins
```

### LSP Management

```vim
:Mason         " Open Mason UI to install/update LSP servers
:LspInfo       " Show attached LSP clients for current buffer
:LspRestart    " Restart LSP client
```

Or use the keymap:
```
<leader>cm     " Open Mason UI
```

### Diagnostics

```vim
:lua vim.diagnostic.open_float()  " Show diagnostics in float
:lua vim.diagnostic.setloclist()  " Send diagnostics to location list
```

Or use keymaps:
```
<leader>e      " Show diagnostic float
<leader>q      " Diagnostics to location list
[d / ]d        " Navigate diagnostics (Neovim 0.11 defaults)
```

## Adding New LSP Servers

1. Install the server via Mason: `:Mason` → search → press `i`
2. Create a config file: `lsp/<server_name>.lua` with a table containing:
   - `cmd` - Command to start server
   - `filetypes` - File types to activate on
   - `root_markers` - Root directory detection patterns
   - `settings` - Server-specific settings (optional)
3. Add server name to `vim.lsp.enable()` call in `lua/settings/lsp.lua`

Example pattern (see `lsp/lua_ls.lua`, `lsp/ts_ls.lua`):

```lua
return {
  cmd = { "server-command" },
  filetypes = { "lang" },
  root_markers = { "project.json", ".git" },
  settings = {
    -- Server-specific config
  },
}
```

## Adding New Plugins

1. Create a new file in `lua/plugins/<plugin_name>.lua`
2. Return a lazy.nvim plugin spec table:

```lua
return {
  "author/plugin-name",
  dependencies = { "optional-dep" },
  event = "VeryLazy",  -- or cmd, keys, ft, etc.
  opts = {},           -- Passed to setup()
  config = function(_, opts)
    require("plugin-name").setup(opts)
  end,
}
```

3. Restart Neovim or run `:Lazy sync`

## Buffer Utilities

When working with buffer management code, use the utilities in `lua/settings/utils/buffers.lua`:

- `buffers.is_special_buffer(bufnr)` - Check if buffer is a sidebar/special buffer
- `buffers.get_normal_buffers()` - Get list of normal buffers (sorted by last used)
- `buffers.get_special_buffers()` - Get list of special buffers
- `buffers.close_current_buffer()` - Smart close that avoids leaving user in a sidebar
- `buffers.close_other_buffers()` - Close all except current, preserving sidebars

Excluded filetypes and buftypes are defined in `buffers.exclude_filetypes` and `buffers.exclude_buftypes`.
