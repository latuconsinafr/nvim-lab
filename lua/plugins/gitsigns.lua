return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      numhl = false,
      linehl = false,
      word_diff = false,
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 100,
        virt_text_pos = "eol",
      },
      current_line_blame_formatter = "      <author>, <author_time:%R> - <summary>",
      current_line_blame_formatter_nc = '    Not commited yet',
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          opts.silent = true
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "<leader>gl", "<cmd>Gitsigns setqflist all<CR>", { desc = "List all hunks in quickfix" })

        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gitsigns.next_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Next git hunk" })

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gitsigns.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous git hunk" })

        map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview git hunk" })
        map("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle git line blame" })
        map("n", "<leader>gB", function() gitsigns.blame_line({ full = true }) end, { desc = "Git blame full" })
        map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff against index" })
        map("n", "<leader>gD", function() gitsigns.diffthis("~") end, { desc = "Diff against last commit" })
      end,
    })
  end,
}
