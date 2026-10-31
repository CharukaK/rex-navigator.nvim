# rex-navigator.nvim

Seamlessly switch between **[Rex](https://superlogical.com/rex)** panes and **Neovim** splits.

When you attempt to navigate past the edge of a Neovim split window, `rex-navigator.nvim` automatically hands off focus to the adjacent Rex pane in that direction.

Inspired by [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator).

---

## ⚡ Features

- **Seamless Navigation**: Move effortlessly across Neovim splits and Rex terminal panes using unified keybindings.
- **Normal & Terminal Mode**: Works smoothly whether you are in normal editing mode or inside a Neovim `:terminal` buffer.
- **Smart Edge Detection**: Detects Neovim split boundaries automatically before calling Rex.
- **Floating & Zoom Handling**: Configurable behavior for zoomed windows and floating windows (e.g. Telescope, Lazy, hover popups).
- **Graceful Fallback**: Functions as standard Neovim split navigation when running outside Rex.
- **Extra Rex Commands**: Split new Rex panes or toggle Rex pane zoom directly from inside Neovim (`:RexSplitRight`, `:RexZoomToggle`, etc.).
- **Rex-side Handoff**: The included Rex module sends navigation keys into Neovim and focuses Rex panes everywhere else.
- **Health Check Support**: Built-in `:checkhealth rex-navigator` diagnostic integration.

---

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "charukak/rex-navigator.nvim",
  event = "VeryLazy",
  opts = {
    set_default_keymaps = true,
  },
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'charukak/rex-navigator.nvim'
```

Then in your `init.lua`:

```lua
require("rex-navigator").setup()
```

---

## ⚙️ Configuration

Here is the full default configuration:

```lua
require("rex-navigator").setup({
  -- Automatically set up default keymaps (<C-h>, <C-j>, <C-k>, <C-l>, <C-\>, <C-Space>)
  set_default_keymaps = true,

  -- Modes in which keymaps will be registered ("n" for Normal, "t" for Terminal)
  modes = { "n", "t" },

  -- Wrap focus around screen edges when navigating in Rex
  wrap_at_edge = false,

  -- Disable navigation when current Neovim window is zoomed / maximized
  disable_when_zoomed = false,

  -- Allow navigation when focus is in a Neovim floating window
  navigate_floating_windows = false,

  -- Custom keybindings (used when set_default_keymaps = true)
  keybindings = {
    left = "<C-h>",
    down = "<C-j>",
    up = "<C-k>",
    right = "<C-l>",
    previous = "<C-\\>",
    next = "<C-Space>",
  },
})
```

---

## 🖥️ Rex Keybindings Setup (`~/.config/rex/init.lua`)

Copy this repository's `rex-navigator.lua` to `~/.config/rex/rex-navigator.lua`, then load it from `~/.config/rex/init.lua`:

```lua
require("rex-navigator").setup()
```

Reload Rex configuration:

```sh
rex config reload
```

The Rex module binds `Ctrl-h/j/k/l/\\`. When the focused terminal is running Neovim, the binding returns the key to Neovim. Otherwise it moves Rex focus. Neovim first tries its own split and calls `rex focus` only at an edge.

---

## ⌨️ Commands

| Command | Description |
|---|---|
| `:RexNavigateLeft` | Focus Neovim split or Rex pane to the left |
| `:RexNavigateDown` | Focus Neovim split or Rex pane below |
| `:RexNavigateUp` | Focus Neovim split or Rex pane above |
| `:RexNavigateRight` | Focus Neovim split or Rex pane to the right |
| `:RexNavigatePrevious` | Focus previous Neovim split or Rex pane |
| `:RexNavigateNext` | Focus next Neovim split or Rex pane |
| `:RexSplitLeft` | Split a new Rex pane to the left |
| `:RexSplitRight` | Split a new Rex pane to the right |
| `:RexSplitAbove` | Split a new Rex pane above |
| `:RexSplitBelow` | Split a new Rex pane below |
| `:RexZoomToggle` | Toggle zoom state of current Rex pane |
| `:RexInfo` | Display status and diagnostic details |

---

## 🛠️ Lua API

```lua
local nav = require("rex-navigator")

-- Directional focus
nav.focus("left") -- or nav.focus_left()
nav.focus("down") -- or nav.focus_down()
nav.focus("up")   -- or nav.focus_up()
nav.focus("right")-- or nav.focus_right()
nav.focus("previous") -- or nav.focus_previous()
nav.focus("next")     -- or nav.focus_next()

-- Rex pane management
nav.split("right") -- "right", "left", "above", "below"
nav.zoom_toggle()

-- Diagnostics
nav.info()
```

---

## 🩺 Health Check

Run the following inside Neovim to verify your environment setup:

```vim
:checkhealth rex-navigator
```

---

## 📄 License

MIT
