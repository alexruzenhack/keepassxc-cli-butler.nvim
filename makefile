# Makefile
.PHONY: test test-watch lint format

test:
	@echo "Running tests..."
	@./scripts/test.sh

test-watch:
	@echo "Running tests in watch mode..."
	@find . -name "*.lua" | entr -c make test

lint:
	@echo "Running luacheck..."
	@luacheck lua/ tests/

format:
	@echo "Formatting code with stylua..."
	@stylua lua/ tests/

install-dev-deps:
	@echo "Installing development dependencies..."
	@luarocks install luacheck
	@luarocks install stylua
