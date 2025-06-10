-- tests/keepass/init_spec.lua
local keepass = require("keepassxc-cli-butler.init")

describe("keepass", function()
	before_each(function()
		-- Reset configuration before each test
		keepass.setup({
			binary_path = "mock-kp-butler",
			notify = false,
			timeout = 5000,
		})
	end)

	describe("setup", function()
		it("should merge user config with defaults", function()
			keepass.setup({
				timeout = 10000,
				custom_option = "test",
			})

			assert.are.equal(10000, keepass.config.timeout)
			assert.are.equal("test", keepass.config.custom_option)
			assert.are.equal("kp-butler", keepass.config.binary_path)
		end)
	end)

	describe("is_available", function()
		it("should return true when binary exists", function()
			-- Mock vim.fn.executable
			local original_executable = vim.fn.executable
			vim.fn.executable = function(cmd)
				return cmd == "mock-kp-butler" and 1 or 0
			end

			assert.is_true(keepass.is_available())

			-- Restore
			vim.fn.executable = original_executable
		end)

		it("should return false when binary does not exist", function()
			keepass.config.binary_path = "nonexistent-binary"

			assert.is_false(keepass.is_available())
		end)
	end)

	describe("status", function()
		it("should return current plugin status", function()
			local status = keepass.status()

			assert.are.equal("mock-kp-butler", status.binary_path)
			assert.is_table(status.config)
			assert.is_boolean(status.binary_exists)
		end)
	end)
end)
