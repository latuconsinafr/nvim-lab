-- Utility functions for marks.nvim integration
local M = {}

-- Get all marks from a specific bookmark group (0-9)
-- Returns a formatted list suitable for fzf-lua
M.get_group_marks = function(group_nr)
  local ok, marks_module = pcall(require, 'marks')
  if not ok or not marks_module.bookmark_state then
    vim.api.nvim_echo({{"marks.nvim not loaded or bookmark_state unavailable", "WarningMsg"}}, false, {})
    return {}
  end

  local group = marks_module.bookmark_state.groups[group_nr]
  if not group or not group.marks then
    vim.api.nvim_echo({{"No marks in group " .. group_nr, "Normal"}}, false, {})
    return {}
  end

  local items = {}
  for bufnr, buffer_marks in pairs(group.marks) do
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
      filename = "[No Name]"
    end

    for line, mark in pairs(buffer_marks) do
      local text = ""
      if vim.api.nvim_buf_is_loaded(bufnr) then
        local lines = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)
        text = lines[1] or ""
        text = text:gsub("^%s+", "")  -- trim leading whitespace
      end

      -- Format: filename:line:col text
      local entry = string.format("%s:%d:%d: %s",
        filename,
        line,
        mark.col + 1,
        text
      )
      table.insert(items, entry)
    end
  end

  -- Sort by filename, then line number
  table.sort(items)

  if #items == 0 then
    vim.api.nvim_echo({{"No marks in group " .. group_nr, "Normal"}}, false, {})
  end

  return items
end

return M
