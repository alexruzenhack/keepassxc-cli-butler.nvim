describe("keepass commands", function()
	local original_setreg
	local captured_register_value
	local original_get_secret

	before_each(function()
		-- Mock vim.fn.setreg
		original_setreg = vim.fn.setreg
		vim.fn.setreg = function(reg, value)
			captured_register_value = value
		end

		-- Load the module first
		local butler = require("keepassxc-cli-butler.butler")

		-- Store original function
		original_get_secret = butler.get_secret_sync

		-- Mock the function in the loaded module
		butler.get_secret_sync = function(entry)
			return "test_secret", nil
		end

		-- Update package.loaded to ensure the mock persists
		-- [Optional]: This is just an assurance
		package.loaded["keepassxc-cli-butler.butler"] = butler

		-- Now source the plugin (which will use the mocked module)
		-- - The plugin entry-point loades the butler module, which is already mocked
		vim.cmd("source plugin/keepassxc-cli-butler.lua")
	end)

	after_each(function()
		vim.fn.setreg = original_setreg

		-- Restore original function
		if original_get_secret then
			local butler = require("keepassxc-cli-butler.butler")
			butler.get_secret_sync = original_get_secret
		end

		-- Clean captured register value
		if captured_register_value then
			captured_register_value = nil
		end
	end)

	describe(":KeepassGet", function()
		it("should copy secret to clipboard", function()
			vim.cmd("KeepassGet test-entry")
			assert.are.equal("test_secret", captured_register_value)
		end)
	end)

	-- TODO: Implement tests for other commands
	--
	-- describe.todo(":KeepassInsert")
	-- describe.todo(":KeepassStatus")
end)
