return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  cmd = "FzfLua",
  keys = {
    { "<leader>ff",  "<cmd>FzfLua files<CR>",                                                                                                                                 desc = "Find Files" },
    { "<leader>fg",  "<cmd>FzfLua live_grep<CR>",                                                                                                                             desc = "Live Grep" },
    { "<leader>fh",  "<cmd>FzfLua help_tags<CR>",                                                                                                                             desc = "Help Tags" },
    { "<leader>fb",  "<cmd>FzfLua buffers<CR>",                                                                                                                               desc = "Buffers" },
    { "<leader>fc",  "<cmd>FzfLua commands<CR>",                                                                                                                              desc = "Commands" },
    { "<leader>fC",  "<cmd>FzfLua command_history<CR>",                                                                                                                       desc = "Commands history" },
    { "<leader>fr",  "<cmd>FzfLua oldfiles<CR>",                                                                                                                              desc = "Recent Files" },
    { "<leader>fma",  "<cmd>FzfLua marks<CR>",                                                                                                                                 desc = "Marks (All)" },
    { "<leader>fm0", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(0),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 0" },
    { "<leader>fm1", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(1),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 1" },
    { "<leader>fm2", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(2),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 2" },
    { "<leader>fm3", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(3),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 3" },
    { "<leader>fm4", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(4),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 4" },
    { "<leader>fm5", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(5),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 5" },
    { "<leader>fm6", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(6),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 6" },
    { "<leader>fm7", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(7),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 7" },
    { "<leader>fm8", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(8),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 8" },
    { "<leader>fm9", function() require("fzf-lua").fzf_exec(require("settings.utils.marks").get_group_marks(9),
        { actions = require("fzf-lua").defaults.actions.files }) end,                                                                                                         desc = "Marks Group 9" },
    { "<leader>f?",  "<cmd>FzfLua keymaps<CR>",                                                                                                                               desc = "Keymaps" }
  },

  config = function()
    local actions = require("fzf-lua.actions")
    local fzf = require("fzf-lua")

    fzf.setup({
      winopts = {
        height = 0.8,
        width = 0.8,
        row = 0.5,
        col = 0.5,
        border = "rounded",
        preview = {
          default = "builtin",
          border  = "rounded",
          winopts = {
            signcolumn = "yes",
          }
        },
      },
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"]   = "inline",
      },
      keymap = {
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-a"] = "toggle-all",
        },
      },
      actions = {
        files = {
          ["default"] = actions.file_edit,
          ["ctrl-q"] = actions.file_sel_to_qf,
          ["ctrl-y"] = function(selected)
            local cleaned = {}

            for _, line in ipairs(selected) do
              local path = line:match("[%w%./~%-_]+.*")
              table.insert(cleaned, path)
            end

            local text = table.concat(cleaned, "\n")

            vim.fn.setreg("+", text)
            vim.defer_fn(function()
              vim.api.nvim_echo(
                { { "Copied " .. #cleaned .. " selected item(s)", "Normal" } },
                false,
                {}
              )
            end, 10)
          end
        }
      }
    })
  end,
}
