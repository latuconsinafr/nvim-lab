return {
  "nvim-tree/nvim-tree.lua", 
  version = "*",            
  lazy = false,            
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local api            = require("nvim-tree.api")
    local view_module    = require("nvim-tree.view")
    local original_width = 40
    local step           = 10

    local function is_sidebar_open(ft)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)

        if vim.bo[buf].filetype == ft then
          return true
        end
      end
      return false
    end

    local function ensure_exclusive_nvimtree()
      if is_sidebar_open("dbui") then
        vim.cmd("DBUIClose")
      end

      if not view_module.is_visible() then
        api.tree.open()
      end
    end

    local function grow_tree()
      ensure_exclusive_nvimtree()

      local cur = view_module.View.width or original_width
      local nw  = math.min(vim.o.columns, cur + step)

      view_module.resize(nw)
    end

    local function shrink_tree()
      ensure_exclusive_nvimtree()

      local cur = view_module.View.width or original_width
      local nw  = math.max(original_width, cur - step)

      view_module.resize(nw)
    end

    require("nvim-tree").setup {
      sort_by = "case_sensitive",
      view = { width = original_width },
      renderer = {
        indent_markers = { enable = true },
        icons = { show = { hidden = true } },
      },
      filters = {
        custom = {        
          "^.git$",       
          "^.svn$",     
          "^.hg$",       
          "^CVS$",     
          "^.DS_Store$",  
          "^Thumbs.db$", 
        },
      },
      git = {
        timeout = 500,  
      },
    }

    vim.keymap.set("n", "<leader>e", function()
      if is_sidebar_open("dbui") then
        vim.cmd("DBUIClose")
      end

      vim.cmd("NvimTreeToggle")
    end, { desc = "Toggle explorer" })

    vim.keymap.set("n", "<leader>er", function()
      ensure_exclusive_nvimtree()

      vim.cmd("NvimTreeRefresh")
    end, { desc = "Refresh explorer" })

    vim.keymap.set("n", "<leader>ef", function()
      ensure_exclusive_nvimtree()

      vim.cmd("NvimTreeFindFile")
    end, { desc = "Find file in explorer" })

    vim.keymap.set("n", "<leader>e]", grow_tree, { desc = "Grow explorer by 10 cols" })
    vim.keymap.set("n", "<leader>e[", shrink_tree, { desc = "Shrink explorer by 10 cols (min " .. original_width.. ")" })

    vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#6e6a86" })
    vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "#26233a" })
  end,
}

