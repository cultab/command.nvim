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

local suffix_cache = nil
---Returns executable suffix based on platform
---@return string
local function suffix()
	if suffix_cache then
		return suffix_cache
	end

	suffix_cache = '' -- default to empty, overwrite if it's windows
	-- NOTE: don't use utils.system here. An error means we're not on windows, NOT that something went wrong.
	local ok, obj = pcall(vim.system, { 'wezterm.exe', '--help' })
	if not ok then
		return suffix_cache
	end
	if obj:wait().code == 0 then
		suffix_cache = '.exe'
	end
	return suffix_cache
end

--  TODO: support Next/Prev by looking at the tab id
local function weztermCli(subcmd)
	local bin = 'wezterm' .. suffix()
	local ret, err = system { bin, 'cli', unpack(subcmd) }
	return ret, err
end

local function weztermRun(cmd, pane_id)
	local _, err = weztermCli { 'send-text', '--no-paste', '--pane-id', pane_id, '--', '' .. cmd .. '\n' }
	if err ~= nil then
		notify('command failed: ' .. err, 'error')
		return
	end
end

local function wezterm(cmd)
	local direction = directions[require('command').CommandDirection]
	local pane, err = weztermCli { 'get-pane-direction', direction.new }
	if err ~= nil then
		notify("can't get-pane-direction: " .. err, 'error')
	end
	if pane == '' then
		pane, err = weztermCli { 'split-pane', '--' .. direction.split }
		if err ~= nil then
			notify("cant' split-pane" .. err, 'error')
		end
		_, err = weztermCli { 'activate-pane-direction', direction.old }
		if err ~= nil then
			notify("can't activate-pane-direction: " .. err, 'error')
		end
	end
	weztermRun(cmd, pane)
	if err ~= nil then
		notify(err, 'error')
	end
end

--- @type backend
local M = {
	run = wezterm,
	directions = directions,
}

return M
