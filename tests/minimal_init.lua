-- Minimal Neovim config for testing
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[runtime! plugin/plenary.vim]])

-- Add your plugin to the runtime path
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(plugin_dir)

-- Load your plugin
require("keepassxc-cli-butler").setup({
	binary_path = "mock-kp-butler", -- Use mock for testing
	notify = false, -- Disable notifications in tests
})
