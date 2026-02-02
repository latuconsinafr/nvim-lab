local keymap = vim.keymap.set

--------------------------------------------------
-- 1. Safer defaults
--------------------------------------------------
keymap("n", "Q", "<nop>", { noremap = true, silent = true, desc = "Disable accidental Ex mode" })
keymap({ "n", "x" }, "d", '"_d', { noremap = true, silent = true, desc = "Delete without yanking" })
keymap({ "n", "x" }, "c", '"_c', { noremap = true, silent = true, desc = "Change without yanking" })
keymap("x", "p", '"_dp', { noremap = true, silent = true, desc = "Paste after without overwriting default register" })
keymap("x", "P", '"_dP', { noremap = true, silent = true, desc = "Paste before without overwriting default register" })
-- keymap("n", "<leader>e", vim.cmd.Ex, { noremap = true, silent = true, desc = "Open file explorer (netrw)" })

--------------------------------------------------
-- 2. Better movement
--------------------------------------------------
keymap("n", "n", "nzzzv", { noremap = true, silent = true, desc = "Next search result and center cursor" })
keymap("n", "N", "Nzzzv", { noremap = true, silent = true, desc = "Previous search result and center cursor" })
keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down half-page and center cursor" })
keymap("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up half-page and center cursor" })
keymap("n", "<C-f>", "<C-f>zz", { noremap = true, silent = true, desc = "Scroll forward full-page and center cursor" })
keymap("n", "<C-b>", "<C-b>zz", { noremap = true, silent = true, desc = "Scroll backward full-page and center cursor" })
keymap("n", "{", "{zz", { noremap = true, silent = true, desc = "Move paragraph backward and center cursor" })
keymap("n", "}", "}zz", { noremap = true, silent = true, desc = "Move paragraph forward and center cursor" })
keymap("n", "<C-o>", "<C-o>zz", { noremap = true, silent = true, desc = "Jump backward in jumplist and center cursor" })
keymap("n", "<C-i>", "<C-i>zz", { noremap = true, silent = true, desc = "Jump forward in jumplist and center cursor" })

--------------------------------------------------
-- 3. Visual mode sanity
--------------------------------------------------
keymap("x", "<", "<gv", { noremap = true, silent = true, desc = "Indent left and stay in visual mode" })
keymap("x", ">", ">gv", { noremap = true, silent = true, desc = "Indent right and stay in visual mode" })
keymap("x", "J", ":move '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines down" })
keymap("x", "K", ":move '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selected lines up" })

--------------------------------------------------
-- 4. Clipboard (system-aware)
--------------------------------------------------
-- Optional if clipboard is set to unnamedplus
-- keymap({ "n", "x" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to system clipboard" })
-- keymap("n", "<leader>Y", '"+Y', { noremap = true, silent = true, desc = "Yank current line to system clipboard" })
-- keymap({ "n", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from system clipboard" })
-- keymap({ "n", "x" }, "<leader>P", '"+P', { noremap = true, silent = true, desc = "Paste before cursor from system clipboard" })

--------------------------------------------------
-- 5. Quick escapes
--------------------------------------------------
keymap("i", "<C-c>", "<Esc>", { noremap = true, silent = true, desc = "Quick escape from insert mode" })

--------------------------------------------------
-- 6. Split navigation
--------------------------------------------------
keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Move to left split" })
keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Move to bottom split" })
keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Move to top split" })
keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Move to right split" })
keymap("n", "<C-\\>", "<C-w>p", { noremap = true, silent = true, desc = "Move to previous split" })

--------------------------------------------------
-- 7. Window resizing
--------------------------------------------------
-- keymap("n", "<C-w>+", ":resize +1<CR>", { noremap = true, silent = true, desc = "Increase window height" })
-- keymap("n", "<C-w>-", ":resize -1<CR>", { noremap = true, silent = true, desc = "Decrease window height" })
-- keymap("n", "<C-w><", ":vertical resize -1<CR>", { noremap = true, silent = true, desc = "Decrease window width" })
-- keymap("n", "<C-w>>", ":vertical resize +1<CR>", { noremap = true, silent = true, desc = "Increase window width" })

--------------------------------------------------
-- 8. Buffer navigation
--------------------------------------------------
keymap("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true, desc = "Go to next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Go to previous buffer" })
keymap("n", "<leader>bc", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close current buffer" })
keymap("n", "<leader>bo", function()
  local exclude_filetypes = {
    "NvimTree",
    "help",
    "qf",
    "lazy",
    "mason",
  }
  local exclude_buftypes = {
    "terminal",
    "quickfix",
    "help",
    "nofile",
    "prompt",
  }
  local curr = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= curr and vim.api.nvim_buf_is_loaded(buf) then
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

      if not contains(exclude_buftypes, buftype) and not contains(exclude_filetypes, filetype) then
        vim.api.nvim_buf_delete(buf, { force = false })

      end
    end
  end
end, { noremap = true, silent = true, desc = "Close other buffers (ignore special buffers)" })

--------------------------------------------------
-- 9. Join lines without moving cursor
--------------------------------------------------
keymap("n", "J", "mzJ`z", { noremap = true, silent = true, desc = "Join lines without moving cursor" })

--------------------------------------------------
-- 10. Easy line duplication
--------------------------------------------------
keymap("n", "<leader>yy", ":t.<CR>", { noremap = true, silent = true, desc = "Duplicate current line below" })
keymap("n", "<leader>Yy", ":t-1<CR>", { noremap = true, silent = true, desc = "Duplicate current line above" })
keymap("x", "<leader>yy", ":t'>+0<CR>gv", { noremap = true, silent = true, desc = "Duplicate selected lines below" })
keymap("x", "<leader>Yy", ":t'<-1<CR>gv", { noremap = true, silent = true, desc = "Duplicate selected lines above" })

--------------------------------------------------
-- 11. Remove search highlight
--------------------------------------------------
keymap("n", "<Esc><Esc>", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

--------------------------------------------------
-- 12. Reload
--------------------------------------------------
keymap('n', '<leader>rr', function()
  local choice = vim.fn.confirm(
    "Reload current file from disk? Unsaved changes will be lost!",
    "&Yes\n&No", 2
  )

  if choice == 1 then
    vim.cmd('e!')

    print("File reloaded from disk ✅")
  else
    print("Reload canceled ❌")
  end
end, { noremap = true, silent = true, desc = "Force reload current file with confirmation" })

--------------------------------------------------
-- 13. Quickfix
--------------------------------------------------
keymap("n", "<leader>qf", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "qf" then
      vim.cmd("cclose")
      return
    end
  end
  vim.cmd("copen")
end, { noremap = true, silent = true, desc = "Toggle quickfix window" })

-- Navigate quickfix list
keymap("n", "<C-n>", "<cmd>cnext<CR>zz", { noremap = true, silent = true, desc = "Next quickfix item and center" })
keymap("n", "<C-p>", "<cmd>cprev<CR>zz", { noremap = true, silent = true, desc = "Previous quickfix item and center" })

--------------------------------------------------
-- 14. Find/Replace/Delete
--------------------------------------------------
keymap("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { noremap = true, silent = true, desc = "Replace current word globally (no confirm)" })
keymap("n", "<leader>rwc", [[:.,$s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]],
  { noremap = true, silent = true, desc = "Replace current word from cursor to EOF (confirm)" })
keymap("n", "<leader>rg", [[:%s//gI<Left><Left><Left>]],
  { noremap = true, silent = true, desc = "Replace arbitrary word globally" })
keymap("n", "<leader>rgc", [[:.,$s//gc<Left><Left><Left>]],
  { noremap = true, silent = true, desc = "Replace arbitrary word from cursor to EOF (confirm)" })
keymap("n", "<leader>dw", [[:g/\<<C-r><C-w>\>/d<CR>]],
  { noremap = true, silent = true, desc = "Delete all lines containing current word" })
keymap("n", "<leader>df", [[:g//d<Left><Left>]],
  { noremap = true, silent = true, desc = "Delete all lines matching last search" })
