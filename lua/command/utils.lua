local M = {}

--- @class direction
--- @field name string

--- @class backend
--- @field run function(string)
--- @field directions direction[]|nil

---@alias level "trace" | "debug" | "info" | "warn" | "error" | "off"

--- run shell command
--- @param shell_cmd string
---@return string, string?
M.system = function(shell_cmd)
	local pipe = io.popen(shell_cmd)
	if not pipe then
		return "", "failed to run shell command: " .. shell_cmd
	end
	local ret = pipe:read()
	pipe:close()
	return ret, nil
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
	vim.notify(msg, actual, { title = "command.nvim", icon = require'command'.opts.icon })
end

-- --- run shell command
-- --- @param shell_cmd string[]
-- --- @param callback fun(stdout: string)
-- ---@return nil
-- M.system = function(shell_cmd, callback)
-- 	vim.system(shell_cmd, {
-- 		stderr = function(err, data)
-- 			if err then
-- 				vim.notify('command.utils: ' .. err, 'error')
-- 				return
-- 			end
-- 			vim.notify('`' .. shell_cmd .. '` returned: ' .. data)
-- 		end,
-- 	}, function(out)
-- 		callback(out.stdout)
-- 	end)
-- end

return M
