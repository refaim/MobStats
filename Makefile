.PHONY: test lint format luacheck emmylua-check stylua

lint: emmylua-check luacheck stylua

test:
	lua5.1 src/Tests/RunTests.lua

luacheck:
	luacheck src

emmylua-check:
	emmylua_check .

stylua:
	stylua --check src/

format:
	stylua src/
