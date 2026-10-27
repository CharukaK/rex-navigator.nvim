--- Configuration module for rex-navigator.nvim
local M = {}

--- Default configuration options
M.defaults = {
  -- Automatically set up default keymaps (<C-h>, <C-j>, <C-k>, <C-l>, <C-\>)
  set_default_keymaps = true,

  -- Modes in which keymaps will be set (e.g. normal and terminal mode)
  modes = { "n", "t" },

  -- Wrap around at edges when navigating in Rex
  wrap_at_edge = false,

  -- Switch Neovim file buffers (:bnext / :bprevious) when in single window split
  switch_buffers = true,

  -- Disable navigation when current window is zoomed/maximized
  disable_when_zoomed = false,

  -- Allow navigation when focus is in a Neovim floating window
  navigate_floating_windows = false,

  -- Custom keybindings if set_default_keymaps is true
  keybindings = {
    left = "<C-h>",
    down = "<C-j>",
    up = "<C-k>",
    right = "<C-l>",
    previous = "<C-\\>",
    next = "<C-Space>",
  },
}

--- Active user options initialized with defaults
M.options = vim.tbl_deep_extend("force", {}, M.defaults)

--- Setup and validate configuration
---@param user_opts? table
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
  return M.options
end

return M
