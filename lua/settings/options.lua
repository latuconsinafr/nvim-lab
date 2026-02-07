local opt = vim.opt

--------------------------------------------------
-- 1. Core options: feel, clarity, performance
--------------------------------------------------
-- UI clarity
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes:2"
opt.termguicolors = true
opt.fillchars = { eob = " " }
opt.colorcolumn = "100"
opt.synmaxcol = 200 -- color column is 100, it make sense to syntax doubled from it
opt.showmatch = true
opt.matchtime = 2

-- Completion behaviour
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }

-- Editing behaviour
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Responsiveness
opt.updatetime = 200      -- faster CursorHold, diagnostics
opt.timeoutlen = 500      -- snappy key sequences
opt.redrawtime = 10000    -- avoid long redraw slowdowns on very large files
opt.maxmempattern = 10000 -- regex memory safety

-- Navigation comfort
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.startofline = false -- preserve column on jumps
opt.lazyredraw = true   -- avoid excessive redraws

-- Search sanity
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.wrapscan = false -- do not wrap searches silently

--------------------------------------------------
-- 2. Editor state & safety (undo / swap / backup)
--------------------------------------------------
local state_dir = vim.fn.stdpath("state")

opt.undofile = true     -- persistent undo
opt.swapfile = true     -- crash recovery
opt.backup = false      -- no ~ files
opt.writebackup = false -- avoid partial writes
opt.autoread = true     -- auto reload files changed outside vim

opt.undodir = state_dir .. "/undo//"
opt.backupdir = state_dir .. "/backup//"
opt.directory = state_dir .. "/swap//"

--------------------------------------------------
-- 3. Command-line UX
--------------------------------------------------
opt.wildmenu = true
opt.wildmode = { "longest", "full" }

opt.wildignore:append({
  "*.o", "*.obj", "*.bin", "*.exe",
  "*.jpg", "*.png", "*.gif",
  "*.zip", "*.tar", "*.gz",
  "nore_modules/*", ".git/*",
})

opt.cmdheight = 0
opt.showcmd = true
opt.showcmdloc = "statusline" -- Enable showcmd in statusline (use %S in lualine)

--------------------------------------------------
-- 4. Window & buffer semantics
--------------------------------------------------
opt.hidden = true -- allow background buffers
opt.confirm = true
opt.equalalways = true
opt.winwidth = 20
opt.winminwidth = 10
opt.winheight = 5
opt.winminheight = 5
opt.switchbuf = { "useopen" } -- reuse existing windows

--------------------------------------------------
-- 5. Folding (Treesitter-based)
--------------------------------------------------
opt.foldenable = true
-- opt.foldmethod = "manual" -- disabled, use treesitter expr
opt.foldmethod = "expr"
opt.foldlevelstart = 99 -- no folds closed
opt.foldcolumn = "0"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "" -- use default fold text (cleaner)

--------------------------------------------------
-- 6. Movement precision & cursor semantics
--------------------------------------------------
opt.linebreak = true
opt.breakindent = true
opt.breakindentopt = "shift:2"
opt.whichwrap:append("<,>,h,l") -- allow cursor wrap to next/prev line with 'h' and 'l'
opt.virtualedit = "block"

--------------------------------------------------
-- 7. Clipboard & registers
--------------------------------------------------
opt.clipboard = "unnamedplus"

--------------------------------------------------
-- 8. Diagnostics & message discipline
--------------------------------------------------
opt.shortmess:append({
  W = true,
  I = true,
  c = true
})
opt.report = 999
opt.errorbells = false
opt.visualbell = false
opt.belloff = "all"
