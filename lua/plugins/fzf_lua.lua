return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  cmd = "FzfLua",               
  keys = {
    { "<leader>ff",  "<cmd>FzfLua files<CR>",           desc = "Find Files" },
    { "<leader>fg",  "<cmd>FzfLua live_grep<CR>",       desc = "Live Grep" },
    { "<leader>fh",  "<cmd>FzfLua help_tags<CR>",       desc = "Help Tags" },
    { "<leader>fb",  "<cmd>FzfLua buffers<CR>",         desc = "Buffers" },
    { "<leader>fc",  "<cmd>FzfLua commands<CR>",        desc = "Commands" },
    { "<leader>fC",  "<cmd>FzfLua command_history<CR>", desc = "Commands history" },
    { "<leader>fr",  "<cmd>FzfLua oldfiles<CR>",        desc = "Recent Files" },
    { "<leader>fm",  "<cmd>FzfLua marks<CR>",           desc = "Marks" }
  },

  config = function()
    local actions = require("fzf-lua.actions")

    require("fzf-lua").setup({
      winopts = {
        height = 0.8, 
        width = 0.8, 
        row = 0.5,  
        col = 0.5,  
        border = "rounded",
        preview = {
          default   = "builtin",
          border    = "rounded",
          winopts   = {
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
