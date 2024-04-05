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
	local ret, err = system('tmux ' .. subcmd)
	if err ~= nil then
		return '', 'failed to run tmux cli subcmd: ' .. err
	end
	return ret, nil
end

local function tmuxRun(cmd, pane_id)
	tmuxSubcmd('send-keys -t ' .. pane_id .. ' "' .. cmd .. '" Enter')
end

local function Tmux(cmd)
	-- notify("the tmux backend is still unimplemented", "warn")

	local direction = directions[require('command').CommandDirection]
	local panes, _ = tmuxSubcmd 'display-message -p -F "#{window_panes}"'
	if panes == '1' then
		tmuxSubcmd('split-window -' .. direction.split)
		tmuxSubcmd 'select-pane -t {last}'
	end
	tmuxRun(cmd, direction.new)
end

--- @type backend
local M = {
	run = Tmux,
	directions = directions,
}

return M
