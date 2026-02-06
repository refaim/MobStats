-- DamageTest.lua
-- Tests for DamageVO domain object

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')

TestDamage = {}

-- Test constants
local ATTACK_SPEED_VERY_FAST = 0.001
local ATTACK_SPEED_FAST = 0.5
local ATTACK_SPEED_NORMAL = 2.0
local ATTACK_SPEED_SLOW = 1.5
local ATTACK_SPEED_MEDIUM = 2.5
local MIN_DAMAGE_LOW = 10
local MIN_DAMAGE_MEDIUM = 50
local MIN_DAMAGE_HIGH = 100
local MAX_DAMAGE_LOW = 20
local MAX_DAMAGE_MEDIUM = 100
local MAX_DAMAGE_HIGH = 200
local DAMAGE_EQUAL = 100

-- Test: Basic construction with valid values
function TestDamage:test_construct_with_valid_values()
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)

    lu.assertEquals(damage:GetAttackSpeed(), ATTACK_SPEED_NORMAL)
    lu.assertEquals(damage:GetMinDamage(), MIN_DAMAGE_HIGH)
    lu.assertEquals(damage:GetMaxDamage(), MAX_DAMAGE_HIGH)
end

-- Test: DPS calculation
function TestDamage:test_dps_calculation()
    -- DPS = ((min + max) / 2) / attack_speed
    -- For 100-200 damage, 2.0 speed: ((100 + 200) / 2) / 2.0 = 150 / 2 = 75
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)

    local expected_dps = ((MIN_DAMAGE_HIGH + MAX_DAMAGE_HIGH) / 2.0) / ATTACK_SPEED_NORMAL
    lu.assertEquals(damage:GetDPS(), expected_dps)
end

-- Test: DPS with fractional values
function TestDamage:test_dps_with_fractional_values()
    -- For 50-100 damage, 1.5 speed: ((50 + 100) / 2) / 1.5 = 75 / 1.5 = 50
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_SLOW, MIN_DAMAGE_MEDIUM, MAX_DAMAGE_MEDIUM)

    local expected_dps = ((MIN_DAMAGE_MEDIUM + MAX_DAMAGE_MEDIUM) / 2.0) / ATTACK_SPEED_SLOW
    lu.assertEquals(damage:GetDPS(), expected_dps)
end

-- Test: DPS with equal min and max damage
function TestDamage:test_dps_with_equal_min_max()
    -- For 100-100 damage, 2.0 speed: ((100 + 100) / 2) / 2.0 = 100 / 2 = 50
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, DAMAGE_EQUAL, DAMAGE_EQUAL)

    local expected_dps = DAMAGE_EQUAL / ATTACK_SPEED_NORMAL
    lu.assertEquals(damage:GetDPS(), expected_dps)
end

-- Test: Very fast attack speed
function TestDamage:test_fast_attack_speed()
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_FAST, MIN_DAMAGE_LOW, MAX_DAMAGE_LOW)

    -- DPS = ((10 + 20) / 2) / 0.5 = 15 / 0.5 = 30
    local expected_dps = ((MIN_DAMAGE_LOW + MAX_DAMAGE_LOW) / 2.0) / ATTACK_SPEED_FAST
    lu.assertEquals(damage:GetDPS(), expected_dps)
end

-- Test: Very small attack speed (edge case)
function TestDamage:test_very_small_attack_speed()
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_VERY_FAST, MIN_DAMAGE_LOW, MAX_DAMAGE_LOW)

    -- DPS = ((10 + 20) / 2) / 0.001 = 15 / 0.001 = 15000
    local expected_dps = ((MIN_DAMAGE_LOW + MAX_DAMAGE_LOW) / 2.0) / ATTACK_SPEED_VERY_FAST
    lu.assertEquals(damage:GetDPS(), expected_dps)
end

-- Test: min_damage > max_damage is allowed (no validation in code)
function TestDamage:test_min_damage_greater_than_max_allowed()
    -- Code does not validate min <= max, so this should work
    local damage = MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MAX_DAMAGE_HIGH, MIN_DAMAGE_HIGH)

    lu.assertEquals(damage:GetMinDamage(), MAX_DAMAGE_HIGH)
    lu.assertEquals(damage:GetMaxDamage(), MIN_DAMAGE_HIGH)
end

-- Test: Invalid zero attack speed throws error
function TestDamage:test_zero_attack_speed_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(0, MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid negative attack speed throws error
function TestDamage:test_negative_attack_speed_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(-1.0, MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid nil attack speed throws error
function TestDamage:test_nil_attack_speed_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(nil, MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid zero min damage throws error
function TestDamage:test_zero_min_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, 0, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid negative min damage throws error
function TestDamage:test_negative_min_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, -10, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid nil min damage throws error
function TestDamage:test_nil_min_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, nil, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Invalid zero max damage throws error
function TestDamage:test_zero_max_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, 0)
    end)
end

-- Test: Invalid negative max damage throws error
function TestDamage:test_negative_max_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, -50)
    end)
end

-- Test: Invalid nil max damage throws error
function TestDamage:test_nil_max_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, nil)
    end)
end

-- Test: Non-number attack speed throws error
function TestDamage:test_non_number_attack_speed_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct("2.0", MIN_DAMAGE_HIGH, MAX_DAMAGE_HIGH)
    end)
end

-- Test: Non-number min damage throws error
function TestDamage:test_non_number_min_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, "100", MAX_DAMAGE_HIGH)
    end)
end

-- Test: Non-number max damage throws error
function TestDamage:test_non_number_max_damage_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.DamageVO:Construct(ATTACK_SPEED_NORMAL, MIN_DAMAGE_HIGH, "200")
    end)
end

return TestDamage
