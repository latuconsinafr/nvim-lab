return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local use_global_width = false
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

    local function get_width()
      if use_global_width then
        return vim.o.columns
      else
        return vim.api.nvim_win_get_width(0)
      end
    end

    local function hide_below(width)
      return get_width() > width 
    end
    
    local function is_special_buffer()
      for _, ft in ipairs(exclude_filetypes) do
        if vim.bo.filetype == ft then
          return true
        end
      end

      return false
    end

    local function is_not_special_buffer()
      return not is_special_buffer()
    end
    
    local function buf_position()
      if is_special_buffer() then
        return "" 
      end
      
      local function contains(table, value)
        for _, v in ipairs(table) do
          if v == value then return true end
        end

        return false
      end
      
      local function is_excluded(buftype, filetype)
        return contains(exclude_buftypes, buftype) or contains(exclude_filetypes, filetype)
      end
      
      local current = vim.fn.bufnr("%")
      local listed = {}
      
      for _, buf in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
        local buftype = vim.fn.getbufvar(buf.bufnr, "&buftype")
        local filetype = vim.fn.getbufvar(buf.bufnr, "&filetype")
        
        if not is_excluded(buftype, filetype) and buftype == "" then
          table.insert(listed, buf.bufnr)
        end
      end
      
      
      local pos = 0

      for i, bufnr in ipairs(listed) do
        if bufnr == current then
          pos = i
          break
        end
      end
      
      local total = #listed
      
      if not is_excluded(vim.bo.buftype, vim.bo.filetype) and pos > 0 then
        return string.format(" %d (%d/%d)", current, pos, total)
      elseif total > 0 then
        return string.format("(%d bufs)", total)
      end
      
      return ""
    end
    
    require('lualine').setup {
      options = {
        theme = 'auto',
        section_separators = { left = '', right = '' }, 
        component_separators = { left = '', right = '' },
        globalstatus = use_global_width
      },
      sections = {
        lualine_a = {
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
        },
        lualine_b = {
          { 
            buf_position, 
            cond = function() 
              return is_not_special_buffer() 
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
              if is_special_buffer() then
                return str
              end
              
              local win_width = vim.api.nvim_win_get_width(0)
              local result = ""
              
              -- Get the filename based on width
              if win_width < 80 then -- only show file name
                local filename = vim.fn.fnamemodify(str, ':t')
                local max_len = math.max(10, math.floor(win_width * 0.5))
                
                if #filename > max_len then
                  result = filename:sub(1, max_len - 3) .. "..."
                else
                  result = filename
                end
              elseif win_width < 120 then -- show parent/file
                local full_path = vim.fn.expand("%:~:.")
                local parts = vim.split(full_path, '/', { plain = true })

                if #parts >= 2 then
                  result = parts[#parts - 1] .. '/' .. parts[#parts]
                else
                  result = str
                end
              else -- show full relative path
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
              
              -- Manually add symbols (required with custom fmt)
              if vim.bo.modified then
                result = result .. " ●"
              end
              if vim.fn.expand("%") == "" then
                result = "[No Name]"
              end
              
              return result
            end,
          } 
        },
        lualine_x = {
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
          { 'progress' }
        },
        lualine_z = {
          { 'location' }
        },
      },
    }
  end,
}
