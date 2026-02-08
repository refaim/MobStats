-- RunTests.lua
-- Entry point for running all tests with LuaUnit and LuaCov
-- Usage: lua5.1 src/Tests/RunTests.lua

-- Ensure project root is in package.path
package.path = "?.lua;" .. package.path

-- Clean old coverage files
os.remove("coverage/luacov.stats.out")
os.remove("coverage/luacov.report.out")

-- Start LuaCov for code coverage
require("luacov")

-- Load LuaUnit
local lu = require("luaunit")

-- Auto-discover and load all *Test.lua files in src/Tests/
local is_windows = package.config:sub(1, 1) == "\\"

local function discover_tests(dir)
    local cmd
    if is_windows then
        cmd = 'dir /s /b "' .. dir .. '\\*Test.lua" 2>nul'
    else
        cmd = 'find "' .. dir .. '" -name "*Test.lua" 2>/dev/null'
    end
    local handle = io.popen(cmd)
    local output = handle:read("*a")
    handle:close()

    for filepath in output:gmatch("[^\r\n]+") do
        -- Convert path to relative module name:
        -- .../src/Tests/Unit/Domain/ArmorTest.lua → src.Tests.Unit.Domain.ArmorTest
        local relative = filepath:match("(src[/\\]Tests[/\\].+)$")
        if relative then
            local module = relative:gsub("[/\\]", "."):gsub("%.lua$", "")
            require(module)
        end
    end
end

discover_tests("src/Tests")

-- Run all tests
local exit_code = lu.LuaUnit.run()
if exit_code ~= 0 then
    os.exit(exit_code)
end

-- Save coverage stats before generating report
local luacov_runner = require("luacov.runner")
luacov_runner.save_stats()

-- Generate coverage report
print("Generating coverage report...")
local luacov_reporter = require("luacov.reporter")
local cfg = luacov_runner.load_config()
local reporter = luacov_reporter.DefaultReporter:new(cfg)
reporter:run()
reporter:close()

-- Check 100% coverage
print("Checking coverage...")
local report = assert(io.open("coverage/luacov.report.out", "r"), "Error: luacov.report.out not found")

for line in report:lines() do
    ---@cast line string
    if line:match("^Total") then
        local coverage = line:match("(%d+%.%d+)%%")
        if coverage then
            print(line)
            if tonumber(coverage) < 100 then
                report:close()
                os.exit(1)
            end
            report:close()
            os.exit(0)
        end
    end
end

report:close()
print("Error: Could not find coverage summary")
os.exit(1)
