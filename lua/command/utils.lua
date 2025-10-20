local M = {}

---@alias level "trace" | "debug" | "info" | "warn" | "error" | "off"

--- run shell command
--- @param cmd string[]
---@return string, string?
M.system = function(cmd)
	local obj = vim.system(cmd):wait()
	if obj.code ~= 0 then
		return '',
			'failed to run "' .. vim.inspect(cmd) .. '"\n\texit code: ' .. obj.code .. '\n\tstderr: ' .. obj.stderr
	end
	local out = obj.stdout:gsub('\n$', '') -- remove trailing newline
	return out, nil
end

local levels = {
	trace = 0,
	debug = 1,
	info = 2,
	warn = 3,
	error = 4,
	off = 5,
}

---@param msg string
---@param level level
M.notify = function(msg, level)
	local actual = levels[level]
	vim.notify(msg, actual, { title = 'command.nvim', icon = vim.g.command.icon })
end

return M
