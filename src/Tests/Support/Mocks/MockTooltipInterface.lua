-- MockTooltipInterface.lua
-- Mock implementation of TooltipInterface for testing

local MockTooltipInterface = {}
MockTooltipInterface.__index = MockTooltipInterface

function MockTooltipInterface:new()
    local instance = {
        calls = {}
    }
    setmetatable(instance, MockTooltipInterface)
    return instance
end

-- Mock GetValueColor to return a fixed color
function MockTooltipInterface:GetValueColor()
    return "|cffffffff"  -- White
end

-- Mock AddValue to record the call
function MockTooltipInterface:AddValue(label, value, wrap)
    table.insert(self.calls, {
        label = label,
        value = value,
        wrap = wrap
    })
end

-- Test helper: Get number of calls
function MockTooltipInterface:GetCallCount()
    return #self.calls
end

-- Test helper: Get a specific call (1-indexed)
function MockTooltipInterface:GetCall(index)
    return self.calls[index]
end

-- Test helper: Clear all recorded calls
function MockTooltipInterface:Clear()
    self.calls = {}
end

return MockTooltipInterface
