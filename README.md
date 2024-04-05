# command.nvim

command.nvim is a simple command runner. You give it a command and it runs it in a new or existing pane of your multiplexer (or a ToggleTerm terminal). It remembers the last command so it can repeat it. It can run the current file as is or a custom command depending on rules (see Rules section). If the current file is not executable, it asks if you want to make it executable.

It supports the following multiplexers/backends:

- tmux
- wezterm
- toggleterm

# Installing

With Lazy.nvim

```lua
{
    'cultab/command.nvim',
    opts = {},
    dependencies = {
        'MunifTanjim/nui.nvim',
        'akinsho/toggleterm.nvim' -- optional, for the toggleterm backend
    }
}
```

# Usage

Setup keymaps for each action that you want to use. For example using lua:

```lua
local map = vim.keymap.set
map('n','<leader>ct', require('command').change_direction, { desc = '[c]ommand [t]oggle pane direction' })
map('n','<leader>cc', require('command').run_command,      { desc = '[c]ommand shell [c]ommand'         })
map('n','<leader>cr', require('command').run_current_file, { desc = '[c]ommand [r]un current file'      })
map('n','<leader>cl', require('command').run_last_command, { desc = '[c]ommand repeat [l]ast command'   })
```

## User Commands

You can also use the following user commands instead of the exported lua functions.

- `:CommandChangeDirection`
    Toggles pane direction for running commands

- `:CommandRun`
    Show prompt to ask for a command to run

- `:CommandFile`
    Runs current file

- `:CommandLast`
    Runs last command

## Multiplexers & Backends

### tmux & wezterm

The tmux and wezterm backends both have 2 built in pane directions, right of the editor pane, and below the editor pane.

### ToggleTerm

The ToggleTerm backend does not support toggling different pane directions, it uses the direction configured in ToggleTerm's setup.

# Configuration

Configurations is done by passing `opts` to the setup function.

```lua
require('command.nvim').setup( {--[[ your options here ]]} )
```

## Backends

The backend is the multiplexer or terminal to use. It's controlled by the `use` key in the opts table.

```lua
opts = {
    --- the backend to use, one of:
    --- @alias backend_used
    --- | 'auto' -- pick automatically by examining environment vars
    --- | 'tmux'
    --- | 'wezterm'
    --- | 'toggleterm'
	use = "auto",
}
```


## Rules

Rules are key-value pairs of lua patterns and functions.
They are passed into the `setup()` function through the opts table.

```lua
opts = {
	rules = {
        -- run the current file with `nvim -l` if it ends with '.lua'
		[".*%.lua"] = function(filepath)
			return "nvim -l " .. filepath
		end,
        -- run the default Makefile rule if the current file is called 'Makefile'
		["Makefile"] = function(_)
			return "make"
		end,
	},
}
```

The lua pattern is matched against the current filename. The function must accept an optional argument and return a string. The optional argument will contain the filepath to the current file. The return value will be the shell command to be run when the name of the current file matches the pattern.

## Default Opts

The defaults options are as follows:

```lua
local default_opts = {
    --- the backend to use, one of:
    --- @alias backend_used
    --- | 'auto' -- pick automatically by examining environment vars
    --- | 'tmux'
    --- | 'wezterm'
    --- | 'toggleterm'
	use = "auto",

    --- defines rules to overwrite the command to run when using the "run current file" behavior
    --- keys are lua patterns (see :help lua-pattern)
    ---
    --- values are functions that accept:
    ---     an optional argument containing the path to the current file
    --- returns:
    ---     a string of the shell command to run
    --- @alias rule table<string, fun(string?):string>
	rules = {
        -- run the current file with `nvim -l` if it ends with '.lua'
		[".*%.lua"] = function(filepath)
			return "nvim -l " .. filepath
		end,
        -- run the default Makefile rule if the current file is called 'Makefile'
		["Makefile"] = function(_)
			return "make"
		end,
	},

    --- whether to check if keys in the opts passed to setup are valid
    --- @type bool
	validate = true,

    --- an icon to use for prompts and notifications
    --- @type string
	icon = "$ ",
}
```

# TODO

- [ ] slime-like behaviors
    - [ ] send current line to pane
    - [ ] send buffer contents to pane
    - [ ] send virtual selection to pane
    - [ ] send buffer contents up to current line to pane
- [ ] backends
    - [x] tmux
    - [x] ToggleTerm
    - [x] wezterm
    - [ ] default nvim terminal
    - [ ] kitty
    - [ ] some other backend
    - [ ] zellij
- [x] clean up types
    - [x] types for all opts, use lua-ls enums
    - [x] move to utils ?
    - [x] also in readme also
- [ ] history instead of just last command
- [x] add bugs
- [ ] user configured pane directions
    - [ ] maybe fully custom
    - [ ] maybe add every choice and make their availability configurable
