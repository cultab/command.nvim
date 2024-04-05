local function ToggleTerm(cmd)
	require('toggleterm').exec(cmd)
end

--- @type backend
local M = {
	run = ToggleTerm,
	directions = nil,
}

return M
