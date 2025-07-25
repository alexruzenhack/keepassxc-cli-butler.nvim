# keepassxc-cli-butler.nvim

Secure KeePassXC CLI integration for Neovim with YubiKey support.

## Features

- 🔐 Secure secret retrieval using custom kp-butler command
- 🔑 YubiKey hardware authentication support  
- 🔌 Plugin API for integration with other plugins
- ⚡ Synchronous secret retrieval
- [ ] 📋 Copy secrets to clipboard or insert at cursor
- [ ] TODO: ⚡ Asynchronous secret retrieval

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "alexruzenhack/keepassxc-cli-butler.nvim",
  config = function()
    require("keepassxc-cli-butler").setup({
      database_path = "$HOME/path/to/passwords.kdbx", -- Required
      database_password_entry = "password-entry-to-keepassxc-database-passwords", -- Required (use: security add-generic-password -s "password-entry-to-keepassxc-database-passwords" -a "$whoami" -T /usr/bin/security -w)
      yubikey_serial_number = "XXXXXXXX", -- Required (use: ykman list)
      notify = true, -- Enable notifications
      timeout = 30000, -- Timeout in milliseconds
      -- binary_path = "/custom/path/to/kp-butler", -- Optional: custom binary path
    })
  end,
}
```

## CLI Installation

You may want to use the undelaying CLI command kp-butler directly.

First, you nee to find where the plugin was installed and then:

```sh
sudo ln -s <plugins>/keepassxc-cli-butler/bin/kp-butler /usr/local/bin/kp-butler
```

Once installed:

```sh
kp-butler help
```

## Commands

- [x]  `:KeepassGet <entry>` - Retrieve secret and copy to clipboard
- [x] `:KeepassInsert <entry>` - Retrieve secret and insert at cursor  
- [x] `:KeepassStatus` - Show plugin status and configuration
- [x] `:KeepassConfig` - Show configuration entries

## API

```lua
local keepass = require("keepassxc-cli-butler")

-- Synchronous retrieval
local secret, err = keepass.get_secret_sync("my-entry")
```

## Test installation & Usage

```bash
# Install plenary.nvim (automatically handled by plugin managers)
# Run tests
./scripts/test.sh

# Or use make
make test

# Watch mode for development
make test-watch
```

## Requirements

- Neovim >= 0.7.0
- kp-butler command (bundled with plugin)
- KeePassXC database with YubiKey setup
