local repo = assert(arg[1], "repository path required")
package.path = repo .. "/?.lua;" .. package.path

local bindings = {}
local focused
local process_name = "nvim"

rex = {
  bind = function(key, fn)
    bindings[key] = fn
  end,
  block = {
    call = function()
      return { foreground = { name = process_name } }
    end,
  },
  session = {
    focus_direction = function(args) focused = args.direction; return {} end,
    focus_previous_pane = function() focused = "previous"; return {} end,
  },
}

require("rex-navigator").setup()
assert(bindings["ctrl+h"]({ block_id = "block:test" }) == false, "Rex must pass navigation keys to Neovim")
assert(focused == nil, "Rex must not move while Neovim owns the key")

process_name = "zsh"
assert(bindings["ctrl+l"]({ block_id = "block:test" }) == true, "Rex must handle navigation outside Neovim")
assert(focused == "right", "Rex must focus in the bound direction")

bindings["ctrl+\\"]({ block_id = "block:test" })
assert(focused == "previous", "Ctrl-backslash must focus the previous Rex pane")

print("rex_config_spec: ok")
