local M = {}

--------------------------------------------------
-- Excluded filetypes and buftypes
-- Used across settings and plugins for consistency
--------------------------------------------------
M.exclude_filetypes = {
  "NvimTree",
  "help",
  "qf",
  "lazy",
  "mason",
  "oil",
  "dbui",
  "dbout",
}

M.exclude_buftypes = {
  "terminal",
  "quickfix",
  "help",
  "nofile",
  "prompt",
}

--- Check if a value exists in a table
---@param tbl table
---@param value any
---@return boolean
function M.contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

--- Check if a buffer is a "special" buffer (sidebar, floating, etc.)
---@param bufnr? number Buffer number (defaults to current)
---@return boolean
function M.is_special_buffer(bufnr)
  bufnr = bufnr or 0
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype
  return M.contains(M.exclude_buftypes, buftype) or M.contains(M.exclude_filetypes, filetype)
end

--- Get list of normal (non-special) buffers, ordered by last used
---@return number[] List of buffer numbers
function M.get_normal_buffers()
  local bufs = {}

  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if not M.is_special_buffer(buf.bufnr) then
      table.insert(bufs, buf)
    end
  end

  -- Sort by lastused (most recent first)
  table.sort(bufs, function(a, b)
    return (a.lastused or 0) > (b.lastused or 0)
  end)

  local result = {}
  for _, buf in ipairs(bufs) do
    table.insert(result, buf.bufnr)
  end

  return result
end

--- Get list of special buffers (sidebars, etc.)
---@return number[] List of buffer numbers
function M.get_special_buffers()
  local bufs = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and M.is_special_buffer(buf) then
      table.insert(bufs, buf)
    end
  end

  return bufs
end

--- Close current buffer and switch to another normal buffer
--- Respects sidebar/pinned buffers - won't leave you on NvimTree
--- If last normal buffer, falls back to special buffer or quits Neovim
function M.close_current_buffer()
  local current = vim.api.nvim_get_current_buf()

  -- If current buffer is special (sidebar like NvimTree)
  if M.is_special_buffer(current) then
    local normal_bufs = M.get_normal_buffers()

    if #normal_bufs > 0 then
      -- There are normal buffers, just close this window
      vim.cmd("close")
    else
      -- No normal buffers, this is the last thing open, quit
      vim.cmd("quit")
    end
    return
  end

  -- Current buffer is normal
  local normal_bufs = M.get_normal_buffers()

  -- Find next normal buffer to switch to (exclude current)
  local next_buf = nil
  for _, bufnr in ipairs(normal_bufs) do
    if bufnr ~= current then
      next_buf = bufnr
      break
    end
  end

  if next_buf then
    -- Switch to next normal buffer first, then delete current
    vim.api.nvim_set_current_buf(next_buf)
    vim.api.nvim_buf_delete(current, { force = false })
  else
    -- No other normal buffers
    local special_bufs = M.get_special_buffers()

    if #special_bufs > 0 then
      -- Close the window first (sidebar takes over fullscreen)
      -- then wipe the buffer
      local win_count = #vim.api.nvim_list_wins()
      if win_count > 1 then
        vim.cmd("close")
      end
      -- Now delete the orphaned buffer
      pcall(vim.api.nvim_buf_delete, current, { force = true })
    else
      -- No buffers left at all, quit Neovim
      vim.cmd("quit")
    end
  end
end

--- Close all other normal buffers except current
--- Keeps sidebar/pinned buffers intact
function M.close_other_buffers()
  local current = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      -- Only close normal buffers, keep special ones
      if not M.is_special_buffer(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = false })
      end
    end
  end
end

return M
