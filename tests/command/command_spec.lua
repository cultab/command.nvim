local plugin = require 'command'

describe('setup', function()
	it('chooses tmux backend', function()
		plugin.setup { use = 'tmux' }
		assert(plugin.backend == require 'command.tmux', 'wrong backend chosen')
	end)

	it('chooses wezterm backend', function()
		plugin.setup { use = 'wezterm' }
		assert(plugin.backend == require 'command.wezterm', 'wrong backend chosen')
	end)

	it('chooses toggleterm backend', function()
		plugin.setup { use = 'toggleterm' }
		assert(plugin.backend == require 'command.toggleterm', 'wrong backend chosen')
	end)

	it('automatically chooses tmux backend', function()
		vim.env.TMUX = '1'
		plugin.setup { use = 'auto' }
		assert(plugin.backend == require 'command.tmux', 'wrong backend chosen')
	end)

	-- it('automatically chooses wezterm backend', function()
	-- 	vim.env.TMUX = nil
	-- 	vim.env.WEZTERM_EXECUTABLE = '1'
	-- 	plugin.setup { use = 'auto' }
	-- 	assert(plugin.backend == require 'command.wezterm', 'wrong backend chosen')
	-- end)

	it('automatically chooses toggleterm backend', function()
		vim.env.TMUX = nil
		plugin.setup { use = 'auto' }
		assert(plugin.backend == require 'command.toggleterm', 'wrong backend chosen')
	end)
	-- it('fails', function()
	-- 	assert(false, 'welp')
	-- end)
end)
