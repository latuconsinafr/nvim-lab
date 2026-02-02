return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Move to left split" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Move to bottom split" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Move to top split" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Move to right split" },
    { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Move to previous split" },
  },
}
