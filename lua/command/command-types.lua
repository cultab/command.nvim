--- @alias backend_used
--- | 'wezterm'
--- | 'tmux'
--- | 'toggleterm'
--- | 'zellij'
--- | 'auto' -- pick automatically by examining environment vars

--- @alias rule table<string, fun(string?):string>

--- @class direction
--- @field name string
--- @field new string|nil
--- @field old string|nil
--- @field split string|nil

--- @class backend
--- @field run fun(string)
--- @field directions direction[]|nil

--- @class opts
--- @field backend backend_used?
--- @field rules rule[]?
--- @field validate boolean?
--- @field icon string?
