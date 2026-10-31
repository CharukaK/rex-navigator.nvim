--- Main module for rex-navigator.nvim
local config = require("rex-navigator.config")
local utils = require("rex-navigator.utils")

local M = {}

--- Neovim wincmd direction mappings
local dir_to_wincmd = {
  left = "h",
  down = "j",
  up = "k",
  right = "l",
  previous = "p",
  next = "w",
}

--- Rex focus direction mappings
local dir_to_rex = {
  left = "left",
  down = "down",
  up = "up",
  right = "right",
  previous = "prev",
  next = "next",
}

--- Set up keymaps based on configuration
local function set_keymaps()
  local opts = config.options
  if not opts.set_default_keymaps or not opts.keybindings then
    return
  end

  local bindings = opts.keybindings
  local modes = opts.modes or { "n", "t" }

  local key_dir_map = {
    [bindings.left] = "Left",
    [bindings.down] = "Down",
    [bindings.up] = "Up",
    [bindings.right] = "Right",
    [bindings.previous] = "Previous",
    [bindings.next] = "Next",
  }

  for key, cmd_suffix in pairs(key_dir_map) do
    if key and key ~= "" then
      local rhs = string.format("<Cmd>RexNavigate%s<CR>", cmd_suffix)
      for _, mode in ipairs(modes) do
        vim.keymap.set(mode, key, rhs, {
          silent = true,
          noremap = true,
          desc = string.format("Navigate Rex / Neovim %s", cmd_suffix:lower()),
        })
      end
    end
  end
end

--- Initialize plugin with options
---@param user_opts? table
function M.setup(user_opts)
  config.setup(user_opts)
  set_keymaps()
end

--- Focus a Neovim window first, then a Rex block at the window edge
---@param direction string "left"|"down"|"up"|"right"|"previous"|"next" or "h"|"j"|"k"|"l"|"p"|"n"
function M.focus(direction)
  direction = utils.norm_dir(direction)
  local opts = config.options

  -- Check if current window is a floating window
  if utils.is_floating_win() and not opts.navigate_floating_windows then
    return
  end

  -- Check if current window is zoomed/maximized
  if opts.disable_when_zoomed and utils.is_zoomed_win() then
    return
  end

  local win_cmd = dir_to_wincmd[direction]
  local prev_win = vim.api.nvim_get_current_win()

  -- 1. Try Neovim split window navigation
  if win_cmd then
    vim.cmd("wincmd " .. win_cmd)
  end

  local new_win = vim.api.nvim_get_current_win()

  -- If Neovim window split changed, we successfully moved between windows
  if prev_win ~= new_win then
    return
  end

  -- 2. At a Neovim edge, switch the Rex block that owns this process.
  if utils.is_rex() then
    local rex_dir = dir_to_rex[direction]
    if rex_dir then
      local args = { "focus", "-s", vim.env.REX_SESSION, rex_dir }
      if opts.wrap_at_edge then
        table.insert(args, "--wrap")
      end
      local ok, err = utils.run_rex_cmd(args)
      if not ok then
        vim.notify("rex-navigator: Failed to focus Rex pane: " .. tostring(err), vim.log.levels.ERROR)
      end
    end
  end
end

--- Convenience functions for directional focus
function M.focus_left()
  M.focus("left")
end

function M.focus_down()
  M.focus("down")
end

function M.focus_up()
  M.focus("up")
end

function M.focus_right()
  M.focus("right")
end

function M.focus_previous()
  M.focus("previous")
end

function M.focus_next()
  M.focus("next")
end

--- Split a Rex block in specified direction from Neovim
---@param direction string "right"|"left"|"above"|"below"
function M.split(direction)
  if not utils.is_rex() then
    vim.notify("rex-navigator: Not running inside a Rex terminal session", vim.log.levels.WARN)
    return
  end

  direction = direction or "right"
  local args = { "split", "-s", vim.env.REX_SESSION, "-b", vim.env.REX_BLOCK, "--split=" .. direction }
  local ok, err = utils.run_rex_cmd(args)
  if not ok then
    vim.notify("rex-navigator: Failed to split Rex pane: " .. tostring(err), vim.log.levels.ERROR)
  end
end

--- Toggle zoom state of current Rex block
function M.zoom_toggle()
  if not utils.is_rex() then
    vim.notify("rex-navigator: Not running inside a Rex terminal session", vim.log.levels.WARN)
    return
  end

  local ok, err = utils.run_rex_cmd({ "zoom", "-s", vim.env.REX_SESSION, vim.env.REX_BLOCK })
  if not ok then
    vim.notify("rex-navigator: Failed to toggle Rex zoom: " .. tostring(err), vim.log.levels.ERROR)
  end
end

--- Print Rex status and diagnostic information
function M.info()
  local is_rex = utils.is_rex()
  local bin = utils.get_rex_bin()
  local lines = {
    "=== rex-navigator.nvim Status ===",
    "Inside Rex Session: " .. (is_rex and "YES" or "NO"),
    "Rex Executable:     " .. (bin or "NOT FOUND"),
    "TERM_PROGRAM:       " .. (vim.env.TERM_PROGRAM or "unset"),
    "REX_SESSION:        " .. (vim.env.REX_SESSION or "unset"),
    "REX_BLOCK:          " .. (vim.env.REX_BLOCK or "unset"),
    "REX_SERVER:         " .. (vim.env.REX_SERVER or "unset"),
    "REX_BIN_DIR:        " .. (vim.env.REX_BIN_DIR or "unset"),
    "Wrap at Edge:       " .. tostring(config.options.wrap_at_edge),
    "Disable when Zoomed:" .. tostring(config.options.disable_when_zoomed),
  }

  if bin then
    local ok, ver = utils.run_rex_cmd({ "version" })
    if ok then
      table.insert(lines, "Rex Version:        " .. vim.trim(ver))
    end
  end

  print(table.concat(lines, "\n"))
end

return M
