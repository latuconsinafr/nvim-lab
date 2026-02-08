-- Floating terminal utility
local M = {}

local state = {
  buf = nil,
  win = nil,
}

-- Note: Footer will inherit border background color
-- To make it transparent, you'd need to make FloatBorder transparent too
vim.api.nvim_set_hl(0, "TerminalFooter", {
  fg = "#f6c177",
  bg = "#1f1d2e",
  bold = true,
})

-- Helper to get mode display text with position info
local function get_mode_text()
  local mode = vim.api.nvim_get_mode().mode
  local mode_icon = ""

  if mode == "t" then
    mode_icon = "󰠠"
  elseif mode == "nt" or mode == "n" then
    mode_icon = ""
  elseif mode:match("^[vV]") or mode == "\22" then
    mode_icon = "󱠆"
  elseif mode == "c" then
    mode_icon = ""
  else
    mode_icon = mode:upper()
  end

  -- Add position info for visual mode or when searching
  local extra_info = ""

  -- Normal mode: show current line / total lines
  if mode == "nt" or mode == "n" then
    local cursor = vim.api.nvim_win_get_cursor(state.win)
    local total_lines = vim.api.nvim_buf_line_count(state.buf)

    extra_info = string.format(" [%d/%d]", cursor[1], total_lines)
  end

  -- Search mode: show match count
  if vim.v.hlsearch == 1 and vim.fn.getreg('/') ~= '' then
    local ok, search_count = pcall(vim.fn.searchcount, { recompute = 1, maxcount = -1 })

    if ok and search_count.total > 0 then
      extra_info = string.format(" [%d/%d]", search_count.current, search_count.total)
    end
  end

  return mode_icon .. extra_info
end

-- Update footer with current mode
local function update_footer()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    local config = vim.api.nvim_win_get_config(state.win)

    config.footer = { { string.format("  %s  ", get_mode_text()), "TerminalFooter" } }
    config.footer_pos = "right"

    vim.api.nvim_win_set_config(state.win, config)
  end
end

M.toggle = function()
  -- Check if terminal buffer is visible in any window
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == state.buf then
        -- Terminal is visible, close it
        vim.api.nvim_win_close(win, true)
        state.win = nil

        return
      end
    end
  end

  -- Create terminal buffer if needed
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].buflisted = false
  end

  -- Calculate floating window size
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor(((vim.o.lines - height) / 2) - ((vim.o.lines - height) / 2 * 0.1))
  local col = math.floor((vim.o.columns - width) / 2)

  -- Open floating window
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    footer = { { "󰠠", "TerminalFooter" } },
    footer_pos = "right",
  })

  -- Set up autocmds to update footer on mode change and cursor movement
  local augroup = vim.api.nvim_create_augroup("TerminalModeIndicator", { clear = true })

  vim.api.nvim_create_autocmd("ModeChanged", {
    group = augroup,
    callback = function()
      update_footer()
    end,
  })

  -- Update footer on cursor move (for visual mode line tracking)
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    buffer = state.buf,
    callback = function()
      update_footer()
    end,
  })

  -- Update footer on search (for search match tracking)
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    callback = function()
      vim.defer_fn(update_footer, 50)
    end,
  })

  -- Initial footer update
  vim.defer_fn(update_footer, 50)

  -- Start terminal if buffer is empty (first time)
  if vim.api.nvim_buf_line_count(state.buf) == 1 and vim.api.nvim_buf_get_lines(state.buf, 0, 1, false)[1] == "" then
    vim.fn.termopen(vim.o.shell)
  end

  -- Enter insert mode automatically
  vim.cmd("startinsert")
end

return M
