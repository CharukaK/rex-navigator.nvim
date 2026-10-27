--- Utility functions for rex-navigator.nvim
local M = {}

--- Map direction aliases to standard canonical direction names
local dir_aliases = {
  h = "left",
  j = "down",
  k = "up",
  l = "right",
  p = "previous",
  n = "next",
  left = "left",
  down = "down",
  up = "up",
  right = "right",
  previous = "previous",
  prev = "previous",
  next = "next",
}

--- Normalize direction string
---@param dir string
---@return string
function M.norm_dir(dir)
  dir = (dir or ""):lower()
  return dir_aliases[dir] or dir
end

--- Check if running inside a Rex terminal session
---@return boolean
function M.is_rex()
  if vim.env.TERM_PROGRAM == "rex" then
    return true
  end
  if vim.env.REX_SESSION ~= nil and vim.env.REX_SESSION ~= "" then
    return true
  end
  if vim.env.REX_SERVER ~= nil and vim.env.REX_SERVER ~= "" then
    return true
  end
  if vim.env.REX_BLOCK ~= nil and vim.env.REX_BLOCK ~= "" then
    return true
  end
  return false
end

--- Locate the Rex CLI executable path
---@return string|nil
function M.get_rex_bin()
  if vim.fn.executable("rex") == 1 then
    return "rex"
  end
  if vim.env.REX_BIN_DIR and vim.env.REX_BIN_DIR ~= "" then
    local bin = vim.env.REX_BIN_DIR .. "/rex"
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  return nil
end

--- Run a Rex CLI command safely
---@param args table List of string arguments to pass to rex
---@return boolean success, string output
function M.run_rex_cmd(args)
  local bin = M.get_rex_bin()
  if not bin then
    return false, "rex executable not found in PATH or REX_BIN_DIR"
  end

  local cmd = { bin }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error
  return exit_code == 0, output
end

--- Check if the given window ID (or current window) is a floating window
---@param win_id? integer
---@return boolean
function M.is_floating_win(win_id)
  win_id = win_id or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win_id) then
    return false
  end
  local cfg = vim.api.nvim_win_get_config(win_id)
  return cfg.relative ~= nil and cfg.relative ~= ""
end

--- Check if the current tab page has only one non-floating window (zoomed/maximized state)
---@return boolean
function M.is_zoomed_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local non_float_count = 0
  for _, w in ipairs(wins) do
    if not M.is_floating_win(w) then
      non_float_count = non_float_count + 1
    end
  end
  return non_float_count <= 1
end

return M
