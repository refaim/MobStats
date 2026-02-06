-- MeleeDrawerTest.lua
-- Tests for MeleeDrawer

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')
local MockTooltipInterface = require('src.Tests.Support.Mocks.MockTooltipInterface')

TestMeleeDrawer = {}

-- Test constants
local ATTACK_SPEED_MAIN = 2.0
local ATTACK_SPEED_OFF = 1.5
local ATTACK_SPEED_FRACTIONAL = 2.567
local MIN_DAMAGE_MAIN = 100
local MAX_DAMAGE_MAIN = 150
local MIN_DAMAGE_OFF = 50
local MAX_DAMAGE_OFF = 75
local MIN_DAMAGE_FRACTIONAL = 100.7
local MAX_DAMAGE_FRACTIONAL = 150.3

function TestMeleeDrawer:setUp()
    self.tooltip = MockTooltipInterface:new()
    self.drawer = MobStats.new(MobStats.MeleeDrawer)
end

function TestMeleeDrawer:tearDown()
    self.tooltip:Clear()
end

-- Test: MeleeVO = nil returns nil without calling tooltip
function TestMeleeDrawer:test_nil_melee_returns_nil()
    local result = self.drawer:Draw(nil, self.tooltip)

    lu.assertNil(result)
    lu.assertEquals(self.tooltip:GetCallCount(), 0)
end

-- Test: Only mainhand displays one line "Melee" with exact format
function TestMeleeDrawer:test_mainhand_only_displays_single_line()
    local mainhand = MobStats.DamageVO:Construct(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local melee = MobStats.MeleeVO:Construct(mainhand, nil)

    self.drawer:Draw(melee, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Melee")
    lu.assertEquals(call.value, "100-150 @ 2.00 (62.5 dps)")
    lu.assertEquals(call.wrap, false)
end

-- Test: Both hands display two lines "Melee (MH)" and "Melee (OH)"
function TestMeleeDrawer:test_dual_wield_displays_two_lines()
    local mainhand = MobStats.DamageVO:Construct(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local offhand = MobStats.DamageVO:Construct(ATTACK_SPEED_OFF, MIN_DAMAGE_OFF, MAX_DAMAGE_OFF)
    local melee = MobStats.MeleeVO:Construct(mainhand, offhand)

    self.drawer:Draw(melee, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 2)

    local call1 = self.tooltip:GetCall(1)
    lu.assertEquals(call1.label, "Melee (MH)")
    lu.assertEquals(call1.value, "100-150 @ 2.00 (62.5 dps)")
    lu.assertEquals(call1.wrap, false)

    local call2 = self.tooltip:GetCall(2)
    lu.assertEquals(call2.label, "Melee (OH)")
    lu.assertEquals(call2.value, "50-75 @ 1.50 (41.7 dps)")
    lu.assertEquals(call2.wrap, false)
end

-- Test: Rounding is correct (attack speed: 2 decimals, damage: integers, dps: 1 decimal)
function TestMeleeDrawer:test_rounding()
    local mainhand = MobStats.DamageVO:Construct(ATTACK_SPEED_FRACTIONAL, MIN_DAMAGE_FRACTIONAL, MAX_DAMAGE_FRACTIONAL)
    local melee = MobStats.MeleeVO:Construct(mainhand, nil)

    self.drawer:Draw(melee, self.tooltip)

    local call = self.tooltip:GetCall(1)
    -- Attack speed 2.567 -> 2.57 (2 decimals)
    -- Min damage 100.7 -> 101 (integer)
    -- Max damage 150.3 -> 150 (integer)
    -- DPS (100.7+150.3)/2 / 2.567 = 48.89... -> 48.9 (1 decimal)
    lu.assertEquals(call.value, "101-150 @ 2.57 (48.9 dps)")
    lu.assertEquals(call.wrap, false)
end

return TestMeleeDrawer
