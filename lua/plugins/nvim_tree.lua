return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local view_module    = require("nvim-tree.view")
    local sidebar        = require("settings.utils.sidebar")
    local original_width = 45
    local step           = 10

    require("nvim-tree").setup {
      sort_by = "case_sensitive",
      view = { width = original_width },
      renderer = {
        group_empty = true,
        indent_markers = { enable = true },
        icons = { show = { hidden = true } },
      },
      filters = {
        dotfiles = false,
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

    -- Use "I" inside the nvim tree to toggle hidden git files

    -- Register NvimTree as a sidebar
    sidebar.register({
      filetype = "NvimTree",
      close_cmd = "NvimTreeClose",
      min_width = original_width,
      custom_resize = function(delta, min_width)
        if not view_module.is_visible() then
          vim.notify("NvimTree sidebar not found", vim.log.levels.WARN)

          return false
        end

        local cur = view_module.View.width or original_width
        local new_width

        if delta > 0 then
          new_width = math.min(vim.o.columns, cur + delta)
        else
          new_width = math.max(min_width, cur + delta)
        end

        view_module.resize(new_width)

        return true, new_width
      end,
    })

    -- Setup resize keymaps
    sidebar.setup_resize_keymaps("NvimTree", "<leader>e>", "<leader>e<", {
      min_width = original_width,
      step = step,
      grow_desc = "Grow file explorer width",
      shrink_desc = "Shrink file explorer width"
    })

    -- Setup mutual exclusivity
    sidebar.setup_exclusivity("NvimTree")

    vim.keymap.set("n", "<leader>ee", function()
      vim.cmd("NvimTreeToggle")
    end, { desc = "Toggle explorer" })
    vim.keymap.set("n", "<leader>er", function()
      if not view_module.is_visible() then
        vim.notify("NvimTree sidebar not found", vim.log.levels.WARN)
        return
      end

      vim.cmd("NvimTreeRefresh")
    end, { desc = "Refresh explorer" })

    vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#6e6a86" })
    vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "#26233a" })
  end,
}
