#!/bin/bash
# scripts/test.sh
set -euo pipefail

NVIM_CMD="${NVIM_CMD:-nvim}"

echo "🧪 Running KeePass plugin tests..."

# Run tests with plenary
$NVIM_CMD --headless \
  --noplugin \
  -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"

echo "✅ Tests completed!"
