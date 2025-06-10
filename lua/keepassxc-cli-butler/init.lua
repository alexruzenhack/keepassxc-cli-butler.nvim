local M = {}

-- Default configuration
local default_config = {
	database_path = nil, -- KeePassXC database file path
	database_password_entry = nil, -- KeePassXC database password entry registere in the system keychain
	yubikey_serial_number = nil, -- The serial number for the Yubikey device used as MFA in the KeePassXC
	binary_path = nil, -- Auto-detect or use bundled
	notify = true,
	timeout = 30000, -- 30 seconds timeout for operations
}

-- Plugin configuration
M.config = default_config

-- Import bridge module
local butler = require("keepassxc-cli-butler.butler")

--- Initialize the keepassxc-cli-butler plugin with optional configuration.
--- Auto-detects the kp-butler binary if not explicitly configured.
--- Searches for bundled binary first, then system PATH.
--- @param opts table|nil Optional configuration table to override defaults
--- @field opts.database_path string|nil Path to the KeePassXC database file (required)
--- @field opts.database_password_entry string|nil Password entry registered in the system keychain (required)
--- @field opts.yubikey_serial_number string|nil Yubikey serial number used as MFA with the KeePassXC database (optional)
--- @field opts.binary_path string|nil Path to kp-butler binary (auto-detected if nil)
--- @field opts.notify boolean Whether to show notifications (default: true)
--- @field opts.timeout number Timeout in milliseconds for operations (default: 30000)
function M.setup(opts)
	M.config = vim.tbl_extend("force", default_config, opts or {})

	if not M.config.database_path then
		vim.notify("❌  Database path not configured. Please set a database_path", vim.log.levels.ERROR)
		return
	end

	if not M.config.database_password_entry then
		vim.notify(
			"❌  Database password entry not configured. Please set a database_password_entry",
			vim.log.levels.ERROR
		)
		return
	end

	if not M.config.yubikey_serial_number then
		vim.notify("Yubikey serial number not configured. Please set a yubikey_serial_number", vim.log.levels.WARN)
	end

	-- Auto-detect or set binary path
	if not M.config.binary_path then
		local plugin_root = debug.getinfo(1, "S").source:match("@(.*/)")
		plugin_root = plugin_root:gsub("lua/keepassxc%-cli%-butler/?$", "")
		local bundled_binary = plugin_root .. "bin/kp-butler"

		vim.notify("bundled_binary: " .. bundled_binary, vim.log.levels.WARN)

		if vim.fn.executable(bundled_binary) == 1 then
			M.config.binary_path = bundled_binary
		elseif vim.fn.executable("kp-butler") == 1 then
			M.config.binary_path = "kp-butler"
		else
			vim.notify("❌  kp-butler not found. Please install or configure binary_path", vim.log.levels.ERROR)
			return
		end
	end

	butler.config_set_database_path(M.config.database_path, M.config.binary_path)
	butler.config_set_keychain_entry(M.config.database_password_entry, M.config.binary_path)

	if M.config.yubikey_serial_number then
		butler.config_set_yubikey_serial(M.config.yubikey_serial_number, M.config.binary_path)
	end
end

--- Public API: Synchronously retrieve a secret from KeePassXC database.
--- Uses the configured kp-butler binary to fetch the specified entry.
--- @param entry string The entry path/name to retrieve from KeePassXC
--- @return string|nil secret The retrieved secret value, or nil if failed
--- @return string|nil error Error message if retrieval failed
function M.get_secret_sync(entry)
	if not M.config.binary_path then
		return nil, "kp-butler binary not configured or found"
	end

	return butler.get_secret_sync(entry, M.config.binary_path)
end

--- Utility: Check if the plugin is properly configured and ready to use.
--- Verifies that the binary path is set and the binary is executable.
--- @return boolean true if plugin is available and ready, false otherwise
function M.is_available()
	return M.config.binary_path and vim.fn.executable(M.config.binary_path) == 1
end

--- Utility: Get the current status and configuration of the plugin.
--- Provides detailed information about binary availability and current settings.
--- @return table status Table containing plugin status information
--- @field status.binary_path string|nil Path to the configured kp-butler binary
--- @field status.binary_exists boolean Whether the binary exists and is executable
--- @field status.config table Current plugin configuration
function M.status()
	local status = {
		binary_path = M.config.binary_path,
		binary_exists = M.config.binary_path and vim.fn.executable(M.config.binary_path) == 1,
		config = M.config,
	}

	return status
end

return M
