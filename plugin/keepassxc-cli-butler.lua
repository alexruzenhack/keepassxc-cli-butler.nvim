-- plugin/keepass.lua (Command definitions)
local bluter = require("keepassxc-cli-butler.butler")

-- Command: Get a secret and copy to clipboard
vim.api.nvim_create_user_command("KeepassGet", function(opts)
	local entry = opts.args
	if entry == "" then
		vim.notify("❌ Usage: :KeepassGet <entry_name>", vim.log.levels.ERROR)
		return
	end

	local secret, err = bluter.get_secret_sync(entry)
	if secret then
		vim.fn.setreg("+", secret)
		vim.notify("🔑 Secret copied to clipboard!", vim.log.levels.INFO)
	else
		vim.notify("❌ Error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
	end
end, {
	nargs = 1,
	-- TODO: Add support to auto complete by implementing a function list_entries
	--
	-- ucomment the code bellow:
	-- complete = function()
	--   local entries, _ = require('keepassxc-cli-butler.butler').list_entries()
	--   return entries or {}
	-- end,
	desc = "Retrieve KeePass secret and copy to clipboard",
})

-- Command: Insert secret at cursor
vim.api.nvim_create_user_command("KeepassInsert", function(opts)
	local entry = opts.args
	if entry == "" then
		vim.notify("❌ Usage: :KeepassInsert <entry_name>", vim.log.levels.ERROR)
		return
	end

	local secret, err = bluter.get_secret_sync(entry)
	if secret then
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { secret })
		vim.notify("🔑 Secret inserted!", vim.log.levels.INFO)
	else
		vim.notify("❌ Error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
	end
end, {
	nargs = 1,
	desc = "Retrieve KeePass secret and insert at cursor",
})

-- Command: Check plugin status
vim.api.nvim_create_user_command("KeepassStatus", function()
	local status = bluter.status()

	print("KeePass Plugin Status:")
	print("  Binary Path: " .. (status.binary_path or "not configured"))
	print("  Binary Available: " .. (status.binary_exists and "✅ Yes" or "❌ No"))
	print("  Notifications: " .. (status.config.notify and "enabled" or "disabled"))
end, {
	desc = "Show KeePass plugin status",
})

-- Command: Get config entries
vim.api.nvim_create_user_command("KeepassConfig", function()
	local entries = bluter.config_get_entries()
	if entries then
		for key, value in pairs(entries) do
			print(key .. "=" .. value)
		end
	end
end, {
	desc = "Show config entries",
})
