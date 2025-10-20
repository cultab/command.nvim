--- @alias backend_used
--- | 'wezterm'
--- | 'tmux'
--- | 'toggleterm'
--- | 'auto' -- pick automatically by examining environment vars

--- @alias rule table<string, fun(string?):string>

--- @class direction
--- @field name string

--- @class backend
--- @field run fun(string)
--- @field directions direction[]|nil

--- @class opts
--- @field backend backend_used?
--- @field rules rule[]?
--- @field validate boolean?
--- @field icon string?
