local notify = require('command.utils').notify

--- @type backend[]
local backends = {
	wezterm = require 'command.wezterm',
	tmux = require 'command.tmux',
	toggleterm = require 'command.toggleterm',
}

--- @type opts
local default_opts = {
	rules = {
		['.*%.lua'] = function(filepath)
			return 'nvim -l ' .. filepath
		end,
		['Makefile'] = function(_)
			return 'make'
		end,
	},
	validate = true,
	icon = '$ ',
}

-- overwrite opts with user config
local opts = vim.tbl_deep_extend('force', default_opts, vim.g.command or {})

-- if backend is unset try heuristics
-- else fallback to the 'use' key
if not opts.backend then
	if vim.env.TMUX then
		opts.backend = backends.tmux
	elseif vim.env.TERM == 'wezterm' then
		opts.backend = backends.wezterm
	elseif require 'toggleterm' then
		opts.backend = backends.toggleterm
	else
		notify('No backend could be chosen automatically', 'error')
	end
else
	opts.backend = backends[opts.use]
end

local get_subcommand = function(opts)
	local subcommands = require 'command'

	local fargs = opts.fargs
	local subcommand_key = fargs[1]
	local subcommand = subcommands[subcommand_key]
	if not subcommand then
		notify("No such subcommand: '" .. subcommand_key .. "'", 'error')
		return
	end
	subcommand()
end

vim.api.nvim_create_user_command('Command', get_subcommand, {
	nargs = '+',
	desc = 'Run command',
	complete = function(arg_lead, cmdline, _)
		local subcommands = require 'command'
		if cmdline:match "^['<,'>]*Command[!]*%s+%w*$" then
			-- Filter subcommands that match
			local subcommand_keys = vim.tbl_keys(subcommands)
			return vim.iter(subcommand_keys)
				:filter(function(key)
					return key:find(arg_lead) ~= nil
				end)
				:totable()
		end
	end,
})

vim.g.command = opts
