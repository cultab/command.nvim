local system = require('command.utils').system
local notify = require('command.utils').notify

--- @type direction[]
local directions = {
	{
		name = 'vertical pane on right side',
		new = '{right-of}',
		split = 'h',
	},
	{
		name = 'horizontal pane below editor',
		new = '{down-of}',
		split = 'v',
	},
}

local function tmuxSubcmd(subcmd)
	return system { 'tmux', unpack(subcmd) }
end

local function tmuxRun(cmd, pane_id)
	return tmuxSubcmd { 'send-keys', '-t', pane_id, cmd .. '\n' }
end

local function Tmux(cmd)
	-- notify("the tmux backend is still unimplemented", "warn")

	local direction = directions[require('command').CommandDirection]
	local panes, err = tmuxSubcmd { 'display-message', '-p', '-F', '#{window_panes}' }
	if err ~= nil then
		notify("can't get panes: " .. err, 'error')
		return
	end
	if panes == '1' then
		local _, err = tmuxSubcmd { 'split-window', '-' .. direction.split }
		if err ~= nil then
			notify("can't split window: " .. err, 'error')
			return
		end
		tmuxSubcmd { 'select-pane', '-t', '{last}' }
		if err ~= nil then
			notify("can't return to vim pane: " .. err, 'error')
			return
		end
	end
	_, err = tmuxRun(cmd, direction.new)
	if err ~= nil then
		notify(err, 'error')
		return
	end
end

--- @type backend
local M = {
	run = Tmux,
	directions = directions,
}

return M
