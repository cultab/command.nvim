# command.nvim

## What

command.nvim is a simple command runner. You give it a command and it runs it in a new or existing pane of your multiplexer (or a ToggleTerm terminal). It remembers the last command so it can repeat it. It can run the current file as is or a custom command depending on rules (see Rules section). If the current file is not executable, it asks if you want to make it executable.

## Installing

With lazy

```lua
{
    "cultab/command.nvim",
    opts = {}
}

```

## Usage

### Rules

Rules are passed into the `setup()` function.
They are key-value pairs of lua patterns and functions.
```lua
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
```
The lua pattern is matched against the current filename. The function must accept an optional argument and return a string.
The optional argument will contain the filepath to the current file. The return value will be the shell command to be run when the name of the current file matches the pattern.

###  Example with Lua Functions

```lua
local map = vim.keymap.set
map('n','<leader>ct', require('command').change_direction, { desc = '[c]ommand [t]oggle pane direction' })
map('n','<leader>cc', require('command').run_command,      { desc = '[c]ommand shell [c]ommand'         })
map('n','<leader>cr', require('command').run_current_file, { desc = '[c]ommand [r]un current file'      })
map('n','<leader>cl', require('command').run_last_command, { desc = '[c]ommand repeat [l]ast command'   })
```

### User Commands

You can also use the following user commands instead of the exported lua functions.

- `:CommandChangeDirection`
    Toggles pane direction for running commands

- `:CommandRun`
    Show prompt to ask for a command to run

- `:CommandFile`
    Runs current file

- `:CommandLast`
    Runs last command

## Default opts

```lua
local default_opts = {
    -- defines the backend to use, one of:
    -- 'auto', pick automatically by examining environment vars
    -- 'tmux'
    -- 'wezterm'
    -- 'toggleterm'
	use = "auto",
    -- defines rules to overwrite the command to run when using the "run current file" behavior
    -- keys are lua patterns (see :help lua-pattern)
    -- values are functions that accept:
    --     an optional argument containing the path to the current file
    -- must return:
    --     a string of the shell command to run
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
    -- whether to check if keys in the opts passed to setup are valid
    --- @type bool
	validate = true,
    -- an icon to use for prompts and notifications
    --- @type string
	icon = "$ ",
}
```


## TODO

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
    - [ ] zelij
    - [ ] kitty
- [ ] clean up types
    - [ ] types for all opts, use lua-ls enums
    - [ ] move to utils ?
    - [ ] also in readme also
- [ ] history instead of just last command
- [x] add bugs