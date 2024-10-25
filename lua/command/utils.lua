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
	out = obj.stdout:gsub('\n$', '') -- remove trailing newline
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
