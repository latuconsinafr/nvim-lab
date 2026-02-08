-- Utility functions for sidebar
local M = {}

-- Registry of all sidebar configurations
M.sidebars = {}

-- Register a sidebar with its configuration
function M.register(config)
  if not config.filetype then
    error("Sidebar registration requires 'filetype' field")
  end

  M.sidebars[config.filetype] = {
    filetype = config.filetype,
    close_cmd = config.close_cmd,
    min_width = config.min_width or 40,
    on_resize = config.on_resize,
    custom_resize = config.custom_resize,
  }
end

-- Find a sidebar window by filetype
function M.find_window(filetype)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == filetype then
      return win
    end
  end
  return nil
end

-- Check if a sidebar is open
function M.is_open(filetype)
  return M.find_window(filetype) ~= nil
end

-- Close all other sidebars except the specified one
function M.close_others(current_filetype)
  for filetype, config in pairs(M.sidebars) do
    if filetype ~= current_filetype and M.is_open(filetype) then
      if config.close_cmd then
        vim.cmd(config.close_cmd)
      end
    end
  end
end

-- Resize a sidebar window
function M.resize(filetype, delta, min_width)
  local config = M.sidebars[filetype]

  -- Use custom resize if provided
  if config and config.custom_resize then
    min_width = min_width or config.min_width or 40
    return config.custom_resize(delta, min_width)
  end

  -- Otherwise use default implementation
  local win = M.find_window(filetype)

  if not win then
    vim.notify(string.format("%s sidebar not found", filetype), vim.log.levels.WARN)
    return false
  end

  min_width = min_width or (config and config.min_width) or 40

  local current_width = vim.api.nvim_win_get_width(win)
  local new_width = math.max(min_width, current_width + delta)

  vim.api.nvim_win_set_width(win, new_width)

  -- Call optional resize callback
  if config and config.on_resize then
    config.on_resize(new_width)
  end

  return true, new_width
end

-- Setup standard resize keymaps for a sidebar
function M.setup_resize_keymaps(filetype, key_grow, key_shrink, opts)
  opts = opts or {}
  local step = opts.step or 10
  local min_width = opts.min_width or 40

  vim.keymap.set("n", key_grow, function()
    M.resize(filetype, step, min_width)
  end, { desc = opts.grow_desc or string.format("Grow %s width", filetype) })

  vim.keymap.set("n", key_shrink, function()
    M.resize(filetype, -step, min_width)
  end, { desc = opts.shrink_desc or string.format("Shrink %s width", filetype) })
end

-- Setup mutual exclusivity autocmd for a sidebar
function M.setup_exclusivity(filetype)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      M.close_others(filetype)
    end,
  })
end

return M
