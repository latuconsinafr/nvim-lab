return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "lua",
        "typescript",
        "javascript",
        "python",
        "rust",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
      },
      auto_install = false,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })

    -- Textobjects config (options only, no keymaps)
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    })

    -- Textobjects keymaps (manual setup required by new API)
    local ts_select = require("nvim-treesitter-textobjects.select")
    local ts_move = require("nvim-treesitter-textobjects.move")
    local ts_swap = require("nvim-treesitter-textobjects.swap")

    -- Select textobjects
    vim.keymap.set({ "x", "o" }, "af", function() ts_select.select_textobject("@function.outer", "textobjects") end,
      { desc = "Select outer function" })
    vim.keymap.set({ "x", "o" }, "if", function() ts_select.select_textobject("@function.inner", "textobjects") end,
      { desc = "Select inner function" })
    vim.keymap.set({ "x", "o" }, "ac", function() ts_select.select_textobject("@class.outer", "textobjects") end,
      { desc = "Select outer class" })
    vim.keymap.set({ "x", "o" }, "ic", function() ts_select.select_textobject("@class.inner", "textobjects") end,
      { desc = "Select inner class" })
    vim.keymap.set({ "x", "o" }, "aa", function() ts_select.select_textobject("@parameter.outer", "textobjects") end,
      { desc = "Select outer parameter" })
    vim.keymap.set({ "x", "o" }, "ia", function() ts_select.select_textobject("@parameter.inner", "textobjects") end,
      { desc = "Select inner parameter" })
    vim.keymap.set({ "x", "o" }, "ai", function() ts_select.select_textobject("@conditional.outer", "textobjects") end,
      { desc = "Select outer conditional" })
    vim.keymap.set({ "x", "o" }, "ii", function() ts_select.select_textobject("@conditional.inner", "textobjects") end,
      { desc = "Select inner conditional" })
    vim.keymap.set({ "x", "o" }, "al", function() ts_select.select_textobject("@loop.outer", "textobjects") end,
      { desc = "Select outer loop" })
    vim.keymap.set({ "x", "o" }, "il", function() ts_select.select_textobject("@loop.inner", "textobjects") end,
      { desc = "Select inner loop" })
    vim.keymap.set({ "x", "o" }, "a/", function() ts_select.select_textobject("@comment.outer", "textobjects") end,
      { desc = "Select outer comment" })

    -- Move to next/previous textobjects
    vim.keymap.set({ "n", "x", "o" }, "]f", function() ts_move.goto_next_start("@function.outer", "textobjects") end,
      { desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "[f", function() ts_move.goto_previous_start("@function.outer", "textobjects") end,
      { desc = "Previous function start" })
    vim.keymap.set({ "n", "x", "o" }, "]F", function() ts_move.goto_next_end("@function.outer", "textobjects") end,
      { desc = "Next function end" })
    vim.keymap.set({ "n", "x", "o" }, "[F", function() ts_move.goto_previous_end("@function.outer", "textobjects") end,
      { desc = "Previous function end" })
    vim.keymap.set({ "n", "x", "o" }, "]c", function() ts_move.goto_next_start("@class.outer", "textobjects") end,
      { desc = "Next class start" })
    vim.keymap.set({ "n", "x", "o" }, "[c", function() ts_move.goto_previous_start("@class.outer", "textobjects") end,
      { desc = "Previous class start" })
    vim.keymap.set({ "n", "x", "o" }, "]C", function() ts_move.goto_next_end("@class.outer", "textobjects") end,
      { desc = "Next class end" })
    vim.keymap.set({ "n", "x", "o" }, "[C", function() ts_move.goto_previous_end("@class.outer", "textobjects") end,
      { desc = "Previous class end" })
    vim.keymap.set({ "n", "x", "o" }, "]a", function() ts_move.goto_next_start("@parameter.inner", "textobjects") end,
      { desc = "Next parameter" })
    vim.keymap.set({ "n", "x", "o" }, "[a", function() ts_move.goto_previous_start("@parameter.inner", "textobjects") end,
      { desc = "Previous parameter" })

    -- Swap parameters
    vim.keymap.set("n", "<leader>sp", function() ts_swap.swap_next("@parameter.inner") end,
      { desc = "Swap parameter with next" })
    vim.keymap.set("n", "<leader>sP", function() ts_swap.swap_previous("@parameter.inner") end,
      { desc = "Swap parameter with previous" })

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Start treesitter highlighting",
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- Helper: Check Treesitter status for current buffer
    vim.api.nvim_create_user_command("TSStatus", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo[bufnr].filetype

      if ft == "" then
        vim.notify("No filetype set for this buffer", vim.log.levels.WARN)
        return
      end

      local lines = { string.format("Treesitter Status (filetype: %s)\n", ft) }

      -- Check if parser is available
      local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr)

      if has_parser and parser then
        local lang = parser:lang()

        table.insert(lines, string.format("✓ Parser attached: %s", lang))

        -- Check if highlighting is enabled
        local highlighter = vim.treesitter.highlighter.active[bufnr]

        if highlighter then
          table.insert(lines, "✓ Highlighting: enabled")
        else
          table.insert(lines, "✗ Highlighting: disabled")
        end
      else
        table.insert(lines, string.format("✗ No parser available for '%s'", ft))
        table.insert(lines, "\nInstall with: :TSInstall " .. ft)
      end

      -- List all installed parsers (check parser directory)
      local parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser"
      local installed = {}
      if vim.fn.isdirectory(parser_dir) == 1 then
        for name in vim.fs.dir(parser_dir) do
          if name:match("%.so$") or name:match("%.dll$") then
            local parser_name = name:gsub("%.so$", ""):gsub("%.dll$", "")
            installed[#installed + 1] = parser_name
          end
        end
        table.sort(installed)
      end

      table.insert(lines, "\nInstalled parsers:")
      if #installed > 0 then
        table.insert(lines, "  " .. table.concat(installed, ", "))
      else
        table.insert(lines, "  (none)")
      end

      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
    end, { desc = "Show Treesitter status for current buffer" })
  end,
}
