local repo = assert(arg[1], "repository path required")
package.path = repo .. "/lua/?.lua;" .. repo .. "/lua/?/init.lua;" .. package.path

local state
local notifications
local rex_calls

vim = {
  env = { REX_SESSION = "session:test", REX_BLOCK = "block:test" },
  fn = {},
  v = {},
  log = { levels = { ERROR = "error", WARN = "warn" } },
  api = {
    nvim_get_current_win = function()
      return state.window
    end,
  },
  cmd = function(command)
    if state.move then
      state.window = state.window + 1
    end
    state.commands[#state.commands + 1] = command
  end,
  notify = function(message)
    notifications[#notifications + 1] = message
  end,
  tbl_deep_extend = function(_, _, defaults, options)
    options = options or {}
    for key, value in pairs(defaults) do
      if options[key] == nil then
        options[key] = value
      end
    end
    return options
  end,
}

package.loaded["rex-navigator.config"] = {
  options = {
    disable_when_zoomed = false,
    navigate_floating_windows = false,
    wrap_at_edge = false,
  },
}
package.loaded["rex-navigator.utils"] = {
  norm_dir = function(direction) return direction end,
  is_floating_win = function() return false end,
  is_zoomed_win = function() return false end,
  is_rex = function() return state.in_rex end,
  run_rex_cmd = function(args)
    rex_calls[#rex_calls + 1] = args
    return state.rex_ok, "failure"
  end,
}

local navigator = require("rex-navigator")

local function reset(overrides)
  state = { window = 1, move = false, in_rex = true, rex_ok = true, commands = {} }
  for key, value in pairs(overrides or {}) do
    state[key] = value
  end
  notifications = {}
  rex_calls = {}
end

reset({ move = true })
navigator.focus("left")
assert(#rex_calls == 0, "Neovim split movement must not call Rex")

reset()
navigator.focus("right")
assert(table.concat(rex_calls[1], " ") == "focus -s session:test right", "edge navigation must target the owning Rex session")

reset({ in_rex = false })
navigator.focus("up")
assert(#rex_calls == 0, "navigation outside Rex must stay in Neovim")

reset({ rex_ok = false })
navigator.focus("down")
assert(notifications[1]:match("Failed to focus Rex pane"), "Rex failures must be reported")

print("navigation_spec: ok")
