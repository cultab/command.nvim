local M = {}
local notify = require('command.utils').notify

--- @alias backend_used
--- | 'wezterm'
--- | 'tmux'
--- | 'toggleterm'
--- | 'auto' -- pick automatically by examining environment vars

--- @class opts
--- @field use backend_used?
--- @field rules rule[]?
--- @field validate boolean?
--- @field icon string?
--- @field backend backend?

--- @class direction
--- @field name string

--- @class backend
--- @field run fun(string)
--- @field directions direction[]|nil

--- @type string
M.LastCommand = nil
--- @type number
M.CommandDirection = 1

--- @type backend
M.backend = nil
--- @type opts
M.opts = {}

--- @type backend[]
local backends = {
	wezterm = require 'command.wezterm',
	tmux = require 'command.tmux',
	toggleterm = require 'command.toggleterm',
}

--- @alias rule table<string, fun(string?):string>
--- @type rule[]

--- @type opts
local default_opts = {
	use = 'auto',
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

--- @type string[]
local valid_opts = {
	'use',
	'rules',
	'validate',
	'icon',
}

---@param user_opts opts
M.setup = function(user_opts)
	M.opts = vim.tbl_deep_extend('force', default_opts, user_opts or {})

	if M.opts.validate then
		for user_opt, _ in pairs(M.opts) do
			local ok = false
			for _, valid_opt in ipairs(valid_opts) do
				if user_opt == valid_opt then
					ok = true
				end
			end
			if not ok then
				notify('Invalid option passed to setup(): "' .. user_opt .. '"', 'warn')
			end
		end
	end

	M.popup_options = {
		relative = 'editor',
		position = '50%',
		size = {
			width = 24,
		},
		border = {
			style = 'rounded',
			text = {
				top = M.opts.icon .. 'cmd: ',
				top_align = 'left',
			},
		},
		win_options = {
			winhighlight = 'Normal:Normal',
		},
	}

	if M.opts.use == 'auto' then
		if vim.env.TMUX then
			M.backend = backends.tmux
		elseif vim.env.WEZTERM_EXECUTABLE then
			M.backend = backends.wezterm
		elseif require 'toggleterm' then
			M.backend = backends.toggleterm
		end
	else
		M.backend = backends[M.opts.use]
	end

	if not M.backend then
		notify('No such backend: ' .. M.opts.use, 'error')
	end
end

M.change_direction = function()
	if not M.backend.directions then
		notify('Changing directions is not supported using backend: ' .. M.opts.use, 'error')
		return
	end
	M.CommandDirection = (M.CommandDirection % #M.backend.directions + 1)
	notify('Changed command direction to ' .. M.backend.directions[M.CommandDirection].name, 'info')
end

local Input = require 'nui.input'
local event = require('nui.utils.autocmd').event

M.run_command = function()
	local input = Input(M.popup_options, {
		prompt = '$ ',
		default_value = '',
		on_close = function()
			-- print("Input closed!")
		end,
		on_submit = function(command)
			if command then
				M.LastCommand = command
				M.backend.run(command)
			end
		end,
		-- on_change = function(value)
		--     print("Value changed: ", value)
		-- end,
	})

	-- unmount component when cursor leaves buffer
	input:on(event.BufLeave, function()
		input:unmount()
	end)

	input:on(event.InsertLeave, function()
		input:unmount()
	end)
	-- mount/open the component
	input:mount()
	-- vim.ui.input({ prompt = opts.icon .. "cmd: ", completion = 'shellcmd' }, function(command)
	--     if command then
	--         M.LastCommand = command
	--         config.backend.run(command)
	--     end
	-- end)
end

M.run_last_command = function()
	if M.LastCommand then
		M.backend.run(M.LastCommand)
	else
		notify('No command to repeat', 'warn')
	end
end

M.run_current_file = function()
	local command = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.expand '%:t'
	local filepath = vim.fn.expand '%:p'

	for pattern, callback in pairs(M.opts.rules) do
		if string.find(filename, pattern) then
			command = callback(filepath)
			M.backend.run(command)
			M.LastCommand = command
			return
		end
	end

	-- if we're gonna run the file as is, check if it's executable first
	local perms = vim.fn.getfperm(filepath)
	if not perms:find 'x' then
		vim.ui.select({ 'Yes', 'No' }, {
			prompt = M.opts.icon .. 'make executable?',
		}, function(choice)
			if choice and choice:find '[Yy]' then
				M.backend.run('chmod +x ' .. filepath)
				M.backend.run(command)
				M.LastCommand = command
			else
				notify("didn't run file, as it's not executable", 'info')
			end
		end)
	else
		M.backend.run(command)
		M.LastCommand = command
	end
end

vim.api.nvim_create_user_command(
	'CommandChangeDirection',
	M.change_direction,
	{ desc = 'Toggles pane direction for running commands' }
)
vim.api.nvim_create_user_command('CommandRun', M.run_command, { desc = 'Prompt to run command' })
vim.api.nvim_create_user_command('CommandFile', M.run_current_file, { desc = 'Run current file' })
vim.api.nvim_create_user_command('CommandLast', M.run_last_command, { desc = 'Run last command' })

return M
