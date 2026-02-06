-- ArmorDrawerTest.lua
-- Tests for ArmorDrawer

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')
local MockTooltipInterface = require('src.Tests.Support.Mocks.MockTooltipInterface')

TestArmorDrawer = {}

-- Test constants
local PLAYER_LEVEL_1 = 1
local PLAYER_LEVEL_60 = 60
local ARMOR_ZERO = 0
local ARMOR_LOW = 100
local ARMOR_MEDIUM = 1000
local ARMOR_MEDIUM_FRACTIONAL = 1000.7
local ARMOR_HIGH = 5000
local ARMOR_VERY_HIGH = 100000

function TestArmorDrawer:setUp()
    self.tooltip = MockTooltipInterface:new()
    self.drawer = MobStats.new(MobStats.ArmorDrawer)
end

function TestArmorDrawer:tearDown()
    self.tooltip:Clear()
end

-- Test: nil input does nothing
function TestArmorDrawer:test_nil_armor_does_nothing()
    self.drawer:Draw(nil, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 0)
end

-- Test: Armor with value > 0 displays value with exact DR percentage
function TestArmorDrawer:test_armor_with_value_displays_with_dr()
    local armor = MobStats.ArmorVO:Construct(ARMOR_MEDIUM, PLAYER_LEVEL_60)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Armor")
    lu.assertEquals(call.value, "1000 (15% DR)")
    lu.assertEquals(call.wrap, false)
end

-- Test: Armor with zero value displays "None"
function TestArmorDrawer:test_armor_zero_displays_none()
    local armor = MobStats.ArmorVO:Construct(ARMOR_ZERO, PLAYER_LEVEL_60)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Armor")
    lu.assertEquals(call.value, "None")
    lu.assertEquals(call.wrap, false)
end

-- Test: Fractional values are rounded correctly
function TestArmorDrawer:test_fractional_values_rounded()
    -- 1000.7 rounds to 1001, DR = 1000.7 / (1000.7 + 400 + 5100) * 100 = 15.39... -> 15%
    local armor = MobStats.ArmorVO:Construct(ARMOR_MEDIUM_FRACTIONAL, PLAYER_LEVEL_60)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.value, "1001 (15% DR)")
    lu.assertEquals(call.wrap, false)
end

-- Test: High armor values display correctly
function TestArmorDrawer:test_high_armor_values()
    -- armor 5000, level 60: 5000 / (5000 + 400 + 5100) * 100 = 5000 / 10500 * 100 = 47.62... -> 48%
    local armor = MobStats.ArmorVO:Construct(ARMOR_HIGH, PLAYER_LEVEL_60)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.value, "5000 (48% DR)")
    lu.assertEquals(call.wrap, false)
end

-- Test: Low level player affects DR calculation
function TestArmorDrawer:test_low_player_level_dr()
    -- armor 100, level 1: 100 / (100 + 400 + 85) * 100 = 100 / 585 * 100 = 17.09... -> 17%
    local armor = MobStats.ArmorVO:Construct(ARMOR_LOW, PLAYER_LEVEL_1)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.value, "100 (17% DR)")
    lu.assertEquals(call.wrap, false)
end

-- Test: Very high armor displays large numbers correctly
function TestArmorDrawer:test_very_high_armor_formatting()
    -- armor 100000, level 60: 100000 / (100000 + 400 + 5100) * 100 = 100000 / 105500 * 100 = 94.79%
    local armor = MobStats.ArmorVO:Construct(ARMOR_VERY_HIGH, PLAYER_LEVEL_60)

    self.drawer:Draw(armor, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.value, "100000 (95% DR)")
    lu.assertEquals(call.wrap, false)
end

return TestArmorDrawer
