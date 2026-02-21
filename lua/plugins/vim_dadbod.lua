return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    "tpope/vim-dadbod",
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUILastQueryInfo" },
  keys = {
    {
      "<leader>dd",
      function()
        vim.cmd("DBUIToggle")
      end,
      desc = "Toggle database UI"
    },
    { "<leader>da", "<cmd>DBUIAddConnection<CR>",     desc = "Add database connection" },
    { "<leader>dl", "<cmd>DBUILastQueryInfo<CR>",     desc = "Last query info" },
    { "<leader>d]", desc = "Grow database UI width" },
    { "<leader>d[", desc = "Shrink database UI width" },
  },
  init = function()
    -- Prevent .psqlrc from interfering with metadata queries
    vim.env.PSQLRC = "/dev/null"

    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_winwidth = 40
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui"
    vim.g.db_ui_auto_execute_table_helpers = 1
  end,
  config = function()
    local sidebar = require("settings.utils.sidebar")
    local original_width = 40
    local step = 10

    -- Register dbuid as a sidebar
    sidebar.register({
      filetype = "dbui",
      close_cmd = "DBUIClose",
      min_width = original_width,
      on_resize = function(new_width)
        vim.g.db_ui_winwidth = new_width
      end,
    })

    -- Setup sidebar resize keymaps
    sidebar.setup_resize_keymaps("dbui", "<leader>d]", "<leader>d[", {
      min_width = original_width,
      step = step,
      grow_desc = "Grow database explorer width",
      shrink_desc = "Shrink database explorer width",
    })

    -- Setup mutual exclusivity
    sidebar.setup_exclusivity("dbui")

    -- Setup DBUI query buffers (only for buffers with database connection)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function(args)
        -- Query execution keymaps (only for DBUI query buffers)
        if vim.b[args.buf].db then
          vim.keymap.set({ "n", "v" }, "<leader>dq", "<Plug>(DBUI_ExecuteQuery)",
            { buffer = args.buf, desc = "Run query" })
          vim.keymap.set("n", "<leader>ds", "<Plug>(DBUI_SaveQuery)",
            { buffer = args.buf, desc = "Save query" })
        end
      end,
    })

    local dbout_group = vim.api.nvim_create_augroup("DadbodDboutUI", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = dbout_group,
      pattern = "dbout",
      callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.colorcolumn = ""
        vim.opt_local.wrap = false
        vim.opt_local.cursorline = true

        vim.keymap.set("n", "<Tab>", "f|2l", { buffer = args.buf, desc = "Next column" })
        vim.keymap.set("n", "<S-Tab>", "F|2h", { buffer = args.buf, desc = "Previous column" })
        vim.keymap.set("n", "]c", "f|2l", { buffer = args.buf, desc = "Next column" })
        vim.keymap.set("n", "[c", "F|2h", { buffer = args.buf, desc = "Previous column" })
        vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, desc = "Close query results" })
      end,
    })
  end,
}
