# command.nvim

command.nvim is a simple command runner. You give it a command and it runs it in a new or existing pane of your multiplexer (or a ToggleTerm terminal).
It remembers the last command so it can repeat it.
It can also run the current file as is or using a custom command depending on rules (see [Rules](#Rules) section).
If the current file is not executable, it asks if you want to make it executable.

# TOC

- [Installation](#Installation)
- [Usage](#Usage)
- [Configuration](#Configuration)
    - [Backends](#Backends)
    - [Rules](#Rules)
    - [Defaults](#Defaults)
- [TODO](#TODO)

It supports the following multiplexers/terminal, refered to as backends hereafter:

- tmux
- wezterm
- toggleterm

## Installation

With Lazy.nvim

```lua
{
    'cultab/command.nvim',
    init = function()
        vim.g.command = { --[[ options go here ]]}
    end,
    dependencies = {
        'MunifTanjim/nui.nvim',
        'akinsho/toggleterm.nvim' -- optional, for the toggleterm backend
    }
}
```

## Usage

Setup keymaps for each action that you want to use. For example using lua:

```lua
local map = vim.keymap.set
map('n','<leader>ct', require('command').ChangeDirection, {
    desc = 'Toggles direction of opening panes for running commands' })
map('n','<leader>cc', require('command').Run,             {
    desc = 'Show prompt for a command to run'         })
map('n','<leader>cr', require('command').CurrentFile,     {
    desc = 'Run the current file, if not executable, ask whether to make executable and run'      })
map('n','<leader>cl', require('command').LastCommand,     {
    desc = 'Repeat last action'   })
```

Or use the user commands:

```vim
:Command ChangeDirection
:Command Run
:Command CurrentFile
:Command LastCommand
```

## Configuration

Configurations is done by passing setting the `vim.g.command` table.

```lua
vim.g.command = {--[[ options go here ]]} )
```

### Backends

The backend is the multiplexer or terminal to use. It's controlled by the `use` key in the options table.
If the `use` key is unset, as it is by default, heuristics are used to pick on of the supported backends.

* If `$TMUX` is set, tmux is used.

* Else if `wezterm(?.exe)` exists in `$PATH`, wezterm is used.

* Else if toggleterm's module can be `require()`'ed, toggleterm is used.

```lua
    --- @alias backend_used
    --- | 'tmux'
    --- | 'wezterm'
    --- | 'toggleterm'
    use = nil
```

#### tmux & wezterm

The tmux and wezterm backends both have 2 built in pane directions, right of the editor pane, and below the editor pane.

#### ToggleTerm

The ToggleTerm backend does not support toggling different pane directions, it uses the direction configured in ToggleTerm's setup.


### Rules

Rules are key-value pairs of lua patterns and functions.

```lua
opts = {
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
}
```

The lua pattern is compared against the current filename, if it maches the function is run to get the shell command and run it.

The function can accept an optional argument that will contain the filepath to the current file.
The function shall return a shell command, as a string, to be run.

### Defaults

The defaults options are as follows:

```lua
vim.g.command = {
    --- the backend to use, one of:
    --- optional, if unset heuristics are used to pick one
    --- @alias backend_used
    --- | 'tmux'
    --- | 'wezterm'
    --- | 'toggleterm'
    use = nil

    --- defines rules to overwrite the command to run when using the "run current file" behavior
    --- keys are lua patterns (see :help lua-pattern)
    ---
    --- values are functions that accept an optional argument containing
    --- the path to the current file and return a string of the shell command to run
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

    --- an icon to use for prompts and notifications
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
    - [ ] kitty
    - [ ] some other backend
    - [ ] zellij
- [x] clean up types
    - [x] types for all opts, use lua-ls enums
    - [x] move to utils ?
    - [x] also in readme also
- [ ] history instead of just last command
- [x] add bugs
- [x] remove bugs
- [ ] ~~user configured pane directions~~
    - [ ] ~~maybe fully custom~~
    - [ ] ~~maybe add every choice and make their availability configurable~~
- [ ] user backends
- [x] expunge `.setup()` all hail `vim.g`

## Similar Plugins

- [yeet.nvim](https://github.com/samharju/yeet.nvim), very similar, would not have *originaly* made this had I known yeet.nvim existed :^P
