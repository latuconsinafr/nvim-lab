return {
  "gbprod/yanky.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
  },
  config = function()
    require("yanky").setup({
      ring = {
        history_length = 100,
        storage = "sqlite",
        storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
        ignore_registers = { "_" },
        update_register_on_cycle = false,
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 100,
      },
    })

    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfterCharwise)", { desc = "Put after" })
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBeforeCharwise)", { desc = "Put before" })
    vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Previous entry" })
    vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "Next entry" })
    vim.keymap.set("n", "<leader>fy", function()
      local ok, yanky_history = pcall(require, "yanky.history")

      if not ok then return end

      local entries, contents = {}, {}
      local history_items = yanky_history.all() or {}

      for _, item in ipairs(history_items) do
        local content = item.regcontents or item.content or ""

        if type(content) == "table" then
          content = table.concat(content, "\n")
        end

        if content ~= "" then
          local preview = content:gsub("\n", " "):sub(1, 80)

          table.insert(contents, content)
          table.insert(entries, string.format("%d: %s", #contents, preview))
        end
      end

      if #entries == 0 then return end

      require('fzf-lua').fzf_exec(entries, {
        preview = function(selected)
          local idx = tonumber(selected[1]:match("^(%d+):"))

          return contents[idx] or ""
        end,
        actions = {
          ['default'] = function(selected)
            local idx = tonumber(selected[1]:match("^(%d+):"))

            if contents[idx] then
              vim.fn.setreg('"', contents[idx])
              vim.api.nvim_paste(contents[idx], false, -1)
            end
          end,
          ['ctrl-y'] = function(selected)
            local idx = tonumber(selected[1]:match("^(%d+):"))

            if contents[idx] then
              vim.fn.setreg('"', contents[idx])
              vim.fn.setreg('+', contents[idx])
            end
          end,
        }
      })
    end, { desc = "Yank history" })
  end,
}
