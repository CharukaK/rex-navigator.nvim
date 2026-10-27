if vim.g.loaded_rex_navigator == 1 then
  return
end
vim.g.loaded_rex_navigator = 1

local nav = require("rex-navigator")

-- Define navigation user commands
vim.api.nvim_create_user_command("RexNavigateLeft", function()
  nav.focus_left()
end, { desc = "Focus split/block to the left" })

vim.api.nvim_create_user_command("RexNavigateDown", function()
  nav.focus_down()
end, { desc = "Focus split/block below" })

vim.api.nvim_create_user_command("RexNavigateUp", function()
  nav.focus_up()
end, { desc = "Focus split/block above" })

vim.api.nvim_create_user_command("RexNavigateRight", function()
  nav.focus_right()
end, { desc = "Focus split/block to the right" })

vim.api.nvim_create_user_command("RexNavigatePrevious", function()
  nav.focus_previous()
end, { desc = "Focus previous split/block" })

vim.api.nvim_create_user_command("RexNavigateNext", function()
  nav.focus_next()
end, { desc = "Focus next split/block" })

-- Define Rex pane management commands
vim.api.nvim_create_user_command("RexSplitLeft", function()
  nav.split("left")
end, { desc = "Split a new Rex pane to the left" })

vim.api.nvim_create_user_command("RexSplitRight", function()
  nav.split("right")
end, { desc = "Split a new Rex pane to the right" })

vim.api.nvim_create_user_command("RexSplitAbove", function()
  nav.split("above")
end, { desc = "Split a new Rex pane above" })

vim.api.nvim_create_user_command("RexSplitBelow", function()
  nav.split("below")
end, { desc = "Split a new Rex pane below" })

vim.api.nvim_create_user_command("RexZoomToggle", function()
  nav.zoom_toggle()
end, { desc = "Toggle zoom state of focused Rex pane" })

vim.api.nvim_create_user_command("RexInfo", function()
  nav.info()
end, { desc = "Show rex-navigator status and diagnostics" })

-- Auto-setup with defaults if user hasn't explicitly configured it yet
local config = require("rex-navigator.config")
if not config.options or vim.tbl_isempty(config.options) then
  nav.setup()
end
