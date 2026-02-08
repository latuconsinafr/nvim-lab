local g = vim.g

--------------------------------------------------
-- 1. Leader keys (must be first)
--------------------------------------------------
g.mapleader = " "
g.maplocalleader = " "

--------------------------------------------------
-- 2. Minimal globals (startup sanity)
--------------------------------------------------
-- Disable netrw (will manage files explicitly)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

--------------------------------------------------
-- 3. Disable unused providers (massive startup improvement)
--------------------------------------------------
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
