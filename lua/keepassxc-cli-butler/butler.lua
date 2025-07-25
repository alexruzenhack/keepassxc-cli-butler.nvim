-- lua/keepass/bridge.lua (Updated version of your module)
local M = {}

-- Retrieves a secret synchronously using kp-butler command
-- Prompts user to touch YubiKey and waits for the operation to complete
--
-- @param entry string: The entry identifier for the secret to retrieve
-- @return string|nil: The retrieved secret (whitespace trimmed) on success, nil on failure
-- @return string|nil: Error message on failure, nil on success
--
-- Error cases:
-- - Command execution failure (io.popen fails)
-- - Command exits with non-zero status
-- - Empty or whitespace-only result from command
--
-- Side effects:
-- - Displays notification prompting YubiKey touch
-- - Displays success notification on successful retrieval
function M.get_secret_sync(entry, binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler get <paht/to/entry>` command
	local command = binary_path .. " get_sync " .. vim.fn.shellescape(entry)
	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		return nil, "Command failed to execute: " .. (err or "unknown error")
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process direct to lua process
	local result = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		return nil, string.format("Command exited abnormally [%s:%d]", exit_type, exit_code)
	end

	local cleaned = result and result:gsub("^%s*(.-)%s*$", "%1")
	if not cleaned or cleaned == "" then
		return nil, "No secret found for entry: " .. entry
	end

	-- this notification will appear only after return, as io.popen blocks
	-- Neovim's event loop, preventing queued notifications from displaying
	vim.notify("✅ Secret retrieved!", vim.log.levels.INFO)
	return cleaned
end

function M.list_entries_sync(binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler get <paht/to/entry>` command
	local command = binary_path .. " list_sync"
	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		return nil, "Command failed to execute: " .. (err or "unknown error")
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process  direct to lua process
	local result = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		return nil, string.format("Command exited abnormally [%s:%d]", exit_type, exit_code)
	end

	-- this notification will appear only after return, as io.popen blocks
	-- Neovim's event loop, preventing queued notifications from displaying
	vim.notify("✅ Enties list retrieved!", vim.log.levels.INFO)
	return result
end

function M.config_set_database_path(entry, binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler get <paht/to/entry>` command
	local command = binary_path .. " config db " .. vim.fn.shellescape(entry)

	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		vim.notify("❌ " .. "Command failed to execute: " .. (err or "unknown error"), vim.log.levels.ERROR)
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process  direct to lua process
	local _ = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		vim.notify(
			"❌ " .. string.format("Command exited abnormally [%s:%d]", exit_type, exit_code),
			vim.log.levels.ERROR
		)
	end
end

function M.config_set_keychain_entry(entry, binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler get <paht/to/entry>` command
	local command = binary_path .. " config keychain " .. vim.fn.shellescape(entry)

	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		vim.notify("❌ " .. "Command failed to execute: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process  direct to lua process
	local _ = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		vim.notify(
			"❌ " .. string.format("Command exited abnormally [%s:%d]", exit_type, exit_code),
			vim.log.levels.ERROR
		)
	end
end

function M.config_set_yubikey_serial(entry, binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler get <paht/to/entry>` command
	local command = binary_path .. " config yubikey " .. vim.fn.shellescape(entry)

	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		vim.notify("❌ " .. "Command failed to execute: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process  direct to lua process
	local _ = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		vim.notify(
			"❌ " .. string.format("Command exited abnormally [%s:%d]", exit_type, exit_code),
			vim.log.levels.ERROR
		)
	end
end

function M.config_get_entries(binary_path)
	-- default to embedded kp-butler script command
	binary_path = binary_path or "kp-butler"

	-- results in `kp-butler config show` command
	local command = binary_path .. " config show"

	-- call the command in a new process
	local handle, err = io.popen(command)

	if not handle then
		vim.notify("❌ " .. "Command failed to execute: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return nil
	end

	-- read from the handle buffer content
	-- - despite the usage of a file API, handle is not a file
	-- - the data was streammed from the spawned process  direct to lua process
	local entries = handle:read("*a")
	local success, exit_type, exit_code = handle:close()

	if not success then
		vim.notify(
			"❌ " .. string.format("Command exited abnormally [%s:%d]", exit_type, exit_code),
			vim.log.levels.ERROR
		)
	end

	-- extract key-value pairs from entries
	local entriesTable = {}
	for key, value in entries:gmatch("([%w_]+)=([^\n]+)") do
		entriesTable[key] = value
	end

	return entriesTable
end

-- Integration with telescope.nvim or vim.ui.select
function M.browse_entries(binary_path)
	local entries, err = M.list_entries_sync(binary_path)
	if not entries then
		vim.notify("Error: " .. err, vim.log.levels.ERROR)
		return
	end

	vim.ui.select(entries, {
		prompt = "Select KeePass entry:",
	}, function(choice)
		if choice then
			M.get_secret_sync(choice)
		end
	end)
end

-- Secure clipboard management with auto-clear
function M.copy_secret_secure(entry, clear_after_seconds)
	local secret, err = M.get_secret_sync(entry)
	if secret then
		vim.fn.setreg("+", secret)
		vim.notify("🔑 Secret copied (auto-clear in " .. clear_after_seconds .. "s)")

		vim.defer_fn(function()
			vim.fn.setreg("+", "")
			vim.notify("🧹 Clipboard cleared")
		end, clear_after_seconds * 1000)
	end
end

return M
