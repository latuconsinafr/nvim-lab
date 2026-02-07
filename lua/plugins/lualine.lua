return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local buffers = require("settings.utils.buffers")
    local use_global_width = false

    local function hide_below(width)
      local current_width = vim.o.columns

      if not use_global_width then
        current_width = vim.api.nvim_win_get_width(0)
      end

      return current_width > width
    end

    local function is_special_buffer()
      return buffers.is_special_buffer()
    end

    local function is_not_special_buffer()
      return not is_special_buffer()
    end

    require('lualine').setup {
      options = {
        theme = 'auto',
        section_separators = { left = '', right = ' ' },
        component_separators = { left = '', right = ' ' },
        globalstatus = use_global_width
      },
      sections = {
        lualine_a = {
          {
            'mode',
            cond = is_not_special_buffer,
          },
          {
            function()
              local reg = vim.fn.reg_recording()

              if reg == "" then return "" end

              return "recording @" .. reg
            end,
          },
        },
        lualine_b = {
          {
            'branch',
            cond = function()
              return is_not_special_buffer() and hide_below(80)
            end,
            fmt = function(str)
              if #str > 27 then
                return str:sub(1, 24) .. "..."
              end

              return str
            end
          },
          {
            'diff',
            cond = function()
              return is_not_special_buffer() and hide_below(85)
            end
          },
          {
            'diagnostics',
            cond = function()
              return is_not_special_buffer()
            end
          }
        },
        lualine_c = {
          {
            'filename',
            path = 0,
            fmt = function(str)
              -- Strip any existing indicators to prevent duplication
              str = str:gsub(" %[%+%]", ""):gsub(" %[%-%]", "")

              local result = str

              if is_special_buffer() then
                return result
              end

              -- Normal buffers: apply width-based truncation
              local win_width = vim.api.nvim_win_get_width(0)

              -- Get the filename based on width
              if win_width < 80 then -- only show file name
                local filename = vim.fn.fnamemodify(str, ':t')
                local max_len = math.max(10, math.floor(win_width * 0.5))

                if #filename > max_len then
                  result = filename:sub(1, max_len - 3) .. "..."
                else
                  result = filename
                end
              -- Show parent/file
              elseif win_width < 120 then
                local full_path = vim.fn.expand("%:~:.")
                local parts = vim.split(full_path, '/', { plain = true })

                if #parts >= 2 then
                  result = parts[#parts - 1] .. '/' .. parts[#parts]
                else
                  result = str
                end
              -- Show full relative path
              else
                local max_len = math.floor(win_width * 0.4)
                local full_path = vim.fn.expand("%:~:.")

                if #full_path > max_len then
                  local parts = vim.split(full_path, '/', { plain = true })

                  if #parts > 2 then
                    result = '.../' .. parts[#parts - 1] .. '/' .. parts[#parts]
                  elseif #parts == 2 then
                    result = parts[#parts - 1] .. '/' .. parts[#parts]
                  else
                    result = parts[#parts]
                  end
                else
                  result = full_path
                end
              end

              if vim.fn.expand("%") == "" then
                result = "[No Name]"
              end

              if not vim.bo.modifiable then
                result = " [-]" .. result
              end

              if vim.bo.modified then
                result = result .. " [+]"
              end

              return result
            end,
          }
        },
        lualine_x = {
          {
            "%S",  
          },
          {
            function()
              if vim.v.hlsearch == 0 then return "" end

              local ok, search = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })

              if not ok or search.total == 0 then return "" end

              return string.format("[%d/%d]", search.current, search.total)
            end,
            cond = function()
              return vim.v.hlsearch == 1
            end,
          },
          {
            'encoding',
            cond = function()
              return is_not_special_buffer() and hide_below(140)
            end
          },
          {
            'fileformat',
            cond = function()
              return is_not_special_buffer() and hide_below(130)
            end
          },
          {
            'filetype',
            cond = function()
              return is_not_special_buffer() and hide_below(110)
            end
          },
        },
        lualine_y = {
          {
            'progress',
            cond = is_not_special_buffer,
          }
        },
        lualine_z = {
          { 'location' }
        },
      },
    }
  end,
}
