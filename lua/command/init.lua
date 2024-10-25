local M = {}

local notify = require('command.utils').notify

M.ChangeDirection = function()
	if not M.backend.directions then
		notify('Changing directions is not supported using backend: ' .. vim.g.command.use, 'error')
		return
	end
	M.CommandDirection = (M.CommandDirection % #M.backend.directions + 1)
	notify('Changed command direction to ' .. M.backend.directions[M.CommandDirection].name, 'info')
end

local Input = require 'nui.input'
local event = require('nui.utils.autocmd').event

--- @type string
M.LastCommand = nil
--- @type number
M.CommandDirection = 1

--- @type backend
M.backend = nil

M.Run = function()
	local input = Input({
		relative = 'editor',
		position = '50%',
		size = {
			width = 24,
		},
		border = {
			style = 'rounded',
			text = {
				top = vim.g.command.icon .. 'cmd: ',
				top_align = 'left',
			},
		},
		win_options = {
			winhighlight = 'Normal:Normal',
		},
	}, {
		prompt = '$ ',
		default_value = '',
		on_submit = function(command)
			if command then
				M.LastCommand = command
				vim.g.command.backend.run(command)
			end
		end,
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

M.Last = function()
	if M.LastCommand then
		vim.g.command.backend.run(M.LastCommand)
	else
		notify('No command to repeat', 'warn')
	end
end

M.CurrentFile = function()
	local command = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.expand '%:t'
	local filepath = vim.fn.expand '%:p'

	for pattern, callback in pairs(vim.g.command.rules) do
		if string.find(filename, pattern) then
			command = callback(filepath)
			vim.g.command.backend.run(command)
			M.LastCommand = command
			return
		end
	end

	-- if we're gonna run the file as is, check if it's executable first
	local perms = vim.fn.getfperm(filepath)
	if not perms:find 'x' then
		vim.ui.select({ 'Yes', 'No' }, {
			prompt = vim.g.command.icon .. 'make executable?',
		}, function(choice)
			if choice and choice:find '[Yy]' then
				vim.g.command.backend.run('chmod +x ' .. filepath)
				vim.g.command.backend.run(command)
				M.LastCommand = command
			else
				notify("didn't run file, as it's not executable", 'info')
			end
		end)
	else
		vim.g.command.backend.run(command)
		M.LastCommand = command
	end
end

return M
