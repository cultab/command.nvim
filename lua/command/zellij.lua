local system = require('command.utils').system
local notify = require('command.utils').notify

--- @type direction[]
local directions = {
	{
		name = 'pane on right side',
		new = 'right',
		split = 'right',
	},
	{
		name = 'pane below editor',
		new = 'down',
		split = 'down',
	},
}

---@param p table
---@return string|nil
local function terminal_pane_id(p)
	if p.is_plugin then
		return nil
	end
	return 'terminal_' .. p.id
end

---@param a table
---@param b table
---@return boolean
local function overlaps_vertical(a, b)
	local ay2 = a.pane_y + a.pane_rows
	local by2 = b.pane_y + b.pane_rows
	return math.max(a.pane_y, b.pane_y) < math.min(ay2, by2)
end

---@param a table
---@param b table
---@return boolean
local function overlaps_horizontal(a, b)
	local ax2 = a.pane_x + a.pane_columns
	local bx2 = b.pane_x + b.pane_columns
	return math.max(a.pane_x, b.pane_x) < math.min(ax2, bx2)
end

---@param focused table
---@param panes table[]
---@return table|nil
local function find_right_neighbor(focused, panes)
	local right_edge = focused.pane_x + focused.pane_columns
	local best
	local best_dist
	for _, p in ipairs(panes) do
		if not p.is_plugin and p.id ~= focused.id then
			if p.pane_x >= right_edge and overlaps_vertical(focused, p) then
				local dist = p.pane_x - right_edge
				if not best or dist < best_dist then
					best = p
					best_dist = dist
				end
			end
		end
	end
	return best
end

---@param focused table
---@param panes table[]
---@return table|nil
local function find_down_neighbor(focused, panes)
	local bottom_edge = focused.pane_y + focused.pane_rows
	local best
	local best_dist
	for _, p in ipairs(panes) do
		if not p.is_plugin and p.id ~= focused.id then
			if p.pane_y >= bottom_edge and overlaps_horizontal(focused, p) then
				local dist = p.pane_y - bottom_edge
				if not best or dist < best_dist then
					best = p
					best_dist = dist
				end
			end
		end
	end
	return best
end

---@param panes table[]
---@return table|nil
local function find_focused_terminal(panes)
	for _, p in ipairs(panes) do
		if p.is_focused and not p.is_plugin then
			return p
		end
	end
	local zid = vim.env.ZELLIJ_PANE_ID
	if zid then
		local num = zid:match 'terminal_(%d+)' or zid:match '^(%d+)$'
		if num then
			for _, p in ipairs(panes) do
				if not p.is_plugin and tostring(p.id) == num then
					return p
				end
			end
		end
	end
	return nil
end

---@return table[]|nil, string?
local function list_panes()
	local out, err = system { 'zellij', 'action', 'list-panes', '--json', '--geometry' }
	if err then
		return nil, err
	end
	local ok, decoded = pcall(vim.json.decode, out)
	if not ok or type(decoded) ~= 'table' then
		return nil, 'failed to parse list-panes JSON'
	end
	return decoded, nil
end

---@param panes table[]
---@return table<number, boolean>
local function terminal_ids_set(panes)
	local set = {}
	for _, p in ipairs(panes) do
		if not p.is_plugin then
			set[p.id] = true
		end
	end
	return set
end

---@param dir string
---@return table|nil, string?
local function split_pane(dir)
	local before, err = list_panes()
	if err then
		return nil, err
	end
	if not before then
		return nil, 'list-panes returned no data'
	end
	local before_ids = terminal_ids_set(before)
	local _, split_err = system { 'zellij', 'action', 'new-pane', '--direction', dir }
	if split_err then
		return nil, split_err
	end
	local after, err2 = list_panes()
	if err2 then
		return nil, err2
	end
	if not after then
		return nil, 'list-panes returned no data after split'
	end
	for _, p in ipairs(after) do
		if not p.is_plugin and not before_ids[p.id] then
			return p, nil
		end
	end
	return nil, 'could not find new pane after split'
end

---@param cmd string
---@param pane_id string
---@return string?
local function write_chars(cmd, pane_id)
	local _, err = system { 'zellij', 'action', 'write-chars', cmd .. '\n', '--pane-id', pane_id }
	return err
end

---@param cmd string
local function zellij_run(cmd)
	local panes, err = list_panes()
	if err then
		notify(err, 'error')
		return
	end
	if not panes then
		notify('list-panes returned no data', 'error')
		return
	end
	local focused = find_focused_terminal(panes)
	if not focused then
		notify('could not find focused terminal pane in Zellij', 'error')
		return
	end

	local direction = directions[require('command').CommandDirection]
	if not direction or not direction.new or not direction.split then
		notify('invalid pane direction', 'error')
		return
	end
	local neighbor
	if direction.new == 'right' then
		neighbor = find_right_neighbor(focused, panes)
	elseif direction.new == 'down' then
		neighbor = find_down_neighbor(focused, panes)
	end

	local target = neighbor
	if not target then
		local new_pane, split_err = split_pane(direction.split)
		if split_err then
			notify(split_err, 'error')
			return
		end
		if not new_pane then
			notify('split did not create a new pane', 'error')
			return
		end
		target = new_pane
	end

	local pane_id = terminal_pane_id(target)
	if not pane_id then
		notify('target pane has no terminal id', 'error')
		return
	end

	local werr = write_chars(cmd, pane_id)
	if werr then
		notify(werr, 'error')
	end
end

--- @type backend
local M = {
	run = zellij_run,
	directions = directions,
}

return M
