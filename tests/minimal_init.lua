local plugin_dir = os.getenv("PLUGIN_DIR") or "/tmp/plugins"
local is_not_a_directory = vim.fn.isdirectory(plugin_dir) == 0
if is_not_a_directory then
  vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plugin_dir .. '/plenary.nvim' })
  vim.fn.system({ "git", "clone", "https://github.com/akinsho/toggleterm.nvim", plugin_dir .. '/toggleterm.nvim' })
  vim.fn.system({ "git", "clone", "https://github.com/MunifTanjim/nui.nvim", plugin_dir .. '/nui.nvim' })
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plugin_dir .. '/plenary.nvim')
vim.opt.rtp:append(plugin_dir .. '/toggleterm.nvim')
vim.opt.rtp:append(plugin_dir .. '/nui.nvim')

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
