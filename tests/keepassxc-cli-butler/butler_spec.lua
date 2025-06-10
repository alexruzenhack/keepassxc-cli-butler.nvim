-- tests/keepass/bridge_spec.lua
local butler = require("keepassxc-cli-butler.butler")

describe("butler", function()
	local original_popen

	before_each(function()
		-- Mock io.popen for testing
		original_popen = io.popen
		_G.mock_popen_result = nil
		_G.mock_popen_success = true
		_G.mock_popen_exit_code = 0

		io.popen = function(cmd)
			return {
				read = function(self, format)
					if format == "*a" then
						return _G.mock_popen_result or "test_secret_123"
					end
				end,
				close = function(self)
					return _G.mock_popen_success, "exit", _G.mock_popen_exit_code
				end,
			}
		end
	end)

	after_each(function()
		-- Restore original io.popen
		io.popen = original_popen
	end)

	describe("get_secret_sync", function()
		it("should return secret on success", function()
			_G.mock_popen_result = "my_secret_password\n"

			local secret, err = butler.get_secret_sync("test-entry", "kp-butler")

			assert.are.equal("my_secret_password", secret)
			assert.is_nil(err)
		end)

		it("should handle command execution failure", function()
			io.popen = function(cmd)
				return nil, "Permission denied"
			end

			local secret, err = butler.get_secret_sync("test-entry", "kp-butler")

			assert.is_nil(secret)
			assert.matches("Command failed to execute", err)
		end)

		it("should handle non-zero exit codes", function()
			_G.mock_popen_success = false
			_G.mock_popen_exit_code = 1

			local secret, err = butler.get_secret_sync("test-entry", "kp-butler")

			assert.is_nil(secret)
			assert.matches("Command exited abnormally", err)
		end)

		it("should handle empty results", function()
			_G.mock_popen_result = "   \n  "

			local secret, err = butler.get_secret_sync("test-entry", "kp-butler")

			assert.is_nil(secret)
			assert.matches("No secret found", err)
		end)

		it("should trim whitespace from results", function()
			_G.mock_popen_result = "  secret_with_spaces  \n\n"

			local secret, err = butler.get_secret_sync("test-entry", "kp-butler")

			assert.are.equal("secret_with_spaces", secret)
			assert.is_nil(err)
		end)
	end)
end)
