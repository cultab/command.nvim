local system = require('command.utils').system
local notify = require('command.utils').notify

--- @type direction[]
local directions = {
	{
		name = 'pane on right side',
		new = 'right',
		old = 'left',
		split = 'right',
	},
	{
		name = 'pane below editor',
		new = 'down',
		old = 'up',
		split = 'bottom',
	},
}

---Returns executable suffix based on platform
--- REF: Navigator.nvim
---@return string
local function suffix()
	local uname = vim.loop.os_uname()
	if string.find(uname.release, 'WSL.*$') or string.find(uname.sysname, '^Win') then
		return '.exe'
	end
	return ''
end

-- TODO: support Next/Prev by looking at the tab id
local function weztermCli(subcmd)
	local cli = 'wezterm' .. suffix() .. ' cli '
	local ret, err = system(cli .. subcmd)
	if err ~= nil then
		return '', 'failed to run wezterm cli subcmd: ' .. err
	end
	return ret, nil
end

local function weztermRun(cmd, pane_id)
	local _, err = weztermCli('send-text --no-paste --pane-id ' .. pane_id .. " -- '" .. cmd .. "\n'")
	if err ~= nil then
		notify('failed to run command: ' .. err, 'error')
		return
	end
end

local function wezterm(cmd)
	local direction = directions[require('command').CommandDirection]
	local pane, err = weztermCli('get-pane-direction ' .. direction.new)
	if err ~= nil then
		notify(err, 'error')
	end
	if not pane then
		pane = weztermCli('split-pane --' .. direction.split)
		_, err = weztermCli('activate-pane-direction ' .. direction.old)
		if err ~= nil then
			notify(err, 'error')
		end
	end
	weztermRun(cmd, pane)
end

--- @type backend
local M = {
	run = wezterm,
	directions = directions,
}

return M
